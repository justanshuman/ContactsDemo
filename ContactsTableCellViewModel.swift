//
//  ContactsTableCellViewModel.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 07/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

//Denotes View Model of tableview cell of ViewController class
class ContactsTableCellViewModel {
    let contact: Contact
    var imageChangeSignal : SignalProducer<UIImageView, NSError>?
    var image = MutableProperty(UIImageView(image: UIImage(named: "dummy")))
    
    init(contact: Contact){
        self.contact = contact
        if let u = contact.profilePicUrl {
            var url = u
            //Check if image lies in subfolder  of base url
            if u.compare(Constants.MISSING_IMAGE_URL) == .OrderedSame{
                url = Constants.BASE_URL + Constants.MISSING_IMAGE_URL
            }
            imageChangeSignal = fetchImage(url)
            imageChangeSignal!.startWithNext{(val) in
            }
        }
    }
    //Combine first and last names and return full name
    func getContactFullName() -> String {
        return contact.getContactFullName()
    }
    func fetchImage(url: String) -> SignalProducer<UIImageView, NSError> {
        return SignalProducer { event, disposable in
            // Fetch profile pic url of contact
            Alamofire.request(.GET, url).response() {
                [weak self](_, _, data, _) in
                if let d = data, image = UIImage(data: d){
                    self?.contact.imageData = d
                    self?.image.value = UIImageView(image: image)
                    event.sendNext(UIImageView(image: image))
                    event.sendCompleted()
                }
            }
        }
    }
}
