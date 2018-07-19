//
//  LoginViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/16/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    //username and password outlets
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

    //user login
    @IBAction func loginPressed(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil{
                print(error!)
                self.handleAuthError(error!)
            }else{
                print("Login Successful")
                
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
            }
        }
    }
}
