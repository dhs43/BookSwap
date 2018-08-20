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
    
    var departments = ["",
                       "N/A"]
    
    var courses = ["",
                   "N/A"]
    
    let conditions = ["",
                      "Excellent",
                      "Good",
                      "Poor",
                      "Damaged"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetching department list
        myDatabase.child("departments").observeSingleEvent(of: .value) { (snapshot) in
            self.departments.removeAll()
            if let myData = snapshot.value as? NSDictionary {
                for name in myData.keyEnumerator() {
                    self.departments.append("\(name)")
                    self.departments = self.departments.sorted()
                }
            }
            self.departments.insert("", at: 0)
        }
        
    
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
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var activeTextField = titleTextField
        
        if authorTextField.isEditing { activeTextField = authorTextField }
        else if editionTextField.isEditing { activeTextField = editionTextField }
        else if departmentTextField.isEditing { activeTextField = departmentTextField }
        else if courseTextField.isEditing { activeTextField = courseTextField }
        else if conditionTextField.isEditing { activeTextField = conditionTextField }
        else if isbnTextField.isEditing { activeTextField = isbnTextField }
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
            
            if selectedDepartment != "" && selectedDepartment != "- Other -" {
                myDatabase.child("departments").child("\(selectedDepartment ?? "AHSS")").observeSingleEvent(of: .value) { (snapshot) in
                    
                    //fills in coursePickerView with selected department's courses
                    self.courses.removeAll()
                    self.courses.append("")
                    self.courses.append("N/A")
                    if let myData = snapshot.value as? NSDictionary {
                        
                        var stringList: [String] = [""]
                        var intList: [Int] = [0]
                        stringList.removeAll()
                        intList.removeAll()
                        
                        for name in myData.keyEnumerator() {
                            stringList.append("\(name)")
                        }
                        
                        for string in stringList {
                            intList.append(Int(string)!)
                        }
                        stringList = stringList.sorted()
                        for course in stringList {
                            self.courses.append("\(course)")
                        }
                        
                    }
                }
            }else{
                courses.removeAll()
                courses.append("")
                courses.append("N/A")
            }
            
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
            if Int(editionTextField.text!) != nil {
                bookToSell.edition = editionTextField.text!
            }else{
                SVProgressHUD.showError(withStatus: "Please enter an integer for the edition.")
                return
            }
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
            if Int(priceTextField.text!) != nil {
                bookToSell.price = Int(priceTextField.text!)
            }else{
                SVProgressHUD.showError(withStatus: "Please enter an integer for the price.")
                return
            }
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
        
        var defaultIsbn: String
        if bookToSell.isbn13 != "isbn13" {
            defaultIsbn = bookToSell.isbn13!
        }else if bookToSell.isbn10 != "isbn10" {
            defaultIsbn = bookToSell.isbn10!
        }else{
            SVProgressHUD.showError(withStatus: "Invalid ISBNs")
            return
        }
        
        //post to listings
        let ref = myDatabase.child("listings").child(defaultIsbn).childByAutoId()
        let key = ref.key
        ref.setValue(bookObject)
        
        //post ISBN to courses
        if bookToSell.department == "- Other -" {
            myDatabase.child("departments").child("- Other -").child(defaultIsbn).setValue(defaultIsbn)
        }else{
            myDatabase.child("departments").child(bookToSell.department!).child(bookToSell.course!).child(defaultIsbn).setValue(defaultIsbn)
        }
        
        //add to list of books for sale by user
        myDatabase.child("users").child(userID!).child("authoredListings").child(defaultIsbn).child(key).setValue(key)
        print(key)
        
        //notify user when book is listed
        SVProgressHUD.showSuccess(withStatus: "Your textbook has been listed for sale")
        
        //return to previous view controller
        navigationController?.popToRootViewController(animated: true)
    }
}







