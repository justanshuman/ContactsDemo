//
//  AddContactViewModel.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

class AddContactViewModel {
    let firstName = MutableProperty("")
    let lastName = MutableProperty("")
    let phoneNumber = MutableProperty("")
    let emailId = MutableProperty("")
    var saveContactsDataSignal : SignalProducer<String, NSError>?
    
    init(){
        
    }
    
    // Start save contact signal
    func saveContactsData() -> SignalProducer<String, NSError>{
        return SignalProducer { event, disposable in
            //Return if first name not valid
            if !self.isFirstNameValid() {
                let nserror = NSError(domain: ErrorMessages.FIRST_NAME_INVALID, code: 1, userInfo: nil)
                event.sendFailed(nserror)
                return
            }
                // return if last name not valid
            else if !self.isValidMobile(){
                let nserror = NSError(domain: ErrorMessages.MOBILE_INVALID, code: 1, userInfo: nil)
                event.sendFailed(nserror)
            }
                // Make api call to save contact
            else {
                let parameters: [String: AnyObject] = [
                    "first_name" : self.firstName.value,
                    "last_name" : self.lastName.value,
                    "email": self.emailId.value,
                    "favorite" : false,
                    "phone_number" : self.phoneNumber.value
                ]
                Alamofire.request(.POST, "\(Constants.BASE_URL)/contacts.json", parameters: parameters, encoding: .JSON, headers: nil).responseJSON(completionHandler: { (req, response, result) in
                    // Posting new contact successful
                    if let r = response where r.statusCode == 201 {
                        event.sendCompleted()
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.CONTACTS_UPDATED, object: nil)
                        return
                    }
                    else {
                        //Posting new contact failed
                        event.sendNext(ErrorMessages.GENERIC_ERROR)
                        return
                    }
                })
            }
        }
    }
    //Perform Validations on first name
    func isFirstNameValid() -> Bool {
        return firstName.value.characters.count > 3 ? true : false
    }
    //Perform validations on mobile number. Valid are in forms +918989898989, 09898989898 and 9898989898
    func isValidMobile() -> Bool {
        let mobileRegEx = "^((\\+?[9][1])|([0]))?[1-9]\\d{9}$"
        let mobileTest = NSPredicate(format: "SELF MATCHES %@", mobileRegEx)
        if mobileTest.evaluateWithObject(phoneNumber.value) {
            return true
        }
        return false
    }
    
    func addContact(){
        saveContactsDataSignal = saveContactsData()
    }
    
}