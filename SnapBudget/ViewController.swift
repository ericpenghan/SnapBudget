//
//  ViewController.swift
//  SnapBudget
//
//  Created by Eric Han on 9/27/19.
//  Copyright © 2019 Eric Han. All rights reserved.
//

import UIKit
import FirebaseDatabase
//make it global, so all storyboard can access to it 
private var imagePicker: UIImagePickerController!

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {//last 2 UI classes will let you take pic and use the data

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    //create a reference for data base
    let ref = Database.database().reference()
    
    ref.child("someid/name").setValue("Mike")
  }
  @IBOutlet weak var testoutputpic: UIImageView!
  
  
  //take a photo
  @IBAction func takePic(_ sender: Any) {
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self//make it control the whole class so it can control the camrea
    
    //if the camra is avaiavle then do these
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      imagePicker.sourceType = .camera
    }
    else{
      //if not set it to photolibiary
      imagePicker.sourceType = .photoLibrary
      print("not woreking")
    }
    imagePicker.allowsEditing = true//allow user to edit
    imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
    
    
    self.present(imagePicker, animated: true, completion: nil);//it will allow the user to see the camra
  }
  
 }




//acces to the pic taken
extension ViewController
{
  //if user cancel the camra
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
    print("user canceled the camera / photo library")
  }
  
  
  
  
  //if user taken the pic
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    self.testoutputpic.image = info[.originalImage] as? UIImage
    
    
    //Use image name from bundle to create NSData
    let image : UIImage = info[.originalImage] as! UIImage
    //Now use image to create into NSData format
    let strBase64:String = (image.jpegData(compressionQuality: 0.7)!).base64EncodedString(options: .lineLength64Characters)
    
    //let strBase64 = imageData.base64EncodedString(options: )
    
   
    
 
    var receiptData = callOCRSpace(apiKey: "f0d82f3f1888957", photoString: strBase64, urlNot64: false)
    print(receiptData)
  }
}





