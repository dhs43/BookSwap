//
//  AccountViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/18/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AccountViewController: UIViewController {

    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var emailTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextLabel.layer.masksToBounds = true
        emailTextLabel.layer.cornerRadius = 5.0;
        emailTextLabel.isHidden = true
        
        //unique userID
        userID = Auth.auth().currentUser?.uid
        displayUsername()
    }
    
    func displayUsername() {
        //display username on account page
        var username = usernameTextLabel.text
        myDatabase.child("users").child(userID!).child("userData").observeSingleEvent(of: .value) { (snapshot) in
            let profileData = snapshot.value as! [String: Any]
            username = profileData["username"] as? String
            
            self.usernameTextLabel.text = ("Welcome, \(username!)!")
            self.usernameTextLabel.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //allow user to email bugs or questions
    @IBAction func reportBugButtonPressed(_ sender: Any) {
        emailTextLabel.isHidden = false
        let email = "HSU.Bookswap@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            }else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //edit username
    @IBAction func editUsername(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Edit Username", message:"", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
            //getting the input values from user
            let username = alertController.textFields?[0].text
            
            myDatabase.child("users").child(userID!).child("userData").child("username").setValue(username!)
            self.displayUsername()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //logout
    @IBAction func logOutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            //switch back to login page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "appStart")
            self.present(signInVC, animated: true, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
        }
    }
}
