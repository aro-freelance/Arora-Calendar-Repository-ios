//
//  DayViewController.swift
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


//TODO: this app will use similar code practices to my Tasklist and PhotoJournal. Reference both of those as well as my JCalendar Android project.

/*
 TODO: 1. Design the files by referencing JCalendar
 TODO: 2. Design layouts. Research and implement some sort of gridview in Apple.
 TODO: 3. Implement the methods in the files by referencing Tasklist and PhotoJournal
 TODO: 4. Test and fix bugs.
 
 */


/*
 This is the first view that will show.
 This view is for displaying the list of notes for the day.
 
 */

class DayViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dayTitleLabel: UILabel!
    
    @IBOutlet weak var deleteCatButton: UIButton!
    
    let realm = try! Realm()
    
    var currentTaskList = [Task]()
    var fullTaskList : Results<Task>?
    var categories : Results<Category>?
    
    var categoryString = ""
    
    var isLoadingFromDelete = false
    var isInitialLoad = true
    
    var dateClicked : Date = Date()
    
    var imageUri = ""
    var imagePicker = UIImagePickerController()
    var isUpdatingPhoto = true
    
    var monthInt : Int = 1
    var dayInt : Int = 1
    var yearInt : Int = 2000
    
    var isLeapYear = false
    
    //this will be a default true bool that will be set to false if we are coming to this view from the user clicking on a specific date on the calendar
    var isToday = true
    
    let defaults = UserDefaults()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("view will appear")
        //user clicked on a date, set date from ints sent from user
        if(!isToday){
            
            //make a date from the sent Ints
            var dateComponents = DateComponents()
            dateComponents.year = yearInt
            dateComponents.month = monthInt
            dateComponents.day = dayInt
            dateComponents.hour = 0
            dateComponents.minute = 0
            
            //if the year is divisible by 4 it is a leap year
            if(yearInt % 4 == 0){
                isLeapYear = true
            }
            else{
                isLeapYear = false
            }
            
            //set it to the date object
            dateClicked = NSCalendar.current.date(from: dateComponents) ?? Date()
        }
        
        //TODO: remove time from date string... custom write the string
        //set the title using the date
        dayTitleLabel.text = dateClicked.formatted()
        
        setCurrentTaskList(fullTaskList)
        
        setBackgroundImage()
        
        tableView.rowHeight = 120
        
        tableView.reloadData()
        
        
    }
    
    func goToCalendar(){
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let secondVc = storyboard.instantiateViewController(withIdentifier: "CalendarGridViewController") as! CalendarGridViewController
        secondVc.year = yearInt
        secondVc.monthInt = monthInt
        secondVc.modalPresentationStyle = .fullScreen
        self.show(secondVc, sender: true)
        
    }
    
    
    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        
        goToCalendar()
        
    }
    
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        
        print("today button")
        
        //switch to today's date in this view
        dateClicked = Date()
        self.viewDidLoad()
        self.viewWillAppear(true)
        print("today button")
        
    }
    
    
    @IBAction func changeBackgroundButtonPressed(_ sender: UIBarButtonItem) {
        
        print("change bg button pressed")
        
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
            
            bgImage.backgroundColor = .clear
            imageUri = imageURL.absoluteString
            isUpdatingPhoto = true
            
            //set the selected photo to the background
            bgImage.load(url: imageURL)
            
            
            let timestamp : Timestamp = Timestamp()
            //unique device id
            let udid = UIDevice.current.identifierForVendor?.uuidString
        
            //create image file path
            //titlestring will not be nil here and user id should not be either because of checks
            let imageName = "\(udid)\(timestamp.seconds)"
            let filepath = Storage.storage()
                .reference(withPath: "background_images")
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
                        
                        let firebaseUrlString = url?.absoluteString
                        
                        
                        //save the url locally as the bg image
                        self.defaults.setValue(firebaseUrlString, forKey: "bgimageurl")
                        
                        print("successfully uploaded the image. url: \(self.defaults.string(forKey: "bgimageurl") ?? "no url")")
                        
                    }
                })
            }
            
        } else{
            print("failed to get url")
        }
        
    }
    
    //set the background image to the saved image
    func setBackgroundImage(){
        
        if let urlString : String = defaults.string(forKey: "bgimageurl"){
            print("setBackgroundImage: loaded url string from UserDefaults")
            let url : URL = URL(string: urlString)!
            bgImage.load(url: url)
        }
        else{
            print("setBackgroundImage: No image loaded")
        }
        
    }
    
    func deleteCategory(){
        
        if let categoryToDelete : Category = realm.objects(Category.self).first(where: {$0.categoryName == categoryString}){
            if let categoryList = categories{
                
                for category in categoryList{
                    
                    if(category.categoryName == categoryToDelete.categoryName){
                        
                        //Delete data from persistent storage
                        do{
                            //open transaction
                            try self.realm.write {
                                
                                self.realm.delete(categoryToDelete)
                                
                                self.setPicker()
                                
                                
                            }
                        } catch {
                            print("Error deleting Category: \(error)")
                        }
                        
                    }
                }
            }
        }
            
           
    }
    
    
    @IBAction func deleteCategoryButtonPressed(_ sender: UIButton) {
        
        //show a dialog to confirm that user wants to delete. if they do call deleteCategory
        let alert = UIAlertController(title: "Delete", message: "Are you sure that you want to delete this category?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak alert] (_) in
            print("delete method called")
            self.deleteCategory()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            print("delete canceled")
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func setPicker(){
        
        //TODO: implement
        
    }
    
    
    func getCategories(){
        
        //TODO: implement
        
    }
    
    
    func setCurrentTaskList(_ tasks : Results<Task>?){
        
        currentTaskList.removeAll()
        
        print("set current task list")
        
        //for the full list of tasks
        if let taskList = fullTaskList{
            for task in taskList{
             
                //if the task matches the selected category
                if(task.category == categoryString){
                    
                    //add it to the currentTaskList
                    currentTaskList.append(task)
                }
                
                
            }
        } else{
            print("set current task list: failed to make list from full task list")
        }
        
        print("current task list count = \(currentTaskList.count)")
        
        //there are tasks in the current list
        if(currentTaskList.count > 0){
            deleteCatButton.isHidden = true
            
        }
        // there are not tasks in the current list
        else{
            
            //if the category is not a default category and is empty show the delete category button
            if(categoryString != nil){
                if(categoryString != "To Do List" && categoryString != "Completed"){
                    //TODO: tell user that the category is empty in a label
                    deleteCatButton.isHidden = false
                    
                }
            }
            //To Do List category empty
            else if (categoryString == "To Do List"){
                //TODO: tell user that category is empty in a label
                deleteCatButton.isHidden = true
            }
            //completed category empty
            else{
                //TODO: tell user that no tasks are completed in a label
                deleteCatButton.isHidden = true
            }
            
        }
        
        currentTaskList = sortByDate(currentTaskList)
        
        tableView.reloadData()
        
    }
    
    func sortByDate(_ tasks : [Task]) -> [Task]{
        
        return tasks.sorted(by: { $0.dueDate > $1.dueDate })
        
    }
    
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let task = Task()
        task.dueDate = dateClicked
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let secondVc = storyboard.instantiateViewController(withIdentifier: "WriteNoteViewController") as! WriteNoteViewController
        
        secondVc.isEdit = false
        secondVc.task = task
        
        secondVc.modalPresentationStyle = .fullScreen
        self.show(secondVc, sender: true)
        
    }

    
    
    //TODO: tableview methods
    
    //TODO: on tableview item selected
    
    //TODO: tableview cell "radio button clicked" method
    
    //TODO: picker methods
    

}

extension UIImageView {
    
    func load(url: URL){
        
        DispatchQueue.global().async { [weak self] in
            
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(CGRect(origin: .zero, size: size))
            
        }
    }
    
    
}
