//
//  LoginViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/16/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    //username and password outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    
    
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
        
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
        SVProgressHUD.dismiss()
            
            if error != nil{
                print(error!)
                self.handleAuthError(error!)
                
                if error!._code == 17009{
                    self.resetPasswordButton.isHidden = false
                }
            }else{
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
                userID = Auth.auth().currentUser?.uid
            }
        }
    }
    
    //reset password
    @IBAction func resetPasswordButton(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!){ error in
            
            if error != nil{
                self.handleAuthError(error!)
            }else{
                //alert user to check email for reset link
                let passwordResetAlert = UIAlertController(title: "Password Reset", message: "A password reset link has been sent to your email.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                passwordResetAlert.addAction(okAction)
            }
        }
    }
}
