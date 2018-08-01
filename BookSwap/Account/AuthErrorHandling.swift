//
//  AuthErrorHandling.swift
//  BookSwap
//
//  Created by David Shapiro on 7/18/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import Foundation
import FirebaseAuth

//error code to user-appropriate message
extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account"
        case .userNotFound:
            return "Email not associated with a user"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Incorrect password"
        case .missingEmail:
            return "Please enter an email address"
        default:
            return "Unknown error occurred"
        }
    }
}

//create alert with error message
extension UIViewController{
    func handleAuthError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //create username error alert
    func enterUsernameAlert() {
        let alert = UIAlertController(title: "Error", message: "Please enter a username", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
