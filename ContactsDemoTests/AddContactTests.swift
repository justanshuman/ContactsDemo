//
//  AddContactTests.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import XCTest
import ReactiveCocoa

class AddContactTests: XCTestCase {
    var viewModel: AddContactViewModel!
    var viewController: AddContactViewController!
    override func setUp() {
        super.setUp()
        viewModel = AddContactViewModel()
        let storyboard = UIStoryboard(name: "Main", bundle:  NSBundle(forClass: self.dynamicType))
        viewController = storyboard.instantiateViewControllerWithIdentifier("AddContactViewController") as? AddContactViewController
        viewController.viewModel = viewModel
        let _ = viewController.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTextFieldValueBindingsWithModel() {
        let textField = UITextField()
        textField.text = "hi"
        viewModel!.firstName <~ textField.rac_text
        viewModel!.lastName <~ textField.rac_text
        viewModel!.emailId <~ textField.rac_text
        viewModel!.phoneNumber <~ textField.rac_text
        XCTAssert(viewModel.firstName.value == "hi")
        XCTAssert(viewModel.lastName.value == "hi")
        XCTAssert(viewModel.emailId.value == "hi")
        XCTAssert(viewModel.phoneNumber.value == "hi")
    }
    
    func testMobileNumberValidations(){
        viewModel!.phoneNumber.value = "+917978787878"
        XCTAssert(viewModel.isValidMobile())
        
        viewModel!.phoneNumber.value = "9898989898"
        XCTAssert(viewModel.isValidMobile())
        
        viewModel!.phoneNumber.value = "09898989898"
        XCTAssert(viewModel.isValidMobile())
        
        viewModel!.phoneNumber.value = ""
        XCTAssert(!viewModel.isValidMobile())
        
        viewModel!.phoneNumber.value = "hghkg"
        XCTAssert(!viewModel.isValidMobile())
        
        viewModel!.phoneNumber.value = "98989898988698"
        XCTAssert(!viewModel.isValidMobile())
        
        viewModel!.phoneNumber.value = "+9898989898"
        XCTAssert(!viewModel.isValidMobile())
    }
    
    func testValidFirstName(){
        viewModel!.firstName.value = "abv bbv"
        XCTAssert(viewModel.isFirstNameValid())
        
        viewModel!.firstName.value = "abv986sabdbbv"
        XCTAssert(viewModel.isFirstNameValid())
        
        viewModel!.firstName.value = ""
        XCTAssert(!viewModel.isFirstNameValid())
        
        viewModel!.firstName.value = "a"
        XCTAssert(!viewModel.isFirstNameValid())
        
        viewModel!.firstName.value = "abv"
        XCTAssert(!viewModel.isFirstNameValid())
    }

    func testApiCallFailsForInvalidFirstName(){
        viewModel.firstName.value = "a"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.FIRST_NAME_INVALID)
    }
    
    func testApiCallFailsForEmptyFirstName(){
        viewModel.firstName.value = ""
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.FIRST_NAME_INVALID)
    }
    
    func testApiCallFailsForvalidFirstName(){
        viewModel.firstName.value = "Batman"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message != ErrorMessages.FIRST_NAME_INVALID)
    }
    
    func testApiCallFailsForEmptyPhone(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = ""
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    
    func testApiCallFailsForInvalidPhone1(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "989898"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    
    func testApiCallFailsForInvalidPhone2(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "989898ashjkdh"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForInvalidPhone3(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "-9884659467688676"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForInvalidPhone4(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "09877678"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForInvalidPhone5(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "+9198776780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForInvalidPhone6(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "+9198798 76780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForValidPhone1(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "+919879876780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message != ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForValidPhone2(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "9879876780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message != ErrorMessages.MOBILE_INVALID)
    }
    func testApiCallFailsForValidPhone3(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "09879876780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message != ErrorMessages.MOBILE_INVALID)
    }
    
    func testForServerConnectionNotAvailable(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "09879876780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: false)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == ErrorMessages.GENERIC_ERROR)
    }
    
    func testForServerConnectionAvailable(){
        viewModel.firstName.value = "IronMan"
        viewModel.phoneNumber.value = "09879876780"
        viewModel.saveContactsDataSignal = AddContactTestsUtil.textFieldVadidationsTest(viewModel, isServerConnected: true)
        self.viewController.saveButtonPressed()
        XCTAssert(viewController.message == Constants.SUCCESS)
    }
}

class AddContactTestsUtil {
    static func textFieldVadidationsTest(viewModel: AddContactViewModel, isServerConnected: Bool) -> SignalProducer<String, NSError>{
        return SignalProducer { event, disposable in
            if !viewModel.isFirstNameValid() {
                let nserror = NSError(domain: ErrorMessages.FIRST_NAME_INVALID, code: 1, userInfo: nil)
                event.sendFailed(nserror)
                return
            }
            else if !viewModel.isValidMobile(){
                let nserror = NSError(domain: ErrorMessages.MOBILE_INVALID, code: 1, userInfo: nil)
                event.sendFailed(nserror)
            }
            else {
                isServerConnected ? event.sendCompleted() : event.sendNext(ErrorMessages.GENERIC_ERROR)
                
            }
        }
    }
}
