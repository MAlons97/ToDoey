//
//  ViewController.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/12/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [ToDoItem]()
    
    var selectedCategory : Category? {
        didSet {
            loadToDoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
 
    }

    //MARK: - tableView datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let toDoItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = toDoItem.title
        
        cell.accessoryType = toDoItem.checked ? .checkmark : .none
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
        
    }
    
    //MARK: - tableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        saveToDoItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add new items to list

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen when user presses Add Item button on UI alert
            
            let newToDoItem = ToDoItem(context: self.context)
            newToDoItem.title = textField.text!
            newToDoItem.checked = false
            newToDoItem.parentCategory = self.selectedCategory
            self.itemArray.append(newToDoItem)
            
            self.saveToDoItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField

        }

        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveToDoItems() {
       
        do {
           try context.save()
        }
        catch {
            print("Error Saving ToDoItem, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadToDoItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), additionalPredicate: NSPredicate? = nil) {

        var predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if additionalPredicate != nil {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, additionalPredicate!])
        }
        
        request.predicate = predicate
        
        do {
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error Fetching Data From Context, \(error)")
        }
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        let filter = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadToDoItems(with: request, additionalPredicate: filter)
        
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

