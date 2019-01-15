//
//  ToDoItem.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/14/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var checked : Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "toDoItems")
}
