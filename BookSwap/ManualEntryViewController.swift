//
//  ManualEntryViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/30/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import SVProgressHUD

//global for data from keyword search selection
var selectedBook = Book()

class ManualEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let bookToSell = Book()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var editionTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var conditionTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    
    var selectedDepartment: String?
    var selectedCourse: String?
    var selectedCondition: String?
    
    let departmentPicker = UIPickerView()
    let coursePicker = UIPickerView()
    let conditionsPicker = UIPickerView()
    
    let departments = ["",
                       "N/A",
                       "CS",
                       "BIOL"]
    
    let courses = ["",
                   "N/A",
                   "101",
                   "102",
                   "103"]
    
    let conditions = ["",
                      "Excellent",
                      "Good",
                      "Poor",
                      "Damaged"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        addKeyboardDoneButton()
        createPicker(myPicker: departmentPicker, textField: departmentTextField)
        createPicker(myPicker: coursePicker, textField: courseTextField)
        createPicker(myPicker: conditionsPicker, textField: conditionTextField)
        
        //transfer data from selection in previous view
        if selectedBook.title != nil {
            titleTextField.text = selectedBook.title
            authorTextField.text = selectedBook.author
            isbnTextField.text = selectedBook.isbn13
            bookToSell.isbn10 = selectedBook.isbn10
            bookToSell.imageURL = selectedBook.imageURL
        }else{
            bookToSell.isbn10 = "isbn10"
            bookToSell.imageURL = "none"
        }
    }
    
    //create toolbar w/ done button
    func addKeyboardDoneButton() {
        let keyboardToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ManualEntryViewController.dismissKeyboard))]
        keyboardToolbar.sizeToFit()
        titleTextField.inputAccessoryView = keyboardToolbar
        authorTextField.inputAccessoryView = keyboardToolbar
        editionTextField.inputAccessoryView = keyboardToolbar
        priceTextField.inputAccessoryView = keyboardToolbar
        isbnTextField.inputAccessoryView = keyboardToolbar
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ManualEntryViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolBar
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == departmentPicker {
            return departments.count
        }else if pickerView == coursePicker {
            return courses.count
        }else{
            return conditions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == departmentPicker {
            return departments[row]
        }else if pickerView == coursePicker {
            return courses[row]
        }else{
            return conditions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == departmentPicker {
            selectedDepartment = departments[row]
            departmentTextField.text = selectedDepartment
        }else if pickerView == coursePicker {
            selectedCourse = courses[row]
            courseTextField.text = selectedCourse
        }else{
            selectedCondition = conditions[row]
            conditionTextField.text = selectedCondition
        }
    }
    
    //pressed sell
    @IBAction func sellPressed(_ sender: Any) {
        
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        if titleTextField.text?.isEmpty == false {
            bookToSell.title = titleTextField.text!
        }else{
            SVProgressHUD.showError(withStatus: "Please enter a title")
            return
        }
        if authorTextField.text?.isEmpty == false {
            bookToSell.author = authorTextField.text!
        }else{
            SVProgressHUD.showError(withStatus: "Please enter an author")
            return
        }
        if editionTextField.text?.isEmpty == false {
            bookToSell.edition = editionTextField.text!
        }else{
            bookToSell.edition = "1"
        }
        if selectedDepartment?.isEmpty == false {
            bookToSell.department = selectedDepartment!
        }else{
            SVProgressHUD.showError(withStatus: "Please select a department")
            return
        }
        if selectedCourse?.isEmpty == false {
            bookToSell.course = selectedCourse!
        }else{
            SVProgressHUD.showError(withStatus: "Please select a course")
            return
        }
        if selectedCondition?.isEmpty == false {
            bookToSell.condition = selectedCondition!
        }else{
            SVProgressHUD.showError(withStatus: "Please select the books condition")
            return
        }
        if isbnTextField.text?.isEmpty == false {
            bookToSell.isbn13 = isbnTextField.text!
        }else{
            SVProgressHUD.showError(withStatus: "Please enter an ISBN")
            return
        }
        if priceTextField.text?.isEmpty == false {
            bookToSell.price = Float(priceTextField.text!)!
        }else{
            SVProgressHUD.showError(withStatus: "Please enter an asking price")
            return
        }
        
        postListing(bookToSell: bookToSell)
    }
    
    //post data to firebase
    func postListing(bookToSell: Book) {
        
        let bookObject = [
            "title":bookToSell.title!,
            "author":bookToSell.author!,
            "isbn13":bookToSell.isbn13!,
            "isbn10":bookToSell.isbn10!,
            "edition":bookToSell.edition!,
            "department":bookToSell.department!,
            "course":bookToSell.course!,
            "condition":bookToSell.condition!,
            "price":bookToSell.price!,
            "imageURL":bookToSell.imageURL!,
            "listedBy":userID!
            ] as [String:Any]
        
        myDatabase.child("listings").child(bookToSell.isbn13!).childByAutoId().setValue(bookObject)
        
        //notify user when book is listed
        SVProgressHUD.showSuccess(withStatus: "Your textbook has been listed for sale")
        
        //return to previous view controller
        navigationController?.popToRootViewController(animated: true)
    }
}
