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
        var username = usernameTextLabel.text
        
        //unique userID
        userID = Auth.auth().currentUser?.uid
        //display username on account page
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
