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
    
    //@objc dynamic var dueDate : Date = Date()
    
    @objc dynamic var dateCreated : Date = Date()
    
    @objc dynamic var isDone : Bool = false
    
    @objc dynamic var imageUrl : String = ""
    
    @objc dynamic var hasImage : Bool = false
    
    @objc dynamic var redValue : Float = 0
    
    @objc dynamic var greenValue : Float = 0
    
    @objc dynamic var blueValue : Float = 0
    
    @objc dynamic var isTextWhite : Bool = false
    
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "tasks")
    
    
}
