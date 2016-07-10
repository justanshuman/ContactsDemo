//
//  CoreDataContact.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation
import CoreData


class CoreDataContact: NSManagedObject {
    @NSManaged var id: NSNumber?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var email: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var profilePicUrl: String?
    @NSManaged var isfavorite: NSNumber?
    @NSManaged var url: String?

}

