import SwiftOCR

let swiftOCRInstance = SwiftOCR()
    
swiftOCRInstance.recognize(myImage) { recognizedString in
    print(recognizedString)
}