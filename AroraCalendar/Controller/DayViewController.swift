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

class DayViewController: UIViewController {
    
    
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
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //TODO: Get stored day, month, year.
        
        //TODO: if there is stored date info, use it to make a date.
        //TODO: else set the date to now.
        
        //TODO: set the title using the date
        
        
        setCurrentTaskList(fullTaskList)
        
        //TODO: set the background image
        
        
        
        
        
        tableView.rowHeight = 120
        
        tableView.reloadData()
        
        
    }
    
    func goToCalendar(){
    
        //TODO: switch view to calendar.  send the month, year so that it is displayed over there.
        
    }
    
    
    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        
        goToCalendar()
        
    }
    
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO: switch to today's date in this view
        
    }
    
    
    //TODO: rename to changeBackgroundButtonPressed?
    @IBAction func changeBackgroundView(_ sender: UIBarButtonItem) {
        
        //TODO: prompt user to select a photo
        
        //TODO: save the image to firebase
        //TODO: and save the image to local storage
        
        //TODO: set photo to background
        
    }
    
    func setBackgroundImage(){
        //TODO: implement
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
