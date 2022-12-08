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

class WriteNoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    
    
    //@IBOutlet weak var datePicker: UIDatePicker!
    
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
    
    @IBOutlet weak var textColorSwitch: UISwitch!
    
    @IBOutlet weak var previewColorLabel: UILabel!
    
    
    @IBOutlet weak var colorPreviewImageView: UIImageView!
    
    lazy var realm = try! Realm()
    
    
    var dueDate : Date = Date()
    var now = Date()
    var clickedDate : Date = Date()
    
    var isEdit = false
    
    var categoryString : String = ""
    
    var categoriesFull : Results<Category>?
    
    var categories = [Category]()
    
    var imageUri = ""
    var imagePicker = UIImagePickerController()
    var isUpdatingPhoto = false
    
    var colorString = ""
    
    var redValue : Float = 0
    var blueValue : Float = 0
    var greenValue : Float = 0
    var colorARGB : UIColor?
    var isTextWhite : Bool = false
    
    //var task = Task()
    var taskToUpdate = Task()
    //var tempTask = Task()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self

        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        setupCategories()
        
        setUIOnLoad()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //reset()
        
    }
    
//    func clearData(){
//
//        //TODO: implement
//
//    }
    
    func setUIOnLoad(){
        
        if(isEdit){
            //date
            //datePicker.date = taskToUpdate.dueDate
            
            //text
            noteText.text = taskToUpdate.taskString
            
            //category
            setCategoryPicker()
            
            //photo
            if let url = URL(string: taskToUpdate.imageUrl){
                image.load(url: url)
                imageUri = taskToUpdate.imageUrl
            }
            
            //color
            redValue = taskToUpdate.redValue
            greenValue = taskToUpdate.greenValue
            blueValue = taskToUpdate.blueValue
            isTextWhite = taskToUpdate.isTextWhite
            
            updateColor()
            
        }
        else{
            
            redValue = 255
            greenValue = 255
            blueValue = 255
            
            updateColor()
        }
        
    }
    
    
    @IBAction func editCategoryText(_ sender: UITextField) {
        
        //user is entering a category. show them the button to submit it.
        newCategoryButton.isHidden = false
    }
    
    
    
    
    func setCategoryPicker(){
        
        print("set category picker")
        
        categoryPicker.reloadAllComponents()
        
        if(isEdit){
            //set the category picker to show completed list
            if let index = categories.firstIndex(where: {$0.categoryName == taskToUpdate.category}){
                
                categoryPicker.selectRow(index, inComponent: 0, animated: true)
                
                categoryString = taskToUpdate.category
                
            }
            else{
                print("cannot obtain category index")
            }
            
        }
        else{
            //set the categpory picker to show the first task (To Do List)
            categoryPicker.selectRow(0, inComponent: 0, animated: true)
            
            categoryString = "To Do List"
            
        }
        
    }
    
    
    
    
    //TODO: checkbox clicked method here. the checkbox isn't currently in the UI... if we add it, the purpose of it will be to change the textcolor from black (unchecked) to white (checked)
    
    
    func setupCategories(){
        
        categories.removeAll()
        
        categoriesFull = realm.objects(Category.self)
        
        var toDoListExists = false
        var completedExists = false
        
        if let categoryList = categoriesFull{
            
            for category in categoryList{
             
                if(category.categoryName == "To Do List"){
                    
                    toDoListExists = true
    
                }
                
                if(category.categoryName == "Completed"){
                    completedExists = true
    
                }
                
            }
            
            if(toDoListExists){
                for category in categoryList {
                    
                    categories.append(category)
                    
                }
            }
            else{
                var toDoCat = Category()
                toDoCat.categoryName = "To Do List"
                
                categories.append(toDoCat)
                
                for category in categoryList {
                    categories.append(category)
                }
            }
            
            //if the completed category exists
            if(completedExists){
                //find the index for it
                if let index = categories.firstIndex(where: { $0.categoryName == "Completed"}){
                    //and remove it (we do not want it to display as an option to add tasks to)
                    categories.remove(at: index)
                }
            }
            
            
        } else{
            print("WriteVC: failed to get category list from realm")
            //show error feedback to user
            let alert = UIAlertController(title: "Error", message: "Failed to load categories", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if(isEdit){
            isUpdatingPhoto = true
        }
        
        //prompt user to pick a photo
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            print("Button image picker")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            
            print("loaded url")
            
            image.backgroundColor = .clear
            imageUri = imageURL.absoluteString
            isUpdatingPhoto = true
            
            image.load(url: imageURL)
            
        } else{
            print("failed to get url")
        }
        
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
        save()
        
    }
    
    func save(){
        
        var taskString = noteText.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
//        dueDate = datePicker.date
//
//
//        if(dueDate == nil){
//            if(isEdit){
//                dueDate = taskToUpdate.dueDate
//            }
//            else{
//                dueDate = Date()
//            }
//        }
        
        
        if(categoryString == nil){
            if(isEdit){
                categoryString = taskToUpdate.category
            }
            else{
                categoryString = "To Do List"
            }
        }
        
        //if the category does not exist, save it to realm db
        if let safeCategoriesFull = categoriesFull{
            if(!(safeCategoriesFull.contains(where: {$0.categoryName == categoryString}))){
                
                var category = Category()
                category.categoryName = categoryString
                
                do{
                    try realm.write {
                        print("write cat")
                        realm.add(category)
                    }
                    
                } catch {
                    print("Error saving category \(error)")
                    //show error feedback to user
                    let alert = UIAlertController(title: "Error", message: "Failed to save category. \(error)", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else{
            print("categories full is nil. cannot write new category")
            //show error feedback to user
            let alert = UIAlertController(title: "Error", message: "Cannot access saved categories.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        if let category = realm.objects(Category.self).first(where: {$0.categoryName == categoryString}){
            
            
            var newTask = Task()
            newTask.taskString = taskString
            //TODO: consider removing date from UI... we really just want user to add to the date they entered from
            //newTask.dueDate = dueDate
            newTask.category = categoryString
            newTask.imageUrl = imageUri
            newTask.redValue = redValue
            newTask.greenValue = greenValue
            newTask.blueValue = blueValue
            newTask.isTextWhite = isTextWhite
            
            
            
            
            
            //editing a task
            if(isEdit){
                
                taskToUpdate.taskString = taskString
                //TODO: update this so it is dateclicked?
                //taskToUpdate.dueDate = dueDate
                taskToUpdate.category = categoryString
                taskToUpdate.isDone = false
                taskToUpdate.imageUrl = imageUri
                taskToUpdate.redValue = redValue
                taskToUpdate.greenValue = greenValue
                taskToUpdate.blueValue = blueValue
                taskToUpdate.isTextWhite = isTextWhite
                
                do{
                    try self.realm.write {
                        category.tasks.append(taskToUpdate)
                        
                        self.goToMainScreen()
                    }
                    
                } catch {
                    print("Error editing task \(error)")
                    //show error feedback to user
                    let alert = UIAlertController(title: "Error", message: "Failed to save edited task. \(error)", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            //new task creation
            else{
                
                do{
                    try self.realm.write {
                        
                        print("saving new task. Task: \(newTask)")
                        
                        category.tasks.append(newTask)
                        
                        self.goToMainScreen()
                    }
                    
                } catch {
                    print("Error saving new task \(error)")
                    //show error feedback to user
                    let alert = UIAlertController(title: "Error", message: "Failed to save task. \(error)", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            }
        }
        else{
            print("could not retrieve category from realm ")
            //show error feedback to user
            let alert = UIAlertController(title: "Error", message: "Failed to load category.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func goToMainScreen(){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let secondVc = storyboard.instantiateViewController(withIdentifier: "DayViewController") as! DayViewController
        
        //TODO: pass day info to DayViewController
        
        secondVc.modalPresentationStyle = .fullScreen
        self.show(secondVc, sender: true)
    }
    
    func tempSave(){
        
        //TODO: implement
        
    }
    
//    func reset(){
//
//        noteText.text = ""
//
//        clearData()
//
//    }
    
    @IBAction func textColorSwitch(_ sender: UISwitch) {
        
        isTextWhite = !sender.isOn
        
        updateColor()
        
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
        
        colorARGB = UIColor(red: CGFloat(redValue/255), green: CGFloat(greenValue/255), blue: CGFloat(blueValue/255), alpha: 1)
        
        colorPreviewImageView.backgroundColor = colorARGB
        
        if(isTextWhite){
            previewColorLabel.textColor = .white
        }
        else{
            previewColorLabel.textColor = .black
        }
        
    }
    
    
    //category picker rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categories.count
        
    }
    
    //category picker columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    //category picker list
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return categories[row].categoryName
        
    }
    
    //category picker on click
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        categoryString = categories[row].categoryName
        
    }



}


