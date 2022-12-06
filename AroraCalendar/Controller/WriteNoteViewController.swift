//
//  WriteNoteViewController.swift
//  AroraCalendar
//
//  Created by Mandy on 12/3/22.
//

import UIKit
import RealmSwift

import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage
import FirebaseFirestore

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
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var redSlider: UISlider!
    
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var greenSlider: UISlider!
    
    @IBOutlet weak var colorPreviewImageView: UIImageView!
    
    
    
    var dueDate : Date = Date()
    var now = Date()
    var clickedDate : Date = Date()
    
    var isEdit = false
    
    var categoryString : String = ""
    
    var categories = [Category]()
    
    var imageUri = ""
    var imagePicker = UIImagePickerController()
    
    var colorString = ""
    
    var redValue : Float = 0
    var blueValue : Float = 0
    var greenValue : Float = 0
    var colorARGB : UIColor?
    var textColorARGB : UIColor?
    
    var task = Task()
    var taskToUpdate = Task()
    var tempTask = Task()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //TODO: setup color UI (color box = stored color)
        
        
        
        setUIOnLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        reset()
        
    }
    
    func clearData(){
        
        //TODO: implement
        
    }
    
    func setUIOnLoad(){
        
        //TODO: implement
        
    }
    
    
    
    
    //TODO: checkbox clicked method here. the checkbox isn't currently in the UI... if we add it, the purpose of it will be to change the textcolor from black (unchecked) to white (checked)
    
    
    func getCategories(_ categoryList : [Category]){
        
        //TODO: implement
        
    }
    
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func newCategoryButtonPressed(_ sender: UIButton) {
        
        //if we have user input
        if let userCategoryInput = newCategoryText.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            if(!userCategoryInput.isEmpty){
                
                print("user category input obtained")
                
                //make a category from it
                var newCategory = Category()
                newCategory.categoryName = userCategoryInput
                //add it to the list
                categories.append(newCategory)
                
                //update the category picker
                categoryPicker.reloadAllComponents()
               
                //show newest catgory on the picker
                categoryPicker.selectRow(categories.count - 1, inComponent: 0, animated: true)
                
                //set the category string to the user input
                categoryString = userCategoryInput
                
                //reset the edit text
                newCategoryText.text = ""
            
            }
            //we obtained an empty string from the user
            else{
                print("empty category string submitted")
                
                //show error feedback to user
                let alert = UIAlertController(title: "Error", message: "Empty Category cannot be submitted.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        //make the button for submitting categories invisible again
        newCategoryButton.isHidden = true
        
    }
    
    
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        //TODO: implement
        
    }
    
    func tempSave(){
        
        //TODO: implement
        
    }
    
    func reset(){
        
        noteText.text = ""
        
        clearData()
        
    }
    
    
    @IBAction func redSliderValueChanges(_ sender: UISlider) {
        
        redValue = sender.value
        
        updateColor()
        
    }
    
    @IBAction func blueSliderValueChanged(_ sender: UISlider) {
        
        blueValue = sender.value
        
        updateColor()
        
    }
    
    
    @IBAction func greenSliderValueChanged(_ sender: UISlider) {
        
        greenValue = sender.value
        
        updateColor()
        
    }
    
    func updateColor(){
        
        print("red : \(redValue). blue : \(blueValue). green : \(greenValue)")
        
        colorARGB = UIColor(red: CGFloat(redValue/255), green: CGFloat(greenValue/255), blue: CGFloat(blueValue/255), alpha: 1)
        
        colorPreviewImageView.backgroundColor = colorARGB
    }
    
    
    //TODO: spinner methods
    
    
    



}


