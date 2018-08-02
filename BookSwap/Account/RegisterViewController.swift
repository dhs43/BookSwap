//
//  RegisterViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/16/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


//Username
let userID = Auth.auth().currentUser?.uid

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //registration
    @IBAction func registerPressed(_ sender: Any) {
        
        //require a username
        if self.usernameTextField.text == "Name" || self.usernameTextField.text == "" {
            enterUsernameAlert()
            return
        }
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
        SVProgressHUD.dismiss()
            
            if error != nil{
                print(error!)
                self.handleAuthError(error!)
            }else{
                print("Registration Successful")
                
                self.performSegue(withIdentifier: "registrationSuccess", sender: self)
            
                self.saveProfile(username: self.usernameTextField.text!, email: self.emailTextField.text!)
            }
        }
    }
    
    //save username and email
    func saveProfile(username: String, email: String) {
        
        let userObject = [
            "username":username,
            "email":email
            ] as [String:String]
        
        myDatabase.child("users").child(userID!).setValue(["userData":userObject])
    }
}
