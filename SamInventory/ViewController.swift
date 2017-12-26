//
//  ViewController.swift
//  SamInventory
//
//  Created by Praveen Samuel . J on 09/12/17.
//  Copyright © 2017 Praveen Samuel . J. All rights reserved.
//

import UIKit
import SystemConfiguration
import BarcodeScanner
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var signup: UIButton!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.errorMessage.isHidden = true
        self.email.delegate = self
        self.password.delegate = self
        signup.isEnabled = false
        login.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isInternetAvailable() {
            // internet there
        }else{
            let alert = UIAlertController(title: "No Internet" , message: "Turn on your mobile data or Wi-Fi to access data.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(action)
            
            alert.view.tintColor = UIColor.red
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    @IBAction func emailText(_ sender: Any) {
        if email.text != ""{
            signup.isEnabled = true
            login.isEnabled = true
        } else {
            signup.isEnabled = false
            login.isEnabled = false
        }
    }
    
    @IBAction func passwordText(_ sender: Any) {
        if password.text != "" {
            signup.isEnabled = true
            login.isEnabled = true
        } else {
            signup.isEnabled = false
            login.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == email{
            password.becomeFirstResponder()
        }
        else{
            password.resignFirstResponder()
        }
        return true
    }
    
    
    @IBAction func logInTapped(_ sender: Any) {
        if (email.text != "" && password.text != "") {
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                if error == nil{
                    self.view.endEditing(true)
                    self.errorMessage.text = "Logged In Successfully"
                    self.errorMessage.textColor = UIColor.green
                    self.view.endEditing(true)
                    self.errorMessage.isHidden = false
                    self.email.text = ""
                    self.password.text = ""
                    self.performSegue(withIdentifier: "signuptoscan", sender: nil)
                    self.signup.isEnabled = false
                    self.login.isEnabled = false
                    self.errorMessage.isHidden = true
                }else{
                    self.errorMessage.text = error?.localizedDescription
                    self.errorMessage.textColor = UIColor.red
                    self.errorMessage.isHidden = false
                    self.email.text = ""
                    self.password.text = ""
                }
            })
            
        }else{
            let alert = UIAlertController(title: "Sign Up" , message: "Email or Password field can't be blank.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(action)
            
            alert.view.tintColor = UIColor.red
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func SignUpTapped(_ sender: Any) {
        if (email.text != "" && password.text != "") {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: { (user, Error) in
            if Error != nil{
              //  print(Error!)
                self.errorMessage.text = Error?.localizedDescription
                self.errorMessage.textColor = UIColor.red
                self.errorMessage.isHidden = false
                self.email.text = ""
                self.password.text = ""
            }
            else {
              //  print("registration successful")
                self.view.endEditing(true)
                self.errorMessage.text = "User registration Success"
                self.errorMessage.textColor = UIColor.green
                self.errorMessage.isHidden = false
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                    if error == nil{
                        self.email.text = ""
                        self.password.text = ""
                        self.errorMessage.isHidden = true
                        self.view.endEditing(true)
                        self.performSegue(withIdentifier: "signuptoscan", sender: nil)
                        self.signup.isEnabled = false
                        self.login.isEnabled = false
                    }
                })
            }
        })
        }else{
            let alert = UIAlertController(title: "Sign Up" , message: "Email or Password field can't be blank.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(action)
            
            alert.view.tintColor = UIColor.red
            
            self.present(alert, animated: true, completion: nil)
        }
}
}
