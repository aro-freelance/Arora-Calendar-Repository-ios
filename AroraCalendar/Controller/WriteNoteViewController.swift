//
//  WriteNoteViewController.swift
//  AroraCalendar
//
//  Created by Mandy on 12/3/22.
//

import UIKit

/*
 
 This view is for creating new notes for the day that the user entered from.
 
 */

class WriteNoteViewController: UIViewController {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var noteText: UITextView!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var newCategoryText: UITextField!
    
    @IBOutlet weak var newCategoryButton: UIButton!
    
    @IBOutlet weak var priorityPicker: UIPickerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func newCategoryButtonPressed(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        
    }
    



}
