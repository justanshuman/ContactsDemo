//
//  ContactModelTests.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import XCTest

class ContactModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        contactsArray = [Contact]()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    
    func testParseContacts(){
        let mockData = MockData()
        let contact = mockData.getHalfMockContactWithAllDetails()
        XCTAssert(contact.firstName == "Amitabh")
        XCTAssert(contact.lastName == "Bachchan")
        XCTAssert(contact.profilePicUrl == "/images/missing.png")
        XCTAssert(contact.infoUrl == "http://gojek-contacts-app.herokuapp.com/contacts/17.json")
        XCTAssert(contact.getContactFullName() == "Amitabh Bachchan")
    }
    
    func testLastNameEmpty(){
        let mockData = MockData()
        let contact = mockData.getHalfMockContactWithEmptyLastName()
        XCTAssert(contact.firstName == "Amitabh")
        XCTAssert(contact.lastName == "")
        XCTAssert(contact.profilePicUrl == "/images/missing.png")
        XCTAssert(contact.infoUrl == "http://gojek-contacts-app.herokuapp.com/contacts/17.json")
        XCTAssert(contact.getContactFullName() == "Amitabh")
    }
    
    func testFirstNameEmpty(){
        let mockData = MockData()
        let contact = mockData.getHalfMockContactDataWithEmptyFirstName()
        XCTAssert(contact.firstName == "")
        XCTAssert(contact.lastName == "Bachchan")
        XCTAssert(contact.profilePicUrl == "/images/missing.png")
        XCTAssert(contact.infoUrl == "http://gojek-contacts-app.herokuapp.com/contacts/17.json")
        XCTAssert(contact.getContactFullName() == "Bachchan")
    }

    func testUpdateContactInfo(){
        let mockData = MockData()
        let contact = mockData.getMockContact1()
        XCTAssert(contact.firstName == "Amitabh")
        XCTAssert(contact.lastName == "Bachchan")
        XCTAssert(contact.profilePicUrl == "/images/missing.png")
        XCTAssert(contact.infoUrl == "http://gojek-contacts-app.herokuapp.com/contacts/17.json")
        XCTAssert(contact.getContactFullName() == "Amitabh Bachchan")
        XCTAssert(contact.email == "ab@bachchan.com")
        XCTAssert(contact.phone == "+919980123412")
    }
    
    func testContactsArray(){
        let mockData = MockData()
        contactsArray.append(mockData.getMockContact1())
        contactsArray.append(mockData.getMockContact2())
        
        XCTAssert(contactsArray.count == 2)
        XCTAssert(contactsArray[0].id == 17)
        
    }
    
    func testSectionsArray(){
        let mockData = MockData()
        contactsArray.append(mockData.getMockContact1())
        contactsArray.append(mockData.getMockContact2())
        
        
        Constants.makeContactsDictionary()
        XCTAssert(sections.count == 3)
        XCTAssert(sections[0] == "\(Constants.FAVORITE)")
        XCTAssert(sections[1] == "A")
        XCTAssert(sections[2] == "B")
    }
    
    func testContactsDictionary(){
        let mockData = MockData()
        contactsArray.append(mockData.getMockContact1())
        contactsArray.append(mockData.getMockContact2())
        
        Constants.makeContactsDictionary()
        XCTAssert(contactsDictionary.count == 3)
        
        XCTAssert(contactsDictionary[Constants.FAVORITE]!.count == 1)
        XCTAssert(contactsDictionary["A"]!.count == 1)
        XCTAssert(contactsDictionary["B"]!.count == 1)
    }

}


