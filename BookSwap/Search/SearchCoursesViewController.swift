//
//  SearchCoursesViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/9/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SearchCoursesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var listings = [Book]()
    
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDepartment: String?
    var selectedCourse: String?
    
    let departmentPicker = UIPickerView()
    let coursePicker = UIPickerView()
    
    
    var departments = ["",
                       "N/A"]
    
    var courses = ["",
                   "N/A"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //fetching department list
        SVProgressHUD.show(withStatus: "Fetching data")
        departments.removeAll()
        myDatabase.child("departments").observeSingleEvent(of: .value) { (snapshot) in
            if let myData = snapshot.value as? NSDictionary {
                for name in myData.keyEnumerator() {
                    self.departments.append("\(name)")
                }
                self.departments = self.departments.sorted()
                self.departments.insert("", at: 0)
                
                SVProgressHUD.dismiss()
            }else{
                SVProgressHUD.dismiss()
            }
        }
        

        createPicker(myPicker: departmentPicker, textField: departmentTextField)
        createPicker(myPicker: coursePicker, textField: courseTextField)
    }
    
    //search using department and course from picker views
    func searchByCourse(department: String, course: String) {
        
        var isbnArray: [String] = [""]
        isbnArray.removeAll()
        listings.removeAll()
        
        if courseTextField.text == "All" {
            //get isbns associated with course
            myDatabase.child("departments").child("\(department)").observeSingleEvent(of: .value) { (snapshot) in
                if let data = snapshot.value as? NSDictionary {
                    for isbn in data.keyEnumerator() {
                        if isbn as? String != "placeholder"{
                            isbnArray.append("\(isbn)")
                        }
                    }
                }
                
                //show each book associated with isbns
                for isbn in isbnArray {
                    
                    let listingsRef = myDatabase.child("listings").child(isbn)
                    
                    var bookCounter = 0
                    
                    listingsRef.observeSingleEvent(of: .value) { (snapshot) in
                        for child in snapshot.children {
                            
                            bookCounter += 1
                            
                            //to get only the first book for each isbn
                            //apparently snapshot.children[0] doesn't work
                            if bookCounter == 1 {
                                
                                let data = child as! DataSnapshot //each listing
                                let bookData = data.value as! [String: Any]
                                
                                let book = Book()
                                book.title = bookData["title"] as? String
                                book.author = bookData["author"] as? String
                                book.isbn13 = bookData["isbn13"] as? String
                                book.isbn10 = bookData["isbn10"] as? String
                                book.imageURL = bookData["imageURL"] as? String
                                book.edition = bookData["edition"] as? String
                                book.condition = bookData["condition"] as? String
                                book.department = bookData["department"] as? String
                                book.course = bookData["course"] as? String
                                book.listedBy = bookData["listedBy"] as? String
                                
                                self.listings.append(book)
                                DispatchQueue.main.async { self.tableView.reloadData() }
                            }
                        }
                    }
                }
            }
        }else{
            
            //get isbns associated with course
            myDatabase.child("departments").child("\(department)").child("\(course)").observeSingleEvent(of: .value) { (snapshot) in
                if let data = snapshot.value as? NSDictionary {
                    for isbn in data.keyEnumerator() {
                        if isbn as? String != "placeholder"{
                            isbnArray.append("\(isbn)")
                        }
                    }
                }
                
                //show each book associated with isbns
                for isbn in isbnArray {
                    
                    let listingsRef = myDatabase.child("listings").child(isbn)
                    
                    var bookCounter = 0
                    
                    listingsRef.observeSingleEvent(of: .value) { (snapshot) in
                        for child in snapshot.children {
                            
                            bookCounter += 1
                            
                            //to get only the first book for each isbn
                            //apparently snapshot.children[0] doesn't work
                            if bookCounter == 1 {
                                
                                let data = child as! DataSnapshot //each listing
                                let bookData = data.value as! [String: Any]
                                
                                let book = Book()
                                book.title = bookData["title"] as? String
                                book.author = bookData["author"] as? String
                                book.isbn13 = bookData["isbn13"] as? String
                                book.isbn10 = bookData["isbn10"] as? String
                                book.imageURL = bookData["imageURL"] as? String
                                book.edition = bookData["edition"] as? String
                                book.condition = bookData["condition"] as? String
                                book.department = bookData["department"] as? String
                                book.course = bookData["course"] as? String
                                book.listedBy = bookData["listedBy"] as? String
                                
                                self.listings.append(book)
                                DispatchQueue.main.async { self.tableView.reloadData() }
                            }
                        }
                    }
                }
            }
        }
    }

    //create picker views
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
        }else{
            return courses.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == departmentPicker {
            return departments[row]
        }else{
            return courses[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == departmentPicker {
            selectedDepartment = departments[row]
            
            if selectedDepartment != "- Other -" {
                courseTextField.text = ""
            }else{
                selectedCourse = "All"
            }
            
            if selectedDepartment != "" {
                
                departmentTextField.text = selectedDepartment
                
                myDatabase.child("departments").child("\(selectedDepartment ?? "AHSS")").observeSingleEvent(of: .value) { (snapshot) in
                    
                    if self.selectedDepartment != "- Other -" {
                        
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
                    }else{
                        self.courses.removeAll()
                        self.courseTextField.text = "All"
                        self.courses.append("All")
                    }
                }
            }
            
        }else{
            selectedCourse = courses[row]
            courseTextField.text = selectedCourse
        }
    }
    
    //trigger search
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        if selectedDepartment != nil && selectedCourse != nil {
            self.searchByCourse(department: self.selectedDepartment!, course: self.selectedCourse!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension SearchCoursesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("BookItemTableViewCell", owner: self, options: nil)?.first as! BookItemTableViewCell
        
        //title
        if listings[indexPath.row].title != nil {
            cell.titleLabel.text = listings[indexPath.row].title
        }else{
            cell.titleLabel.text = "(Title Unknown)"
        }
        //author
        if listings[indexPath.row].author != nil{
            cell.authorLabel.text = "Author: \(listings[indexPath.row].author!)"
        }else{
            cell.authorLabel.text = "Author Unknown"
        }
        //isbn
        if listings[indexPath.row].isbn13 != nil {
            cell.isbnLabel.text = "ISBN: \(listings[indexPath.row].isbn13!)"
        }else if listings[indexPath.row].isbn10 != nil{
            cell.isbnLabel.text = "ISBN: \(listings[indexPath.row].isbn10!)"
        }else{
            cell.isbnLabel.text = "ISBN Unknown"
        }
        
        //cover image
        if listings[indexPath.row].imageURL != nil && listings[indexPath.row].imageURL != "none" {
            let url = URL(string: listings[indexPath.row].imageURL!)
            //cache image using Kingfisher
            cell.bookCoverView.kf.setImage(with: url)
        }else{
            cell.bookCoverView.image = #imageLiteral(resourceName: "noCoverImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedBook = listings[indexPath.row]
        
        if selectedBook.isbn13 != nil {
            defaultISBN = selectedBook.isbn13!
        }else if selectedBook.isbn10 != nil {
            defaultISBN = selectedBook.isbn10!
        }
        
        performSegue(withIdentifier: "courseToDetails", sender: self)
    }
}









