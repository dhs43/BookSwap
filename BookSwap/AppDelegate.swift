//
//  AppDelegate.swift
//  BookSwap
//
//  Created by David Shapiro on 7/16/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import UserNotifications

let myDatabase = Database.database().reference()
var userID = Auth.auth().currentUser?.uid
var myUsername = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Firebase
        FirebaseApp.configure()
        
        //check if user is already logged in
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "signedIn")
                
                //setup user once they have logged in
                self.userSetup()
                
                print(user)
            } else {
                // No user is signed in. Directs to Login/Register view.
            }
        }
        
        //Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func userSetup() {
        //unique userID
        userID = Auth .auth().currentUser?.uid
        //username
        myDatabase.child("users").child(userID!).child("userData").child("username").observeSingleEvent(of: .value) { (snapshot) in
            myUsername = snapshot.value as! String
        }
        
        //set app-wide settings for progress indicators
        SVProgressHUD.setBorderColor(UIColor(red:0.72, green:0.69, blue:0.52, alpha:1.0))
        SVProgressHUD.setBorderWidth(1)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        
        //get app id token for notifications
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                myDatabase.child("users").child(userID!).child("userData").child("deviceToken").setValue(result.token)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

