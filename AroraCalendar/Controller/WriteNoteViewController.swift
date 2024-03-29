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
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    
    @IBOutlet weak var colorPreviewImageView: UIImageView!
    
    lazy var realm = try! Realm()
    
    
    var dueDate : Date = Date()
    var now = Date()
    var clickedDate : Date = Date()
    
    var isEdit = false
    
    var categoryString : String = "To Do List"
    
    var categoriesFull : Results<Category>?
    
    var categories = [Category]()
    
    var imageUri = ""
    var imagePicker = UIImagePickerController()
    var isUpdatingPhoto = false
    
    
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
        
        //self.navigationItem.setHidesBackButton(true, animated: true)
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //set the title using the date
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: clickedDate)
        var dateTitleString = "Failed to Obtain Date"
        if let month = calendarDate.month{
            if let day = calendarDate.day{
                if let year = calendarDate.year{
                 
                    var monthName = "Month"
                    
                    switch(month){
                    case 1:
                        monthName = "January"
                    case 2:
                        monthName = "February"
                    case 3:
                        monthName = "March"
                    case 4:
                        monthName = "April"
                    case 5:
                        monthName = "May"
                    case 6:
                        monthName = "June"
                    case 7:
                        monthName = "July"
                    case 8:
                        monthName = "August"
                    case 9:
                        monthName = "September"
                    case 10:
                        monthName = "October"
                    case 11:
                        monthName = "November"
                    case 12:
                        monthName = "December"
                    default:
                        print("DayVC ViewWillAppear: Error setting up month name")
                    }
                    
                    dateTitleString = "\(monthName) \(day), \(year)"
                    
                }
            }
        }
        
        dateTitleLabel.text = dateTitleString
        
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
            //if the task is already in completed category, add completed to the category list
            if(taskToUpdate.category == "Completed"){
                var cat = Category()
                cat.categoryName = "Completed"
                
                categories.append(cat)
                
            }
            
            //set the category picker to show complete list
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
            
            uploadImage(imageUri)
            
        } else{
            print("failed to get url")
        }
        
    }
    
    func uploadImage(_ urlString : String){
        
        var timestamp : Timestamp = Timestamp()
    
        //create image file path
        //titlestring will not be nil here and user id should not be either because of checks
        let imageName = "\(urlString)\(timestamp.seconds)"
        let filepath = Storage.storage()
            .reference(withPath: "journal_images")
            .child(imageName)
        
        guard let url = URL(string: imageUri) else { return }
        
        
        //save image to file path
        let uploadTask = filepath.putFile(from: url, metadata: nil){ metadata, error in
            
            guard let metadata = metadata else{
                print("meta data block fail.")
                return
            }

        }
        
        uploadTask.observe(.success){ snapshot in
            
            //TODO: progressbar invisible
            
            filepath.downloadURL(completion: { url, error in
                
                
                //error getting the download url
                if let error = error {
                    print("Failed to get download url.")
                    //show error to user
                    let alert = UIAlertController(title: "Error", message: "Failed to get download url.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                        print("alert closed")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                //successfully obtained the download url
                else{
                    //the downloaded url as a string
                    guard let safeUrl = url else { return }
                    
                    
                    let imageUrl : String = (safeUrl.absoluteString) ?? ""
                    
                    self.imageUri = imageUrl
                    
                    self.isUpdatingPhoto = true
                    
                    
                }
                
            })
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
        
        
        if(categoryString == nil){
            if(isEdit){
                categoryString = taskToUpdate.category
                print("catstring = \(categoryString)")
            }
            else{
                categoryString = "To Do List"
            }
        }
        
        print("catstring = \(categoryString)")
        
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
            
            print("category found")
            
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
            newTask.hasImage = isUpdatingPhoto
            
            //this will be sent from the dayView and will default to now if nothing is sent
            newTask.dateCreated = clickedDate
            
            
            
            //editing a task
            if(isEdit){
                
                if let taskToEdit = realm.objects(Task.self).first(where: {$0.dateCreated == taskToUpdate.dateCreated}){
                    
                    
                    do{
                        try self.realm.write {
                            taskToEdit.taskString = taskString
                            taskToEdit.category = categoryString
                            taskToEdit.isDone = false
                            taskToEdit.imageUrl = imageUri
                            taskToEdit.redValue = redValue
                            taskToEdit.greenValue = greenValue
                            taskToEdit.blueValue = blueValue
                            taskToEdit.isTextWhite = isTextWhite
                            taskToEdit.hasImage = isUpdatingPhoto
                            category.tasks.append(taskToEdit)

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
        
        secondVc.dateClicked = clickedDate
        
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


