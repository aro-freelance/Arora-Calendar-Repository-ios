//
//  Task.swift
//  AroraCalendar
//
//  Created by Mandy on 12/3/22.
//

import Foundation
import RealmSwift

class Task : Object {
    
    @objc dynamic var taskString : String = ""
    
    
    @objc dynamic var category : String = ""
    
    @objc dynamic var dueDate : Date = Date()
    
    @objc dynamic var dateCreated : Date = Date()
    
    @objc dynamic var isDone : Bool = false
    
    @objc dynamic var imageUrl : String = ""
    
    @objc dynamic var colorInt : Int = 0
    
    @objc dynamic var textColorInt : Int = 0
    
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "tasks")
    
    
}
