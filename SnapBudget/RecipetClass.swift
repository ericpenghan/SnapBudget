////
////  RecipetClass.swift
////  SnapBudget
////
////  Created by Eric Han on 9/28/19.
////  Copyright © 2019 Eric Han. All rights reserved.
////
//
//import UIKit
//import FirebaseDatabase
//import FirebaseStorage
//import Firebase
//
//struct ReceiptDataPlus {
//  var company: String
//  var date: String
//  var cost: Double
//  var url: String
//  init (company: String = "", date: String = "", cost: Double = 0.0, url: String = "") {
//    self.company = company
//    self.date = date
//    self.cost = cost
//    self.url = url
//  }
//  func toString() -> String {
//    return (company + " " + date + " " + String(cost) + " " + url)
//  }
//}
//
//class ReceiptClass: UIViewController, UITableViewDataSource {
//
// 
// 
//  @IBOutlet weak var tableView: UITableView!
//  private var data: [String] = []
//  var databaseHandle : DatabaseHandle?
// 
//  var ref:DatabaseReference?
//  
//  override func viewDidLoad() {
//        super.viewDidLoad()
//    
//    //ref = Database.database().reference()
//    //write everthing into database
//    
//    //set reference
//    ref = Database.database().reference()
//    //retrieve the posts the listen for changes
//    var receiptData: [ReceiptDataPlus] = []
//    databaseHandle = ref?.child("Receipt").observe(.childAdded, with:{(snapshot) in
//      //take the value from snapshot add to data
//      if let value = snapshot.value as? [String: Any] {
//        let company = value["company"] as? String ?? ""
//        let cost = value["cost"] as? Double ?? 0.0
//        let URL = value["url"] as? String ?? ""
//        let date = value["date"] as? String ?? ""
//        let dt = ReceiptDataPlus(company: company, date: date, cost: cost, url: URL)
//        print(dt.toString())
//        receiptData.append(dt)
//      }
//      //receiptData.append(ReceiptDataPlus(company: "a", date: "a", cost: 1.0, url: "1"))
//    //  print(receiptData)
//      //let post = snapshot.value! as! String
//      //print(post)
//      //self.data.append(post)
//      
////
////      let name = snapshot.value as? String
////      print(name)
////      print(name)
//      
//    })
//    
//    for i in receiptData{
//      data.append("Receipt \(i.toString())")
//
////      data.append("Receipt \(i)")
//      
////
////    }
//    
//    tableView.dataSource = self
//      // Do any additional setup after loading the view.
//  }
//    print(data)
//  }
//  
//    
////num of section what does the cell looks like
//  func numberOfSections(in tableView: UITableView) -> Int{
//      return 1
//  }
//  
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//    return data.count
//  }
//  
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//    let cell = /*UITableViewCell(frame: CGRect.init(x: 2.0, y: 2.0, width: 2.0, height: 2.0)) */tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
//    
//  let text = data[indexPath.row]
//    
//    cell.textLabel?.text = text
//    return cell
//    
//  }
//
//  
//  
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
