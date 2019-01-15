//
//  Category.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/14/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let toDoItems = List<ToDoItem>()
}
