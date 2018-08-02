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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var username = usernameTextLabel.text
        
        //display username on account page
        myDatabase.child("users").child(userID!).child("userData").observeSingleEvent(of: .value) { (snapshot) in
            let profileData = snapshot.value as! [String: Any]
            username = profileData["username"] as? String
            
            self.usernameTextLabel.text = username
            self.usernameTextLabel.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
