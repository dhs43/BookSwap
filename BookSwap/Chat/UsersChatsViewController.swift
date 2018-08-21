//
//  UsersChatsViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/18/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase

var selectedChat = ""
var otherUser = ""

class UsersChatsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var chatIds = [String]()
    var otherUsers = [String]()
    var foundFirstUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reset badge app icon
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70

        myDatabase.child("users").child(userID!).child("userChats").observe(.value) { (snapshot) in
            for child in snapshot.children {
                let data = child as! DataSnapshot
                self.getOtherUsers(data: data.key)
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
        //set new messages to false
        myDatabase.child("users").child(userID!).child("hasNewMessages").setValue(false)
        //reset badge app icon
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
    }
    
    func getOtherUsers(data: String) {
        //store chat ID
        chatIds.append(data)
        
        //parse individual user IDs from chat ID
        var firstUser = ""
        var secondUser = ""
        for char in data {
            if self.foundFirstUser == false {
                if char != "-" {
                    firstUser.append(char)
                }else{
                    self.foundFirstUser = true
                }
            }else{
                secondUser.append(char)
            }
        }
        //find userID of other user
        if firstUser == userID {
            self.otherUsers.append(secondUser)
        }else{
            self.otherUsers.append(firstUser)
        }
        
        //reset
        firstUser.removeAll()
        secondUser.removeAll()
        self.foundFirstUser = false
    }
}


extension UsersChatsViewController: UITableViewDelegate,
UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ContactsTableViewCell", owner: self, options: nil)?.first as! ContactsTableViewCell
        
        myDatabase.child("users").child(otherUsers[indexPath.row]).child("userData").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let profileData = snapshot.value as! [String: Any]
            cell.contactLabel.text = profileData["username"] as? String
        })
        
        myDatabase.child("messages").child(chatIds[indexPath.row]).observe(.value) { (snapshot) in
            for child in snapshot.children
            {
                let data = child as! DataSnapshot
                let message = data.value as! [String: Any]
                if message["message"] as? String != "specificBookswapPlaceholder" {
                    cell.previewLabel.text = message["message"] as? String
                }else{
                    cell.previewLabel.text = ""
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedChat = chatIds[indexPath.row]
        otherUser = otherUsers[indexPath.row]
        performSegue(withIdentifier: "selectedChat", sender: self)
        
    }
}

















