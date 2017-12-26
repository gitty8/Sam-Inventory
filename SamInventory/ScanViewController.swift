//
//  ScanViewController.swift
//  SamInventory
//
//  Created by Praveen Samuel . J on 09/12/17.
//  Copyright © 2017 Praveen Samuel . J. All rights reserved.
//

import UIKit
import BarcodeScanner
import Firebase
import FirebaseDatabase
import SystemConfiguration

extension ScanViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        submit.isEnabled = true
        Database.database().reference().child("products").child("\(code)").observe(.value) { (snapshot : DataSnapshot) in
           if (snapshot.exists()){
                self.barcodeDetails.text = snapshot.key
            
            Database.database().reference().child("products").child(code).child("Name").observe(.value) { (snapshot : DataSnapshot) in
                if (snapshot.exists()){
                    self.name.text = snapshot.value as? String

                    Database.database().reference().child("products").child(code).child("Price").observe(.value) { (snapshot : DataSnapshot) in
                        if (snapshot.exists()){
                            self.price.text = snapshot.value as? String
                            
            }
        }
    }
}
    }else{
                self.barcodeDetails.text = "\(code)"
            }
       }
        let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

extension ScanViewController: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension ScanViewController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

class ScanViewController: UIViewController , UITextFieldDelegate {
    var count:Int!
    var namebar:String!, pricebar:String!, barcodebar:String!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var price: UITextField!
    
    @IBOutlet weak var barcodeDetails: UITextField!
    
    @IBOutlet weak var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.delegate = self
        self.price.delegate = self
        self.barcodeDetails.delegate = self
        submit.isEnabled = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch  {
            let alert = UIAlertController(title: "Problem in LogOut" , message: "Please check your internet connection.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
            alert.view.tintColor = UIColor.red
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if (name.text != "" && barcodeDetails.text != "" && price.text != ""){
            namebar = self.name.text!
            barcodebar = self.barcodeDetails.text!
            pricebar = self.price.text!
            store()
            self.view.endEditing(true)
            self.barcodeDetails.text = ""
            self.name.text = ""
            self.price.text = ""
            submit.isEnabled = false
        }else{
            let alert = UIAlertController(title: "Submit" , message: "Barcode, Name or Price field can't be blank.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(action)
            
            alert.view.tintColor = UIColor.red
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func nameTapped(_ sender: Any) {
        if name.text != "" {
            submit.isEnabled = true
        }else{
            submit.isEnabled = false
        }
    }
    
    @IBAction func priceTapped(_ sender: Any) {
        if price.text != "" {
            submit.isEnabled = true
        }else{
            submit.isEnabled = false
        }
    }
    
    @IBAction func barcodeTapped(_ sender: Any) {
        if barcodeDetails.text != "" {
            submit.isEnabled = true
        }else{
            submit.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name{
            price.becomeFirstResponder()
        }
        else{
            price.resignFirstResponder()
        }
        return true
    }
    @IBAction func barcodeImageButtonTapped(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.dismissalDelegate = self
        controller.errorDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func store(){
        //add barcode
        
            Database.database().reference().child("products").child(barcodebar)
        //add name
        Database.database().reference().child("products").child(barcodebar).child("Name").setValue(namebar)
        //add price
        Database.database().reference().child("products").child(barcodebar).child("Price").setValue(pricebar)
        //increament count
        Database.database().reference().child("products").child(barcodebar).child("Count").observeSingleEvent(of: .value, with: { (snapshot : DataSnapshot) in
            if (snapshot.exists()){
                let valString = snapshot.value as! String
                var value = Int(valString)
                value = value! + 1
                if snapshot.value != nil{
                    self.updateValue(val: value!)
                }
            }else{
            Database.database().reference().child("products").child(self.barcodebar).child("Count").setValue("1")
                self.view.endEditing(true)
                self.submit.isEnabled = false
            }
        }
    )}
    func updateValue(val: Int){
        //increament count
        
        Database.database().reference().child("products").child(barcodebar).child("Count").setValue("\(val)")
    }
}
