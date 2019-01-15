//
//  ViewController.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/12/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {

    let realm = try! Realm()
    
    var toDoItems: Results<ToDoItem>?
    
    var selectedCategory : Category? {
        didSet {
            loadToDoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }

    //MARK: - tableView datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let toDoItem = toDoItems?[indexPath.row] {
            
            cell.textLabel?.text = toDoItem.title
            
            cell.accessoryType = toDoItem.checked ? .checkmark : .none
            //Ternary operator ==> value = condition ? valueiftrue : valueiffalse
        }
        else {
            cell.textLabel?.text = "No Todo items added yet"
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoItems?.count ?? 1
        
    }
    
    //MARK: - tableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.checked = !item.checked
                }
            }
            catch {
                print("Error Saving Checked Status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add new items to list

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen when user presses Add Item button on UI alert
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newToDoItem = ToDoItem()
                        newToDoItem.title = textField.text!
                        newToDoItem.dateCreated = Date()
                        currentCategory.toDoItems.append(newToDoItem)
                    }
                }
                catch {
                    print("Error saving items, \(error)")
                }
                
            }
           
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField

        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Manipulation Methods
   
    func loadToDoItems() {

        toDoItems = selectedCategory?.toDoItems.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadToDoItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}

