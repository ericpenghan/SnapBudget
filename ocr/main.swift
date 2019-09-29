import Foundation

// Don't change the API key
let apiKey = "f0d82f3f1a88957"
// There are receipt0_0.jpg to receipt5_0.jpg. receipt2_0.jpg is the asian market that does not work well.
let url = "https://raw.githubusercontent.com/JarrenTay/test/master/receipt5_0.jpg"

callOCRSpace(apiKey: apiKey, photoString: url /*Online swift does not allow us to make a base 64 image*/, urlNot64: true)
print("hmmm")
let seconds = 30.0
while(true){
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      // Put your code which should be executed with a delay here
      print("V")
  }
}