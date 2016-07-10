//
//  ContactDetailsViewController.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 08/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import UIKit
import AddressBook
import Contacts

// Denotes the ViewController class for contact details views
class ContactDetailsViewController: UIViewController {
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var somethingWrongView: UIView!
    var viewModel: ContactDetailsViewModel?
    var imageData: NSData?
    
    let favoriteButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.CONTACTS_DETAILS_BUTTON_IMAGE_SIZE, height: Constants.CONTACTS_DETAILS_BUTTON_IMAGE_SIZE))
    let phoneButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.CONTACTS_DETAILS_BUTTON_IMAGE_SIZE, height: Constants.CONTACTS_DETAILS_BUTTON_IMAGE_SIZE))
    let emailButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.CONTACTS_DETAILS_BUTTON_IMAGE_SIZE, height: Constants.CONTACTS_DETAILS_BUTTON_IMAGE_SIZE))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        
        let shareBarButtonItem = UIBarButtonItem(title: "share", style: .Plain, target: self, action: #selector(shareContact))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem
        
        somethingWrongView.hidden = true
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageView.frame.width / 2
        if let data = imageData, image = UIImage(data: data) {
            self.contactImageView.image = image
        }
        else {
            self.contactImageView.image = UIImage(named: "dummy")
        }
        guard let viewModel = viewModel else {
            self.somethingWrongView.hidden = false
            return
        }
        
        progressView.hideProgressView()
        self.favoriteButton.setTitle(viewModel.contact.getContactFullName(), forState: .Normal)
        self.callButton.setTitle(viewModel.getPhoneNo(), forState: .Normal)
        self.emailButton.setTitle(viewModel.getEmailId(), forState: .Normal)
        
        
        // Favorite button pressed
        favoriteButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (obj) in
            self.viewModel!.invertFavorite()
            self.favoriteButton.enabled = false
            //Listen for API call result for inverting favorite state of contact
            viewModel.invertFavoriteSignal?.on(started: {
                () -> Void in
                },
                failed:{[weak self](error) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.favoriteButton.enabled = true
                        self?.showAlertPopUp(ErrorMessages.GENERIC_ERROR)
                    }
                }, completed: {
                    [weak self]() -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.favoriteButton.enabled = true
                        self?.setUpFavoriteButtonImage()
                    }
                },
                next: {
                    (str) -> Void in
            }).start()
        }
        callButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (obj) in
            self.viewModel?.openDiallerAndMakeCall()
        }
        
        emailButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (obj) in
            self.viewModel?.openEmailApp()
        }
    }
    //Share contact button on navigation bar pressed
    func shareContact(sender : UIBarButtonItem){
        let shareItems:Array = [viewModel!.contact.getContactFullName(), viewModel!.getPhoneNo(), viewModel!.getEmailId()]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    //Alert message with ok button, which dismissed the popUp
    func showAlertPopUp(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Initialize the image on buttons
    func setupButtons() {
        favoriteButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        favoriteButton.addSubview(favoriteButtonImageView)
        setUpFavoriteButtonImage()
        phoneButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        let image2 = UIImage(named: "phone")
        phoneButtonImageView.image = image2
        callButton.addSubview(phoneButtonImageView)
        
        emailButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        let image3 = UIImage(named: "email")
        emailButtonImageView.image = image3
        emailButton.addSubview(emailButtonImageView)
    }
    
    //Setups the image on favorite button, also toggles the image
    func setUpFavoriteButtonImage() {
        if let imageName = self.viewModel?.imageToShow {
            let image1 = UIImage(named: imageName)
            favoriteButtonImageView.image = image1
        }
    }
}
