//
//  BatchViewController.swift
//  BatchUpdateAndDelete
//
//  Created by Mazharul Huq on 2/28/18.
//  Copyright © 2018 Mazharul Huq. All rights reserved.
//

import UIKit
import CoreData

class BatchViewController: UITableViewController {
    
    var persons:[Person]! = []//Array of instances of Person class
    lazy var coreDataStack = CoreDataStack(modelName: "PersonList")

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest:NSFetchRequest<Person> = Person.fetchRequest()
        do {
            persons = try coreDataStack.managedContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let person = persons[indexPath.row]
        cell.textLabel!.text = "\(person.name!) "
        cell.detailTextLabel!.text = "age: \(person.age)"
        return cell
    }
    
    
    @IBAction func updateTapped(_ sender: Any) {
        var objectIDs:[NSManagedObjectID]
        //Resets persons array and the managed object context
        persons = []
        coreDataStack.managedContext.reset()
        //1
        let batchUpdate = NSBatchUpdateRequest(entityName: "Person")
        batchUpdate.propertiesToUpdate =
            [#keyPath(Person.age) : 45]
        batchUpdate.affectedStores = coreDataStack.managedContext
        .persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectIDsResultType
        //2
        do {
            let batchResult =
                try coreDataStack.managedContext.execute(batchUpdate)
                    as! NSBatchUpdateResult
            objectIDs = batchResult.result as! [NSManagedObjectID]
            for objectID in objectIDs{
                let managedObject = coreDataStack.managedContext.object(with: objectID)
                coreDataStack.managedContext.refresh(managedObject, mergeChanges: true)
                persons.append(managedObject as! Person)
            }
            
            
        } catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
    }

}


