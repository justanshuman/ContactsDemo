//
//  ContactTableViewCellModelTests.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import XCTest

class ContactTableViewCellModelTests: XCTestCase {
    
    var viewModel: ContactsTableCellViewModel!
    var contact: Contact!
    override func setUp() {
        super.setUp()
        let mockData = MockData()
        contact = mockData.getMockContact1()
        viewModel = ContactsTableCellViewModel(contact: contact)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }

    func testClassInitialization(){
        XCTAssertNotNil(viewModel.contact)
        XCTAssert(viewModel.contact.id == contact.id)
    }
    
    func testGetFullName(){
        XCTAssert(viewModel.getContactFullName() == contact.getContactFullName())
    }
}
