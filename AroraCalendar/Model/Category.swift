//
//  Category.swift
//  AroraCalendar
//
//  Created by Mandy on 12/3/22.
//

import Foundation
import RealmSwift


class Category: Object {
    
    @objc dynamic var categoryName : String = ""
    
    let tasks = List<Task>()
    
    
}
