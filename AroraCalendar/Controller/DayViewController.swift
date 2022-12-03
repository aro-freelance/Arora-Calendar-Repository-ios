//
//  DayViewController.swift
//  AroraCalendar
//
//  Created by Mandy on 12/3/22.
//

import UIKit


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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        
        
    }
    
    
    @IBAction func changeBackgroundView(_ sender: UIBarButtonItem) {
        
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
    }
    

}
