//
//  RegisterViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/16/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

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
    
    @IBAction func registerPressed(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil{
                print(error!)
            }else{
                print("Registration Successful")
                
                self.performSegue(withIdentifier: "registrationSuccess", sender: self)
            }
        }
    }
}
