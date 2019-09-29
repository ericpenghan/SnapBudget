import Foundation

// Don't change the API key
let apiKey = "f0d82f3f1a88957"
// There are receipt0_0.jpg to receipt5_0.jpg. receipt2_0.jpg is the asian market that does not work well.
let url = "https://raw.githubusercontent.com/JarrenTay/test/master/receipt5_0.jpg"

let receiptData = callOCRSpace(apiKey: apiKey, photoString: url /*Online swift does not allow us to make a base 64 image*/, urlNot64: true)
print(receiptData)
