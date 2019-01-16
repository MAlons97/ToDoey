//
//  ViewController.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/12/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var toDoItems: Results<ToDoItem>?
    
    var selectedCategory : Category? {
        didSet {
            loadToDoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let hexColor = selectedCategory?.backgroundColor else {fatalError()}
        
        title = selectedCategory?.name
        
        updateNavBar(withHexCode: hexColor)
                
        searchBar.barTintColor = UIColor(hexString: hexColor)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "007AFF")
        
    }

    //MARK: - Nav Bar Set Up Methods
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Does Not Exist")}
        guard let mainColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        navBar.barTintColor = mainColor
        navBar.tintColor = ContrastColorOf(mainColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(mainColor, returnFlat: true)]
        
    }

    //MARK: - tableView datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let toDoItem = toDoItems?[indexPath.row] {
            
            cell.textLabel?.text = toDoItem.title
            
            if let color = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(10)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
            
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
    
    func deleteToDoItem(item: ToDoItem) {
        
        do {
            try realm.write {
                realm.delete(item)
            }
        }
        catch {
            print("Error Deleting To Do Item, \(error)")
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.toDoItems?[indexPath.row]{
            deleteToDoItem(item: itemForDeletion)
        }
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

