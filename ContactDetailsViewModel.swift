//
//  ContactDetailsViewModel.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 08/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

class ContactDetailsViewModel {
    
    var invertFavoriteSignal : SignalProducer<String, NSError>?
    let favoriteImageName = "favorite_yes"
    let notfavoriteImageName = "favorite_not"
    var imageToShow: String?
    var contact: Contact
    
    init(contact: Contact){
        self.contact = contact
        if let isFav = contact.isFavorite {
            self.imageToShow = isFav ? favoriteImageName : notfavoriteImageName
        } else {
            self.imageToShow = notfavoriteImageName
        }
    }
    
    //Start signal and invert favorite status of contact
    func invertFavorite(){
        self.invertFavoriteSignal = startInvertFavoriteSignal()
    }
    
    func startInvertFavoriteSignal() -> SignalProducer<String, NSError> {
        return SignalProducer { event, disposable in
            // If contact contains nil value in favorite field, we consider him not favorite by default
            if self.contact.isFavorite == nil {
                self.contact.isFavorite = false
            }
            if let cid = self.contact.id, isfavorite = self.contact.isFavorite {
                let parameters: [String: AnyObject] = [
                    "favorite": !isfavorite
                ]
                Alamofire.request(.PUT, "\(Constants.BASE_URL)/contacts/\(cid).json", parameters: parameters, encoding: .JSON, headers: nil).responseJSON(completionHandler: { [weak self] request, response, JSON in
                    if let r = response where r.statusCode == 200 {
                        self?.imageToShow = isfavorite ? self?.notfavoriteImageName : self?.favoriteImageName
                        self?.contact.isFavorite = !isfavorite
                        self?.updateContactsDictionary(!isfavorite)
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.CONTACTS_DICT_UPDATED, object: nil)
                        event.sendNext(Constants.SUCCESS)
                        event.sendCompleted()
                    }
                    else{
                        let nserror = NSError(domain: "com.contactsdemo.contactdetailserror", code: 1, userInfo: nil)
                        event.sendFailed(nserror)
                    }
                    })
            }
        }
    }
    func updateContactsDictionary(isfavorite: Bool) {
        if isfavorite {
            if sections.contains(Constants.FAVORITE) {
                contactsDictionary[Constants.FAVORITE]?.append(ContactsTableCellViewModel(contact: contact))
                Constants.sortContactsDictionary()
            }
            else {
                contactsDictionary[Constants.FAVORITE] = [ContactsTableCellViewModel(contact: contact)]
                sections.insert(Constants.FAVORITE, atIndex: 0)
            
            }
        }
        else {
            for (key, list) in contactsDictionary {
                if key == Constants.FAVORITE {
                    var tempFavoriteList = [ContactsTableCellViewModel]()
                    for tempContact in list {
                        if tempContact.contact !== contact {
                            tempFavoriteList.append(ContactsTableCellViewModel(contact: tempContact.contact))
                        }
                    }
                    if tempFavoriteList.count > 0 {
                        contactsDictionary[Constants.FAVORITE] = tempFavoriteList
                    }
                    else {
                        contactsDictionary.removeValueForKey("*")
                        sections.removeFirst()
                    }
                    break
                }
            }
        }
    
    }
    
    func openDiallerAndMakeCall(){
        if let p = self.contact.phone, url = NSURL(string: "tel://\(p)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(url)) {
                application.openURL(url)
            }
        }
    }
    
    func openEmailApp(){
        if let emailId = self.contact.email, url = NSURL(string: "mailto:\(emailId)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(url)) {
                application.openURL(url)
            }
        }
    }
    
    func getEmailId() -> String{
        if let e = contact.email {
            return e
        }
        else{
            return ""
        }
    }
    
    func getPhoneNo() -> String{
        if let p = contact.phone {
            return p
        }
        else{
            return ""
        }
    }
}