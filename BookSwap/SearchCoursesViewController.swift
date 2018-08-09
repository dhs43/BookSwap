//
//  SearchCoursesViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/9/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit

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
        
        //fetching department list
        departments.removeAll()
        myDatabase.child("departments").observeSingleEvent(of: .value) { (snapshot) in
            if let myData = snapshot.value as? NSDictionary {
                for name in myData.keyEnumerator() {
                    self.departments.append("\(name)")
                }
                self.departments = self.departments.sorted()
                self.departments.insert("", at: 0)
            }
        }
        

        createPicker(myPicker: departmentPicker, textField: departmentTextField)
        createPicker(myPicker: coursePicker, textField: courseTextField)
    }
    
    
    func searchCourses(department: String, course: String) {
        myDatabase.child("departments").child(department).child(course).observeSingleEvent(of: .value) { (courseSnapshot) in
            if let data = courseSnapshot.value as? [String:String] {
                
                for value in data {
                    let isbn = value.value
                    print(isbn)
                    
                    myDatabase.child("listings").child("\(isbn)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() {
                        }
                    })
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
            departmentTextField.text = selectedDepartment
            
            myDatabase.child("departments").child("\(selectedDepartment ?? "AHSS")").observeSingleEvent(of: .value) { (snapshot) in
                
                if self.selectedDepartment != "Other" {
                    
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
                    self.courses.append("All")
                }
            }
            
        }else{
            selectedCourse = courses[row]
            courseTextField.text = selectedCourse
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if selectedDepartment != nil && selectedCourse != nil {
            self.searchCourses(department: self.selectedDepartment!, course: self.selectedCourse!)
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
        
        
        
        return cell
    }
    
}







