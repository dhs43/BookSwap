//
//  EditListingViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/14/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditListingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let bookToSell = Book()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var editionTextField: UITextField!
    @IBOutlet weak var conditionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    var selectedDepartment: String?
    var selectedCourse: String?
    var selectedCondition: String?
    
    let departmentPicker = UIPickerView()
    let coursePicker = UIPickerView()
    let conditionsPicker = UIPickerView()
    
    let conditions = ["",
                      "Excellent",
                      "Good",
                      "Poor",
                      "Damaged"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = selectedBook.title
        authorTextField.text = selectedBook.author
        editionTextField.text = selectedBook.edition
        conditionTextField.text = selectedBook.condition
        priceTextField.text = "\(selectedBook.price!)"
        
        selectedBook = Book()
        
        addKeyboardDoneButton()
        createPicker(myPicker: conditionsPicker, textField: conditionTextField)
        
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        //stop listening for keyboard events
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    //create toolbar w/ done button
    func addKeyboardDoneButton() {
        let keyboardToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditListingViewController.dismissKeyboard))]
        keyboardToolbar.sizeToFit()
        titleTextField.inputAccessoryView = keyboardToolbar
        authorTextField.inputAccessoryView = keyboardToolbar
        editionTextField.inputAccessoryView = keyboardToolbar
        priceTextField.inputAccessoryView = keyboardToolbar
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var activeTextField = titleTextField
        
        if authorTextField.isEditing { activeTextField = authorTextField }
        else if editionTextField.isEditing { activeTextField = editionTextField }
        else if conditionTextField.isEditing { activeTextField = conditionTextField }
        else if priceTextField.isEditing { activeTextField = priceTextField }
        
        //if the keyboard would be above the textfield (plus 10pts of padding)
        if activeTextField!.frame.maxY + 10 > UIScreen.main.bounds.height - keyboardRect.height {
            if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame {
                
                //move origin up by the amount the keyboard would cover the textfield
                view.frame.origin.y = -(activeTextField!.frame.maxY - keyboardRect.height)
            }else{
                view.frame.origin.y = 0
            }
            //if user selects another textfield and view was previously moved, reset to 0
        }else if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPicker(myPicker: UIPickerView, textField: UITextField) {
        //create picker
        myPicker.delegate = self
        textField.inputView = myPicker
        
        //create toolbar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        //add done button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditListingViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolBar
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return conditions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return conditions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            selectedCondition = conditions[row]
            conditionTextField.text = selectedCondition
    }
    
    
    @IBAction func deleteListingPressed(_ sender: Any) {
        
        if selectedBook.isbn13 != nil {
            print(selectedListingKey)
            myDatabase.child("listings").child(selectedBook.isbn13!).child(selectedListingKey).removeValue()
            myDatabase.child("users").child(userID!).child("authoredListings").child(selectedBook.isbn13!).child(selectedListingKey).removeValue()
            SVProgressHUD.showSuccess(withStatus: "Listing deleted!")
            
        }else if selectedBook.isbn10 != nil {
            myDatabase.child("listings").child(selectedBook.isbn10!).child(selectedListingKey).removeValue()
            myDatabase.child("users").child(userID!).child("authoredListings").child(selectedBook.isbn10!).child(selectedListingKey).removeValue()
            SVProgressHUD.showSuccess(withStatus: "Listing deleted!")
            
        }else{
            SVProgressHUD.showError(withStatus: "Error: Listing not found")
        }
        
        //return to previous view controller
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        if titleTextField.text?.isEmpty == true {
            SVProgressHUD.showError(withStatus: "Please enter a title")
            return
        }
        if authorTextField.text?.isEmpty == true {
            SVProgressHUD.showError(withStatus: "Please enter an author")
            return
        }
        if editionTextField.text?.isEmpty == true {
            editionTextField.text = "1"
        }
        if selectedCondition?.isEmpty == true {
            SVProgressHUD.showError(withStatus: "Please select the books condition")
            return
        }
        if priceTextField.text?.isEmpty == false {
            if Int(priceTextField.text!) == nil {
                SVProgressHUD.showError(withStatus: "Please enter an integer for the price.")
                return
            }
        }else{
            SVProgressHUD.showError(withStatus: "Please enter an asking price")
            return
        }
        
        
        if selectedBook.isbn13 != nil {
            print(selectedListingKey)
            let bookRef = myDatabase.child("listings").child(selectedBook.isbn13!).child(selectedListingKey)
            
            bookRef.child("title").setValue(titleTextField.text!)
            bookRef.child("author").setValue(authorTextField.text!)
            bookRef.child("condition").setValue(conditionTextField.text!)
            bookRef.child("price").setValue(Int(priceTextField.text!))
            
            SVProgressHUD.showSuccess(withStatus: "Listing updated!")
            
        }else if selectedBook.isbn10 != nil {
            let bookRef = myDatabase.child("listings").child(selectedBook.isbn10!).child(selectedListingKey)
            
            bookRef.child("title").setValue(titleTextField.text!)
            bookRef.child("author").setValue(authorTextField.text!)
            bookRef.child("condition").setValue(conditionTextField.text!)
            bookRef.child("price").setValue(Int(priceTextField.text!))
            
            SVProgressHUD.showSuccess(withStatus: "Listing updated!")
        }else{
            SVProgressHUD.showError(withStatus: "Error: Listing not found")
        }
        
        //return to previous view controller
        navigationController?.popToRootViewController(animated: true)
    }
}





