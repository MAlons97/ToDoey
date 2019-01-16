//
//  CatgegoryTableViewController.swift
//  ToDoey
//
//  Created by Matthew Alonso on 1/14/19.
//  Copyright © 2019 Matthew Alonso. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CatgegoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            guard let cellBackgroundColor = UIColor(hexString: category.backgroundColor) else {fatalError("Category has no color value")}
            
            cell.textLabel?.text =  category.name
            
            cell.backgroundColor = cellBackgroundColor
            
            cell.textLabel?.textColor = ContrastColorOf(cellBackgroundColor, returnFlat: true)
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error Saving Category, \(error)")
        }
        
        tableView.reloadData()
    }
 
    func loadCategories() {

        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    func deleteCategory(category: Category) {

        do {
            try realm.write {
                realm.delete(category)
            }
        }
        catch {
            print("Error Deleting Category, \(error)")
        }

    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row]{
            deleteCategory(category: categoryForDeletion)
        }
    }
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //What will happen when user presses Add Category button on UI alert
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.backgroundColor = RandomFlatColor().hexValue()
            
            self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categories?[indexPath.row]
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToToDoItems", sender: self)
        
    }

}



