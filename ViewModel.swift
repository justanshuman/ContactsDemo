//
//  ViewModel.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 06/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire


//Although declaring global variables of these sorts is a bad strategy, I did it to save some time since the app is not going to prod.
var contactsDictionary = [String: [ContactsTableCellViewModel]]()
var sections = [String]()
var contactsArray = [Contact]()

//Denotes View Model of View Controller class
class ViewModel {
    var contactsFetchedSignal : SignalProducer<String, NSError>?
    var contactDetailsFetchedSignal : SignalProducer<String, NSError>?
    
    let title = "Contacts"
    
    //Denotes if we need to make API call to fetch Contacts
    var contactsFetched = false
    
    init(){
        //Check if their are more than 0 contacts in our persistent storage
        if let t = Contact.fetchContactsfromCoreData() {
            contactsArray = t
            if t.count > 0 {
                contactsFetched = true
            }
        }
        loadContactsData()
    }
    
    //Fetch contacts from API
    func refreshData(){
        contactsFetched = false
        loadContactsData()
    }
    
    // Start the signal to update UI
    func loadContactsData() {
        contactsFetchedSignal = fetchContacts()
    }
    
    //Return Signal that updates UI
    func fetchContacts() -> SignalProducer<String, NSError>{
        return SignalProducer { event, disposable in
            //If API call is needed
            if self.contactsFetched == false {
                //Fetch the list of all contacts
                Alamofire.request(.GET, Constants.CONTACTS_URL, parameters: nil, encoding: .JSON)
                    .responseJSON{[weak self] request, response, JSON in
                        if let r = response where r.statusCode == 200 {
                            contactsArray = [Contact]()
                            if let json = JSON.value as? [AnyObject] {
                                for obj in json {
                                    if let contacts = obj as? [String: AnyObject] {
                                        //Convert fetched contact json to array
                                        let contact = Contact.parseContacts(contacts)
                                        contactsArray.append(contact)
                                    }
                                }
                                //Start Signal to fetch contact info for all contacts (namely email, phone etc)
                                self?.contactDetailsFetchedSignal = self?.updateContactsData()
                                event.sendCompleted()
                            }
                        }
                        else{
                            let nserror = NSError(domain: ErrorMessages.GENERIC_ERROR, code: 1, userInfo: nil)
                            event.sendFailed(nserror)
                        }
                }
            }
                // API call not needed, just update the UI
            else {
                self.contactDetailsFetchedSignal = self.updateContactsData()
                event.sendCompleted()
            }
        }
    }
    
    func updateContactsData() -> SignalProducer<String, NSError> {
        return SignalProducer { event, disposable in
            if !self.contactsFetched {
                // To keep track for how many objects we have made the API call
                //Todo: Add retry machanism for failed calls
                var numberOfContacts = contactsArray.count
                for (index, contact) in contactsArray.enumerate() {
                    if let url = contact.infoUrl {
                        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON)
                            .responseJSON{ [weak self] request, response, JSON in
                                numberOfContacts -= 1
                                if let r = response where r.statusCode == 200 {
                                    if let json = JSON.value as? [String: AnyObject] {
                                        contactsArray[index] = Contact.updateContactsInfo(contact, contactDict: json)
                                    }
                                    // If all API calls are done
                                    if numberOfContacts == 0 {
                                        Contact.addContactsToCoreData(contactsArray)
                                        Constants.makeContactsDictionary()
                                        self?.contactsFetched = true
                                        event.sendNext(Constants.SUCCESS)
                                        event.sendCompleted()
                                    }
                                }
                                else{
                                    //Show error if API calls were not successfull
                                    let nserror = NSError(domain: "com.contactsdemo.contactdetailserror", code: 1, userInfo: nil)
                                    event.sendFailed(nserror)
                                }
                        }
                    }
                }
            }
            // if we are just reloading the view
            else {
                Constants.makeContactsDictionary()
                event.sendCompleted()
            }
        }
    }
    

}
