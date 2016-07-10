//
//  MockData.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation

class MockData {
    func getMockContact1() -> Contact {
        let basicInfo1 = [
            "id": 17,
            "first_name": "Amitabh",
            "last_name": "Bachchan",
            "profile_pic": "/images/missing.png",
            "url": "http://gojek-contacts-app.herokuapp.com/contacts/17.json"
        ]
        var contact = Contact.parseContacts(basicInfo1)
        let moreInfo1 = [
            "id": 17,
            "first_name": "Amitabh",
            "last_name": "Bachchan",
            "email": "ab@bachchan.com",
            "phone_number": "+919980123412",
            "profile_pic": "/images/missing.png",
            "favorite" : false,
            "created_at": "2016-06-27T07:05:39.637Z",
            "updated_at": "2016-07-09T11:17:29.241Z"
        ]
        
        contact = Contact.updateContactsInfo(contact, contactDict: moreInfo1)
        return contact
    }
    
    func getMockContact2() -> Contact {
        let basicInfo2 = [
            "id": 10,
            "first_name": "Batman",
            "last_name": "Bachchan",
            "profile_pic": "/images/missing.png",
            "url": "http://gojek-contacts-app.herokuapp.com/contacts/17.json"
        ]
        var contact = Contact.parseContacts(basicInfo2)
        let moreInfo2 = [
            "id": 10,
            "first_name": "Batman",
            "last_name": "Bachchan",
            "email": "batman@bachchan.com",
            "phone_number": "+919980123412",
            "profile_pic": "/images/missing.png",
            "favorite" : true,
            "created_at": "2016-06-27T07:05:39.637Z",
            "updated_at": "2016-07-09T11:17:29.241Z"
        ]
        contact = Contact.updateContactsInfo(contact, contactDict: moreInfo2)
        return contact
    }
    
    func getHalfMockContactDataWithEmptyFirstName() -> Contact {
        let parameters = [
            "id": 17,
            "first_name": "",
            "last_name": "Bachchan",
            "profile_pic": "/images/missing.png",
            "url": "http://gojek-contacts-app.herokuapp.com/contacts/17.json"
        ]
        return Contact.parseContacts(parameters)
    }
    
    func getHalfMockContactWithEmptyLastName() -> Contact {
        let parameters = [
            "id": 17,
            "first_name": "Amitabh",
            "last_name": "",
            "profile_pic": "/images/missing.png",
            "url": "http://gojek-contacts-app.herokuapp.com/contacts/17.json"
        ]
        return Contact.parseContacts(parameters)
    }
    
    func getHalfMockContactWithAllDetails() -> Contact {
        let parameters = [
            "id": 17,
            "first_name": "Amitabh",
            "last_name": "Bachchan",
            "profile_pic": "/images/missing.png",
            "url": "http://gojek-contacts-app.herokuapp.com/contacts/17.json"
        ]
        return Contact.parseContacts(parameters)
    }
}