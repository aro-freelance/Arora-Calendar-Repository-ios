//
//  ViewController.swift
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
 
 This view is for displaying the calendar grid.
 
 */

class CalendarGridViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    
    

    
    @IBOutlet weak var monthPicker: UIPickerView!
    
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var realm = try! Realm()
    
    var now = Date()
    
    //movingLDT if we need it is now without the time components
    
    
    var isInitialLoad = true
    
    var calendarListFull : Results<MyCalendar>?
    var currentMonthCalendarList = [MyCalendar]()
    var fullTaskList : Results<Task>?
    var datesWithNotification = [Date]()
    
    var imageUri = ""
    var imagePicker = UIImagePickerController()
    var isUpdatingPhoto = false
    
    var currentYearInt = 2000
    var currentMonthInt = 1
    //var currentDate = Date()
    
    var monthStringList = [String]()
    
    let defaults = UserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        fullTaskList = realm.objects(Task.self)
        calendarListFull = realm.objects(MyCalendar.self)
        
        
        getMonthList()
        
        monthPickerSetup()
        
        setBackgroundImage()
        
        tableView.reloadData()
    }
    
    func monthPickerSetup(){
        
        //if this is the first load, get the locally stored month/year the user was on last time
        if(isInitialLoad){
            currentMonthInt = defaults.integer(forKey: "currentMonthInt")
            currentYearInt = defaults.integer(forKey: "currentYearInt")
            
            //TODO: set currentDate
            
            isInitialLoad = false
        }
        
        //make a list of strings for the months in the current year
        monthStringList.append("January \(currentYearInt)")
        monthStringList.append("February \(currentYearInt)")
        monthStringList.append("March \(currentYearInt)")
        monthStringList.append("April \(currentYearInt)")
        monthStringList.append("May \(currentYearInt)")
        monthStringList.append("June \(currentYearInt)")
        monthStringList.append("July \(currentYearInt)")
        monthStringList.append("August \(currentYearInt)")
        monthStringList.append("September \(currentYearInt)")
        monthStringList.append("October \(currentYearInt)")
        monthStringList.append("November \(currentYearInt)")
        monthStringList.append("December \(currentYearInt)")
        
        monthPicker.reloadAllComponents()
        
        //set picker to the month it should be showing on load (Jan by default or the most recent user selection)
        monthPicker.selectRow(currentMonthInt - 1, inComponent: 0, animated: true)
        tableView.reloadData()
        
    }
    
    
    
    //month -1
    @IBAction func backMonthButtonPressed(_ sender: UIButton) {
        
        if(currentMonthInt > 1){
            currentMonthInt = currentMonthInt - 1
        } else{
            currentMonthInt = 12
            currentYearInt = currentYearInt - 1
        }
        
        monthPickerSetup()
    }
    
    //month +1
    @IBAction func forwardMonthButtonPressed(_ sender: UIButton) {
        
        if(currentMonthInt < 12){
            currentMonthInt = currentMonthInt + 1
        } else{
            currentMonthInt = 1
            currentYearInt = currentYearInt + 1
        }
        
        monthPickerSetup()
        
    }
    
    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO: reload this view with date = now
        
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: now)

        if let nowMonth = calendarDate.month{
            if let nowYear = calendarDate.year{

                currentMonthInt = nowMonth
                currentYearInt = nowYear

                monthPickerSetup()

            }
        }
        
    }
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        
        goToDayViewController(date: now)
        
    }
    
    func goToDayViewController(date selectedDate : Date){
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let secondVc = storyboard.instantiateViewController(withIdentifier: "DayViewController") as! DayViewController
        
        secondVc.dateClicked = selectedDate
        
        secondVc.modalPresentationStyle = .fullScreen
        self.show(secondVc, sender: true)
        
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
    
    //make a list of the tasks for the month so we can display them on the calendar grid
    func setNotifications(_ taskList : [Task]){
        
        //for each task in the list
        for task in taskList{
            //look at each day in the current month
            for day in currentMonthCalendarList{
                
                let taskDateNoTime = task.dateCreated.removeTimeStamp
                let dayDateNotime = day.date.removeTimeStamp
                
                //if the task date in matches a day that is this month
                if(taskDateNoTime == dayDateNotime){
                    //and if it is not in the completed category
                    if(task.category != "Completed"){
                     
                        //put it on the list of dates with notifications
                        datesWithNotification.append(task.dateCreated)
                        
                    }
                }
            }
        }
        
    }
    
    func setStartOfMonth(){
        
        //TODO: implement
        
    }
    
    
    func getMonthList(){
        
        //TODO: implement
        
    }
    
    
    //rows are vertical columns are horizontal
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: calculate weeks in the calendar
        let weeks = 4
        return weeks
    }
    
    
    //populate the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: implement this... we will also need to make a custom cell for this. Should have Day number, task indications ads dot with color?
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //when a row is selected get the date component for it.
        let dateClicked = currentMonthCalendarList[indexPath.row].date
        //Then send user to DayVC passing that date as the dateclicked.
        goToDayViewController(date: dateClicked)
        
    }
    
    
    
    
    //items to display at once
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //number of items in picker (we will need this to be a list of month that keeps getting longer as user scrolls
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentMonthCalendarList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //TODO: make a string from monthList[row].date month and year components. Should read: December 2022
        let monthYearString = monthStringList[row]
        
        return monthYearString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //TODO: change the tableview to the month in picker
        
    }
    


}

