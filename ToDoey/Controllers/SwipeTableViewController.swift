//
//  SwipeTableViewController.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/15/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

         tableView.rowHeight = 80.0
        
    }
    
    //MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath)
            
            print("Pip Pip Da Diddly Doo")
            
        }
        
        deleteAction.image = UIImage(named: "DeleteIcon")
        
        return [deleteAction]
        
    }
    
    func updateModel(at indexPath: IndexPath) {
    
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeOptions()
        
        options.expansionStyle = .destructive
        
        return options
        
    }
    
}

