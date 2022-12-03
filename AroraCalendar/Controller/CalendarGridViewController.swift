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

class CalendarGridViewController: UIViewController {

    
    @IBOutlet weak var monthPicker: UIPickerView!
    
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var now = Date()
    
    //movingLDT if we need it is now without the time components
    
    
    var isInitialLoad = true
    
    var calendarList : Results<Calendar>?
    var monthList = [Calendar]()
    var taskList : Results<Task>?
    var datesWithNotification = [Date]()
    
    var imageUri = ""
    var imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getMonthList()
        monthPickerSetup()
        setBackgroundImage()
        
        tableView.reloadData()
    }
    
    func monthPickerSetup(){
        
        //TODO: implement
        
    }
    
    
    
    
    @IBAction func backMonthButtonPressed(_ sender: UIButton) {
        
        //TODO: implement
        
    }
    
    @IBAction func forwardMonthButtonPressed(_ sender: UIButton) {
        
        //TODO: implement
        
    }
    
    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO: reload this view with date = now
        
    }
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        
        goToDayViewController(date: now)
        
    }
    
    func goToDayViewController(date selectedDate : Date){
        
        //TODO: go to the DayViewController. send the selectedDate.
        
    }
    
    
    @IBAction func changeBackgroundButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO: prompt user to select a photo
        
        //TODO: save the image to firebase
        //TODO: and save the image to local storage
        
        //TODO: set photo to background
        
    }
    
    func setBackgroundImage(){
        
        //TODO: implement
        
    }
    
    func setNotifications(_ taskList : [Task]){
        
        //TODO: implement
        
    }
    
    func setStartOfMonth(){
        
        //TODO: implement
        
    }
    
    func getMonthList(){
        
        //TODO: implement
        
    }
    
    
    //TODO: tableview methods including onselect
    
    //TODO: picker methods for the month picker selection
    


}

