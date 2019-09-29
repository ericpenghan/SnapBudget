//
//  ViewController.swift
//  SnapBudget
//
//  Created by Eric Han on 9/27/19.
//  Copyright © 2019 Eric Han. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase

//1-design the nw cell in storyboard
//2-create a subclass for the new cell
//3-





//make it global, so all storyboard can access to it 
private var imagePicker: UIImagePickerController!




class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {//last 2 UI classes will let you take pic and use the data

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    //create a reference for data base
//    let ref = Database.database().reference()
//    ref.child("someid/name").setValue("Mike")
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped(gesture:)))
    
    // add it to the image view;
    receipt1.addGestureRecognizer(tapGesture)
     receipt2.addGestureRecognizer(tapGesture)
     receipt3.addGestureRecognizer(tapGesture)
     Receipt4.addGestureRecognizer(tapGesture)
     Receipt5.addGestureRecognizer(tapGesture)
    // make sure imageView can be interacted with by user
    receipt1.isUserInteractionEnabled = true
    receipt2.isUserInteractionEnabled = true
    receipt3.isUserInteractionEnabled = true
    Receipt4.isUserInteractionEnabled = true
    Receipt5.isUserInteractionEnabled = true
  }
  
  @IBOutlet weak var receipt1: UIImageView!
  @IBOutlet weak var receipt2: UIImageView!
  @IBOutlet weak var receipt3: UIImageView!
  @IBOutlet weak var Receipt4: UIImageView!
  @IBOutlet weak var Receipt5: UIImageView!
  @IBOutlet weak var Detail1: UILabel!
  @IBOutlet weak var detail2: UILabel!
  @IBOutlet weak var detail3: UILabel!
  @IBOutlet weak var detail4: UILabel!
  @IBOutlet weak var detail5: UILabel!
  
  var count = 0
  var url1 = ""
  var url2 = ""
  var url3 = ""
  var url4 = ""
  var url5 = ""
  
  @objc func imageTapped(gesture: UIGestureRecognizer) {
    // if the tapped view is a UIImageView then set it to imageview
    if (gesture.view as? UIImageView) != nil {
     
      //Here you can initiate your new ViewController
      
    }
  }
  
  @IBAction func pic1(_ sender: Any) {
    if let url = URL(string : self.url1){
    UIApplication.shared.open(url)
    }
  }
  @IBAction func pic2(_ sender: Any) {
    if let url = URL(string : self.url2){
      UIApplication.shared.open(url)
    }
  }
  @IBAction func pic3(_ sender: Any) {
    if let url = URL(string : self.url3){
      UIApplication.shared.open(url)
    }
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
    
    
    //Use image name from bundle to create NSData
    let image : UIImage? = info[.originalImage] as? UIImage
   
    
    //random will create a random name for each uploaded pic
    let randomId = UUID.init().uuidString
    //create an reference
    let uploadRef = Storage.storage().reference(withPath: "memes/\(randomId).jpg")
    //create a object
    guard let imageData = image?.jpegData(compressionQuality: 0.3) else
    { return }
  
    //create megadata to specify the content type to jpak
    let uploadMetadata = StorageMetadata.init()
    uploadMetadata.contentType = "image/jpeg"
    //start uplaoding file
       var imageUrl = ""
    uploadRef.putData(imageData, metadata: uploadMetadata){ (downloadMetadata, error) in
      imageUrl = imageUrl + downloadMetadata!.bucket + downloadMetadata!.name!
    
      print(imageUrl)
      uploadRef.downloadURL(completion: { (URL
        , Error) in
        print("your download url is: \(URL!.absoluteString)")
        imageUrl = URL!.absoluteString
        
        
        let receiptData = callOCRSpace(apiKey: "f0d82f3f1888957", photoString: imageUrl, urlNot64: true)
        print(receiptData)
        
 
        
        //ref = Database.database().reference()
        //write everthing into database
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        let rDate = receiptData.date == nil ? "No data" : receiptData.date!
        
        let rComp = receiptData.company == nil ? "PLEASE EDIT" : receiptData.company!
        ref.child("Receipt").childByAutoId().setValue(["company": rComp, "cost": receiptData.cost, "date": rDate, "url": imageUrl])
        var txt = rComp + " " + rDate + " "
        txt = txt + String(receiptData.cost)
        if(self.count == 0){
          self.receipt1.image = info[.originalImage] as? UIImage
          self.Detail1.text = txt
          self.url1 = imageUrl
        }
        if(self.count == 1){
          self.receipt2.image = info[.originalImage] as? UIImage
          self.detail2.text = txt
          self.url2 = imageUrl
          
        }
        if(self.count == 2){
          self.receipt3.image = info[.originalImage] as? UIImage
          self.detail3.text = txt
          self.url3 = imageUrl
        }
        if(self.count == 3){
          self.Receipt4.image = info[.originalImage] as? UIImage
          self.detail4.text = txt
          self.url4 = imageUrl
        }
        if(self.count == 4){
          self.Receipt5.image = info[.originalImage] as? UIImage
          self.detail5.text = txt
          self.url5 = imageUrl
        }
        self.count = self.count + 1
       
        
        
        
        self.dismiss(animated: true, completion: nil)
      })
    }
    

  }
}





