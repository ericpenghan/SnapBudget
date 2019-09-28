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

let _apiKey = "f0d82f3f1a88957"
let _url = "https://raw.githubusercontent.com/JarrenTay/test/master/receipt5_0.jpg"

func callOCRSpace(apiKey: String, url: String) {
    // prepare json data
    var estimatedTotal = 0.0
    var date = ""
    var company = ""

    // create get request
    let url = URL(string: "https://api.ocr.space/parse/imageurl?apikey=" + apiKey + "&url=" + url + "&isoverlayrequired=true")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        var totalList: [TotalScores] = []
        do {
            let product = try decoder.decode(OcrData.self, from: data)
            var lineList: [Line] = []
            var totalTopList: [Int] = []
            for line in product.ParsedResults[0].TextOverlay.Lines {
                lineList.append(Line(inTop: line.MinTop, inText: line.LineText))
                let lineSimp = line.LineText.lowercased().replacingOccurrences(of: " ", with: "")
                if((lineSimp.contains("total") || lineSimp.contains("balance")) && !lineSimp.contains("subtotal") && !lineSimp.contains("saving")) {
                    totalTopList.append(line.MinTop)
                }
                if (date == "") {
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
                          date = "ERROR"
                        }
                        if lineSimp3.count >= 2 {
                          date3 = String(lineSimp3.prefix(2))
                          if (lineSimp.range(of: "^[0-9][0-9].*$", options: .regularExpression, range: nil, locale: nil) == nil) {
                            date3 = String(lineSimp3.prefix(1))
                          }
                        } else {
                          date = "ERROR"
                        }
                        if date != "ERROR" {
                          date = date1 + "/" + date2 + "/" + date3
                        }
                    }
                }

            }
            print(totalTopList)
            lineList = lineList.sorted(by: { $0.top < $1.top })
            var notFoundCompany = true
            var count = 0
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
                print(Float(numChar) / Float(numChar + numDig))
                if (Float(numChar) / Float(numChar + numDig)) > 0.7 {
                    notFoundCompany = true
                    company = lineList[count].text
                    break
                }
                count = count + 1
            }

            for total in totalTopList {
                for line in lineList {
                    if(abs(line.top - total) < 20) {
                        if (line.text.count >= 4) {
                            if line.text.range(of: "^-?\\$?[0-9]+(,|.)[0-9][0-9]$", options: .regularExpression, range: nil, locale: nil) != nil {
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
        var maxScore = 0
        for total in totalList{
            if (total.score > maxScore) {
              maxScore = total.score
              estimatedTotal = total.total
            }
        }
      print("Total: " + String(estimatedTotal))
      print("Date: " + date)
      print("Company: " + company)
    }
    task.resume()
}