//
//  ManualEntryViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/30/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit

class ManualEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var conditionTextField: UITextField!
    
    let departmentPicker = UIPickerView()
    let coursePicker = UIPickerView()
    let conditionsPicker = UIPickerView()
    
    let departments = ["CS",
                       "BIOL"]
    
    let courses = ["101",
                   "102",
                   "103"]
    
    let conditions = ["Excellent",
                      "Good",
                      "Poor",
                      "Damaged"]
    
    //holds selections for later use
    var selectedDepartment: String?
    var selectedCourse: String?
    var selectedCondition: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPicker(myPicker: departmentPicker, textField: departmentTextField)
        createPicker(myPicker: coursePicker, textField: courseTextField)
        createPicker(myPicker: conditionsPicker, textField: conditionTextField)
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
}
