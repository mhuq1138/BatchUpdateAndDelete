//
//  AppDelegate.swift
//  AsynchronousFetchingAndBatchUpdate
//
//  Created by Mazharul Huq on 4/21/17.
//  Copyright © 2017 Mazharul Huq. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "PersonList")
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        deleteRecords()
        loadDataIfNeeded()
        return true
    }
    
    func loadDataIfNeeded(){
        let fetchRequest:NSFetchRequest<Person> = Person.fetchRequest()
        var count = 0
        
        do{
            count =
                try coreDataStack.managedContext.count(for: fetchRequest)
        }
        catch {
            print("Unable to get person count")
        }
        if (count == 0) {
            for i in (0..<5000) {
                let person = Person(context: coreDataStack.managedContext)
                person.name = "John #\(i)"
                person.age = Int16(arc4random() % 100)
            }
            
            self.coreDataStack.saveContext()
        }
         
    }
    
    func deleteRecords(){
        let fetchRequest:NSFetchRequest<Person> = Person.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        batchDeleteRequest.resultType = .resultTypeCount
        do {
            let batchResult = try coreDataStack.managedContext.execute(batchDeleteRequest) as! NSBatchDeleteResult
            print("#records deleted: \(batchResult.result!)")
            }
            
            
         catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
    }
}

