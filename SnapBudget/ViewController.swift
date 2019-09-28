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
