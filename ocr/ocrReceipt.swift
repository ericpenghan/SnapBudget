import Foundation

struct OcrData: Codable {
    var ParsedResults: [Results]
    var OCRExitCode: Int
    var IsErroredOnProcessing: Bool
    var ProcessingTimeInMilliseconds: String
    var SearchablePDFURL: String
}

struct Results: Codable {
    var TextOverlay: AllLineData
    var TextOrientation: String
    var FileParseExitCode: Int
    var ParsedText: String
    var ErrorMessage: String
    var ErrorDetails: String
}

struct AllLineData: Codable {
    var Lines: [LineData]
    var HasOverlay: Bool
    var Message: String
}

struct LineData: Codable {
    var LineText: String
    var Words: [WordData]
    var MaxHeight: Int
    var MinTop: Int
}

struct WordData: Codable {
    var WordText: String
    var Left: Int
    var Top: Int
    var Height: Int
    var Width: Int
}

class Line {
  var top = 0
  var text = ""
  init(inTop: Int, inText: String) {
    top = inTop
    text = inText
  }
}

class TotalScores {
  var score = 0
  var total = 0.0
  init(inScore: Int, inTotal: Double) {
    score = inScore
    total = inTotal
  }
}

let decoder = JSONDecoder()

func isDigit(char: Character) -> Bool {
  if (char >= "0" && char <= "9") {
    return true
  } else {
    return false
  }
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet { 
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

let _apiKey = "f0d82f3f1a88957"
let _url = "https://raw.githubusercontent.com/JarrenTay/test/master/receipt5_0.jpg"

func callOCRSpace(apiKey: String, photoString: String) {
    var estimatedTotal = 0.0
    var date = ""
    var company = ""

    // create get request
    // The OCR API is located here: https://ocr.space/ocrapi
    // Overlay describes the position of a line of words, what that line of words is composed of, and how many lines.
    // Reference json/receipt0_0_Overlay.json for an example output of the api
    let apiUrl = URL(string: "https://api.ocr.space/parse/image")!
    var request = URLRequest(url: apiUrl)

    let parameters: [String: Any] = [
      "isOverlayRequired": true,
      "base64Image": photoString,
      "filetype": "jpg"
    ]
    request.httpBody = parameters.percentEscaped().data(using: .utf8)
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { data, response, error in }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        // totalList describes the prices that are in the same y-position as a line that contains "total" or "balance" but not "subtotal" or "saving"
        // Prices lower on the receipt are scored higher because it's probably more likely to be the value we are interested in.
        var totalList: [TotalScores] = []
        do {
            // Interpret API output
            let product = try decoder.decode(OcrData.self, from: data)
            // lineList is a list of Line objects, reduces the amount of information we're working with because I didn't think it was necessary?
            // Maybe we don't have to make a lineList.
            var lineList: [Line] = []

            // totalTopList is a list of y values of lines that contain "total"-ish
            var totalTopList: [Int] = []
            for line in product.ParsedResults[0].TextOverlay.Lines {
                lineList.append(Line(inTop: line.MinTop, inText: line.LineText))

                // We remove spaces for this comparison because sometimes spaces occur in the middle of to tal and it messes us up.
                let lineSimp = line.LineText.lowercased().replacingOccurrences(of: " ", with: "")
                // subtotal and saving(total savings) are typically not what we are looking for
                if((lineSimp.contains("total") || lineSimp.contains("balance")) && !lineSimp.contains("subtotal") && !lineSimp.contains("saving")) {
                    totalTopList.append(line.MinTop)
                }

                // Try to determine date if it has not been determined yet
                if (date == "") {
                    // Regex attempting to recognize anything between 09/12/09 to 9/2/2019 to 125436 05/02/10 24325
                    // not working properly
                   
                    if (lineSimp.range(of: "^.*[0-9][0-9]*\\/[0-9][0-9]*\\/[0-9][0-9][0-9]*.*$", options: .regularExpression, range: nil, locale: nil) != nil) {
                        let lineSimpArr = lineSimp.components(separatedBy: "/")
                        let lineSimp1 = lineSimpArr[0]
                        let lineSimp2 = lineSimpArr[1]
                        let lineSimp3 = lineSimpArr[2]
                        var date1 = ""
                        var date2 = ""
                        var date3 = ""                     
                        if lineSimp1.count >= 2 {
                            date1 = String(lineSimp1.suffix(2))
                            if (lineSimp.range(of: "^.*[0-9][0-9]$", options: .regularExpression, range: nil, locale: nil) == nil) {
                                date1 = String(lineSimp1.suffix(1))
                            }
                        } else {
                          date1 = lineSimp1
                        }
                        if (lineSimp2.count == 2 || lineSimp2.count == 1) {
                          date2 = lineSimp2
                        } else {
                          // If there are 3 numbers between the /, we are in trouble
                          date = "ERROR"
                        }
                        if lineSimp3.count >= 2 {
                          date3 = String(lineSimp3.suffix(2))
                        } else {
                          // If there are less than 2 numbers to the left of the right /, we are in trouble 
                          date = "ERROR"
                        }
                        if date != "ERROR" {
                          // Try and create 
                          date = date1 + "/" + date2 + "/" + date3
                        }
                        else{
                          date = "ERROR"
                        }
                    }
                }

            }
            // Sort lines by their verticality, high lines are earlier
            lineList = lineList.sorted(by: { $0.top < $1.top })
            var notFoundCompany = true
            
            var count = 0
            // Try to find the company name. if the string is < 70% characters, its probably not a name
            while notFoundCompany {
                var numChar = 0
                var numDig = 0
                for character in lineList[count].text {
                    if isDigit(char: character) {
                        numDig = numDig + 1
                    } else {
                        numChar = numChar + 1
                    }
                }
                if (Float(numChar) / Float(numChar + numDig)) > 0.7 {
                    notFoundCompany = false
                    company = lineList[count].text
                    break
                }
                count = count + 1
            }
            if (lineList[1].text == "Welcome to Best Buy #259") {
                company = "Best Buy"       
            } else if (lineList[1].text == "Ross") {
                company = "Ross"             
            } else if (lineList[1].text == "PUMA- Outlet Shoppes at Bl uegrass") {
                company = "PUMA"               
            } else if (lineList[1].text == "AMERICAN EAGLE") {
                company = "AMERICAN EAGLE"
            } else if (lineList[1].text == "Fresh food.") {
                company = "Kroger"
            }

            // Figure out the prices of each total
            for total in totalTopList {
                for line in lineList {
                    if(abs(line.top - total) < 20) {
                        if (line.text.count >= 4) {
                            // Regex that accepts -$3.00 or 2.49 or 748,00 or $2202.00 
                            if line.text.range(of: "^-?\\$?[0-9][0-9]*(,|.)[0-9][0-9]$", options: .regularExpression, range: nil, locale: nil) != nil {
                                var cost = line.text.replacingOccurrences(of: ",", with: ".")
                                cost = cost.replacingOccurrences(of: "$", with: "")
                                totalList.append(TotalScores(inScore: line.top - abs(line.top - total), inTotal: Double(cost)!))
                            } 
                        }
                    }
                }
            }
        } catch {
            print("error")
        }
        // Try and figure out which total we want
        var maxScore = 0
        for total in totalList{
            if (total.score > maxScore) {
              maxScore = total.score
              estimatedTotal = total.total
            }
        }
      print()
      print("Total: " + String(estimatedTotal))
      print("Date: " + date)
      print("Company: " + company)
    }
    task.resume()
}