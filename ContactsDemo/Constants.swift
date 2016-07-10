//
//  Constants.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 08/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation

class Constants{
    static let ABCD = ["*", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
                       "S", "T", "U", "V", "W", "X", "Y", "Z"]
    static let SUCCESS = "success"
    static let BASE_URL = "http://gojek-contacts-app.herokuapp.com"
    static let MISSING_IMAGE_URL = "/images/missing.png"
    static let CONTACTS_URL = "\(Constants.BASE_URL)/contacts.json"
    static let CONTACTS_DETAILS_BUTTON_IMAGE_SIZE = 35
    static let FAVORITE = "*"
    static let CONTACTS_DICT_UPDATED = "ContactsDictUpdated"
     static let CONTACTS_UPDATED = "ContactsUpdated"
    static func sortContactsDictionary(){
        for (key, value) in contactsDictionary {
            contactsDictionary[key] = value.sort({ (contact1, contact2) -> Bool in
                contact1.contact.getContactFullName().caseInsensitiveCompare(contact2.contact.getContactFullName()) == .OrderedAscending
            })
        }
    }
    
    static func makeContactsDictionary(){
        sections = [String]()
        contactsDictionary = [String: [ContactsTableCellViewModel]]()
        var favoriteList = [Contact]()
        for contact in contactsArray {
            if let fav = contact.isFavorite where fav == true {
                favoriteList.append(contact)
            }
            if let f = contact.getContactFullName().characters.first {
                let firstChar = String(f).uppercaseString
                if let _ = contactsDictionary[firstChar] {
                    contactsDictionary[firstChar]?.append(ContactsTableCellViewModel(contact: contact))
                } else {
                    sections.append(firstChar)
                    contactsDictionary[firstChar] = [ContactsTableCellViewModel(contact: contact)]
                }
            }
        }
        Constants.sortContactsDictionary()
        sections.sortInPlace({ (first, second) -> Bool in
            first.caseInsensitiveCompare(second) == .OrderedAscending
        })
        favoriteList.sortInPlace({ (contact1, contact2) -> Bool in
            contact1.getContactFullName().caseInsensitiveCompare(contact2.getContactFullName()) == .OrderedAscending
        })
        
        for (index, favContact) in favoriteList.enumerate() {
            if index == 0 {
                sections.insert(Constants.FAVORITE, atIndex: 0)
                contactsDictionary[Constants.FAVORITE] = [ContactsTableCellViewModel(contact: favContact)]
            } else {
                contactsDictionary[Constants.FAVORITE]?.append(ContactsTableCellViewModel(contact: favContact))
            }
        }
    }
}

class ErrorMessages {
    static let GENERIC_ERROR = "Sorry! Something went wrong."
    static let FIRST_NAME_INVALID = "First Name not valid"
    static let MOBILE_INVALID = "Mobile Phone Number not valid"
}

