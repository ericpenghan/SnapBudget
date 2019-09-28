import Foundation

let apiKey = "f0d82f3f1a88957"
let url = "https://raw.githubusercontent.com/JarrenTay/test/master/receipt5_0.jpg"

callOCRSpace(apiKey: apiKey, url: url)
print("hmmm")
let seconds = 30.0
while(true){
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      // Put your code which should be executed with a delay here
      print("V")
  }
}