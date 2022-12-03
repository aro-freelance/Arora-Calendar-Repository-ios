//
//  Calendar.swift
//  AroraCalendar
//
//  Created by Mandy on 12/3/22.
//

import Foundation
import RealmSwift


class Calendar{
    
    
    @objc dynamic var date : Date = Date()
    
    @objc dynamic var isToday : Bool = false
    
    @objc dynamic var hasNotes : Bool = false
    
    @objc dynamic var colorInt : Int = 0
    
    
    //TODO: figure out the parent for this list?
    let listOfNotes = List<String>()

    
    
}
