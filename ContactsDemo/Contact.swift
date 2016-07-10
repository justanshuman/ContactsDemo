//
//  Contact.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 08/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import UIKit
import CoreData

// Denotes Model of a Contact
class Contact {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var profilePicUrl: String?
    var infoUrl: String?
    var email: String?
    var phone: String?
    var isFavorite: Bool?
    var imageData: NSData?
    
    func getContactFullName() -> String {
        var name = ""
        if let fName = firstName where !fName.isEmpty {
            name += fName
        }
        if let lName = lastName where !lName.isEmpty {
            if let fName = firstName where !fName.isEmpty {
                name += " "
            }
            name += lName
        }
        return name
    }
    
    // Convert a dictionary from api call json into Contact Object
    static func parseContacts(contact: [String: AnyObject]) -> Contact {
        let tempContact = Contact()
        if let id = contact["id"] as? Int {
            tempContact.id = id
        }
        if let fName = contact["first_name"] as? String {
            tempContact.firstName = fName
        }
        if let lName = contact["last_name"] as? String {
            tempContact.lastName = lName
        }
        if let profilePic = contact["profile_pic"] as? String {
            tempContact.profilePicUrl = profilePic
        }
        if let url = contact["url"] as? String {
            tempContact.infoUrl = url
        }
        return tempContact
    }
    
    // Add details of 2nd API call to existing contact object
    static func updateContactsInfo(contact: Contact, contactDict: [String: AnyObject]) -> Contact {
        if let email = contactDict["email"] as? String {
            contact.email = email
        }
        if let phone_number = contactDict["phone_number"] as? String {
            contact.phone = phone_number
        }
        if let favorite = contactDict["favorite"] as? Bool {
            contact.isFavorite = favorite
        }
        return contact
    }
    
    // Save Contacts list to core data
    static func addContactsToCoreData(contactsList: [Contact]) {
        clearNewsFromCoreData() 
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let managedContext = appDelegate.managedObjectContext
            
            for contact in contactsList {
                if let newsObject = NSEntityDescription.insertNewObjectForEntityForName("CoreDataContact", inManagedObjectContext: managedContext) as? CoreDataContact {
                    newsObject.id = contact.id
                    newsObject.firstName = contact.firstName
                    newsObject.lastName = contact.lastName
                    newsObject.url = contact.infoUrl
                    newsObject.profilePicUrl = contact.profilePicUrl
                    newsObject.isfavorite = contact.isFavorite
                    newsObject.phoneNumber = contact.phone
                    newsObject.email = contact.email
                }
            }
            do {
                try managedContext.save()
                managedContext.reset()
            } catch let _ as NSError {
                
            }
        }
    }
    
    // Get contacts list from core data
    static func fetchContactsfromCoreData() -> [Contact]? {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "CoreDataContact")
            
            var newsList = [Contact]()
            do {
                if let fetchRequest_ = try managedContext.executeFetchRequest(fetchRequest) as? [CoreDataContact] {
                    newsList = parseContactsFromCoreData(fetchRequest_)
                    return newsList
                }
            } catch let error as NSError {
                
            } catch {
                
            }
        }
        return nil
    }
    
    static func parseContactsFromCoreData(contactsListFromCoreData: [CoreDataContact]) -> [Contact] {
        var newsList = [Contact]()
        for contact in contactsListFromCoreData {
            let temp = Contact()
            
            if let cid = contact.id as? Int {
                temp.id = cid
            }
            if let fav = contact.isfavorite as? Bool {
                temp.isFavorite = fav
            }
            temp.firstName = contact.firstName
            temp.lastName = contact.lastName
            temp.infoUrl = contact.url
            temp.profilePicUrl = contact.profilePicUrl
            temp.email = contact.email
            temp.phone = contact.phoneNumber
            newsList.append(temp)
        }
        return newsList
    }
    
    //Delete the existing list from core data
    static func clearNewsFromCoreData() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let managedContext = appDelegate.managedObjectContext
            let request = NSFetchRequest(entityName: "CoreDataContact")
            do {
                if let results = try managedContext.executeFetchRequest(request) as? [CoreDataContact] {
                    for r in results {
                        managedContext.deleteObject(r)
                    }
                }
                try managedContext.save()
                managedContext.reset()
            } catch let error as NSError {
                
            }
        }
    }
    
}