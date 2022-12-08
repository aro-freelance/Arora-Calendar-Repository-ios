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

class TaskCell : UITableViewCell{
    
    @IBOutlet weak var cellUIView: UIView!
    
    @IBOutlet weak var taskCellButton: UIButton!
    
    @IBOutlet weak var taskCellText: UILabel!
    
    @IBOutlet weak var taskCellImage: UIImageView!
    
    var closure: (()->())?
    
    @IBAction func taskCellButtonPressed(_ sender: UIButton) {
        closure?()
    }

    
}

class DayViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dayTitleLabel: UILabel!
    
    @IBOutlet weak var deleteCatButton: UIButton!
    
    lazy var realm = try! Realm()
    
    var dailyTaskList = [Task]()
    var dailyCatTaskList = [Task]()
    var fullTaskList : Results<Task>?
    var categoriesFull : Results<Category>?
    var categoryStrings = [String]()
    
    var categoryString = ""
    var category : Category = Category()
    
    var isLoadingFromDelete = false
    var isInitialLoad = true
    var isLoadingToCompleted = false
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableView.automaticDimension

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("view will appear")
        
        fullTaskList = realm.objects(Task.self)
        
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
        
        setDayTaskList(fullTaskList)
        
        setupCategories()
        
        setBackgroundImage()
        
        //tableView.rowHeight = 120
        
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
            if let categoryList = categoriesFull{
                
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
    
    //category picker displays notes in category selected for the day
    func setPicker(){
        
        print("set picker")
        
        categoryPicker.reloadAllComponents()
        
        if(isLoadingToCompleted){
            //set the category picker to show completed list
            if let index = categoryStrings.firstIndex(where: {$0 == "Completed"}){
                
                categoryPicker.selectRow(index, inComponent: 0, animated: true)
                
                
                //TODO: get this from the picker instead
                categoryString = "Completed"
                
                setDayTaskList(fullTaskList)
                
                tableView.reloadData()
            }
            else{
                print("cannot obtain completed index")
            }
            isLoadingToCompleted = false
            
        }
        else{
            //set the categpory picker to show the first task (To Do List)
            categoryPicker.selectRow(0, inComponent: 0, animated: true)
            
            
            //TODO: get this from the picker instead
            categoryString = "To Do List"
            
            setDayTaskList(fullTaskList)
            
            tableView.reloadData()
        }
        
        
        deleteCatButton.isHidden = true
        
        
    }
    
    
    func setupCategories(){
        
        print("setup categories")
        
        categoriesFull = realm.objects(Category.self)
        
        setupCategoryStrings()
        
        setPicker()
        
        
        
//        var toDoListExists = false
//        var completedExists = false
//
//        if let categoryList = categoriesFull{
//
//            print("category list from categories created.")
//
//            for category in categoryList{
//
//                if(category.categoryName == "To Do List"){
//
//                    print("to do list exists")
//
//                    toDoListExists = true
//
//                }
//
//                if(category.categoryName == "Completed"){
//
//                    print("completed exists")
//
//                    completedExists = true
//
//                }
//            }
//
//        }
//        else{
//            print("Main: failed to get categories from realm")
//            //show error feedback to user
//            let alert = UIAlertController(title: "Error", message: "Failed to load categories", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
//
//            }))
//
//            self.present(alert, animated: true, completion: nil)
//        }
//
//        if(!toDoListExists){
//
//            print("to do list doesn't exist b")
//
//            let category = Category()
//            category.categoryName = "To Do List"
//            do{
//                try realm.write {
//                    realm.add(category)
//                }
//
//            } catch {
//                print("Error saving category \(error)")
//                //show error feedback to user
//                let alert = UIAlertController(title: "Error", message: "Failed to save category. \(error)", preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
//
//                }))
//
//                self.present(alert, animated: true, completion: nil)
//            }
//
//        }
//
//        if(!completedExists){
//
//            print("completed doesn't exist b")
//
//            let category = Category()
//            category.categoryName = "Completed"
//            do{
//                try realm.write {
//                    realm.add(category)
//                }
//
//            } catch {
//                print("Error saving category \(error)")
//                //show error feedback to user
//                let alert = UIAlertController(title: "Error", message: "Failed to save category. \(error)", preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
//
//                }))
//
//                self.present(alert, animated: true, completion: nil)
//            }
//
//        }
        
        //setPicker()
        
    }
    

    
    func setDayTaskList(_ tasks : Results<Task>?){
        
        dailyTaskList.removeAll()
        
        
        //for the full list of tasks
        if let taskList = fullTaskList{
            for task in taskList{
                    
                    //remove the time componented
                    let taskDateNoTime = task.dateCreated.removeTimeStamp
                    let dateClickedNoTime = dateClicked.removeTimeStamp
                    
                    
                    //if the dueDate matches the date clicked
                    if(taskDateNoTime == dateClickedNoTime){
                        
                        //add it to the currentTaskList
                        dailyTaskList.append(task)
                    }
                
            }
        } else{
            print("set current task list: failed to make list from full task list")
        }
        
        //then filter for category
        setCategoryTaskList(dailyTaskList)
        
//        print("current task list count = \(dailyTaskList.count)")
//
//        //there are tasks in the current list
//        if(dailyTaskList.count > 0){
//            deleteCatButton.isHidden = true
//
//        }
//        // there are not tasks in the current list
//        else{
//
//            //if the category is not a default category and is empty show the delete category button
//            if(categoryString != nil){
//                if(categoryString != "To Do List" && categoryString != "Completed"){
//                    //TODO: tell user that the category is empty in a label
//                    deleteCatButton.isHidden = false
//
//                }
//            }
//            //To Do List category empty
//            else if (categoryString == "To Do List"){
//                //TODO: tell user that category is empty in a label
//                deleteCatButton.isHidden = true
//            }
//            //completed category empty
//            else{
//                //TODO: tell user that no tasks are completed in a label
//                deleteCatButton.isHidden = true
//            }
//
//        }
//
//        dailyTaskList = sortByDate(dailyTaskList)
//
//        tableView.reloadData()
        
    }
    
    func setCategoryTaskList(_ tasks : [Task]){
        
        dailyCatTaskList.removeAll()
        
        for task in dailyTaskList{
            if(task.category == categoryString){
                dailyCatTaskList.append(task)
            }
        }
       
             
        
        
        print("current task list count = \(dailyCatTaskList.count)")
        
        //there are tasks in the current list
        if(dailyCatTaskList.count > 0){
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
        
        dailyCatTaskList = sortByDate(dailyCatTaskList)
        
        tableView.reloadData()
        
    }
    
    func setupCategoryStrings(){
        
        if(!categoryStrings.contains("To Do List")){
            categoryStrings.append("To Do List")
        }
        
        for task in dailyTaskList{
            
            print("PING")
            
            let c = task.category
            
            if(!categoryStrings.contains(c)){
                print("HELLO")
                categoryStrings.append(c)
            }
        }
        
        if(!categoryStrings.contains("Completed")){
            categoryStrings.append("Completed")
        }
        
        print("setupcatstrings: cat strings count = \(categoryStrings.count)")
    }
    
    func sortByDate(_ tasks : [Task]) -> [Task]{
        
        return tasks.sorted(by: { $0.dateCreated > $1.dateCreated })
        
    }
    
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let secondVc = storyboard.instantiateViewController(withIdentifier: "WriteNoteViewController") as! WriteNoteViewController
        
        secondVc.isEdit = false
        secondVc.clickedDate = dateClicked
        
        secondVc.modalPresentationStyle = .fullScreen
        self.show(secondVc, sender: true)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyCatTaskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = dailyCatTaskList[indexPath.row]
        
        cell.taskCellText.text = task.taskString
        
        cell.cellUIView.backgroundColor = UIColor(red: (CGFloat(task.redValue)/255), green: (CGFloat(task.greenValue)/255), blue: (CGFloat(task.blueValue)/255), alpha: 1)
        
        if(task.isTextWhite){
            cell.taskCellText.textColor = .white
        }
        else{
            cell.taskCellText.textColor = .black
        }
        
        if(task.hasImage){
            if let url = URL(string: task.imageUrl){
                print("\(task.taskString) image.")
                
                cell.taskCellImage.isHidden = false
                cell.taskCellImage.contentMode = UIView.ContentMode.scaleToFill
                cell.taskCellImage.load(url: url)
            }
            else{
                print("could not load url to image")
            }
        }
        else{
            
            print("\(task.taskString) no image.")
            
            cell.taskCellImage.isHidden = true
        }
        
        
        
        
        cell.closure = {
            print("clicked button. closure for \(task.taskString)")
            //if category is not completed, move task to completed
            if(self.categoryString != "Completed"){
                if let completedCat = self.realm.objects(Category.self).first(where: {$0.self.categoryName == "Completed"}){
                    
                    do{
                        
                        try self.realm.write {
                            task.category = "Completed"
                            
                            completedCat.tasks.append(task)
                            
                            //TODO: display label saying it was deleted?
                            
                            self.isLoadingToCompleted = true
                            self.setPicker()
                            
                        }
                        
                    } catch {
                        print("Error editing task \(error)")
                        //show error feedback to user
                        let alert = UIAlertController(title: "Error", message: "Failed to edit task. \(error)", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }
            //category is completed, prompt user to delete task
            else{
                
                
                //show a dialog to confirm that user wants to delete. if they do call delete()
                let alert = UIAlertController(title: "Delete", message: "Are you sure that you want to delete this?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak alert] (_) in
                    print("delete method called")
                    self.delete(task: task)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                    print("delete canceled")
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        
        
        return cell
        
    }
    
    func delete(task: Task){
        
        //delete task
        if let taskToDelete = self.realm.objects(Task.self).first(where: {$0.taskString == task.taskString}){
            
            do{
                
                try self.realm.write {
                    realm.delete(taskToDelete)
                    
                    isLoadingToCompleted = true
                    setPicker()
                    
                    
                }
                
            } catch {
                print("Error deleting task \(error)")
                //show error feedback to user
                let alert = UIAlertController(title: "Error", message: "Failed to remove task. \(error)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let secondVc = storyboard.instantiateViewController(withIdentifier: "WriteNoteViewController") as! WriteNoteViewController
        
        secondVc.isEdit = true
        secondVc.taskToUpdate = dailyCatTaskList[indexPath.row]
        
        secondVc.modalPresentationStyle = .fullScreen
        self.show(secondVc, sender: true)
        
    }
    

///MARK : picker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryStrings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let s = categoryStrings[row]
        
        print("picker string : \(s)")
        
        return s
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        categoryString = categoryStrings[row]
        print("category string = \(categoryString)")
        category.categoryName = categoryStrings[row]
        
        //setDayTaskList(fullTaskList)
        
        setCategoryTaskList(dailyTaskList)
        
        tableView.reloadData()
        
//        if let string = categories[row].categoryName {
//
//            categoryString = string
//            category.categoryName = categoryString
//
//            print("category string = \(categoryString)")
//
//            setCurrentTaskList(fullTaskList)
//
//            tableView.reloadData()
//
//
//        }
//        else{
//
//            print("category selected could not be obtained")
//            //show error feedback to user
//            let alert = UIAlertController(title: "Error", message: "Failed to find category", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
//
//            }))
//
//            self.present(alert, animated: true, completion: nil)
//        }
        
        
    }
    

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

extension Date {
    public var removeTimeStamp : Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
   }
}
