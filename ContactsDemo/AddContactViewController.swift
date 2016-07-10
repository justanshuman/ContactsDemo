//
//  AddContactViewController.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 09/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import UIKit
import ReactiveCocoa

class AddContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var addContactButtonBottumSpaceContraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: ProgressView!
    var message = ""
    let imagePicker = UIImagePickerController()
    var viewModel: AddContactViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make textfield bindings with ViewModel
        viewModel!.firstName <~ firstNameTextField.rac_text
        viewModel!.lastName <~ lastNameTextField.rac_text
        viewModel!.phoneNumber <~ phoneNumberTextField.rac_text
        viewModel!.emailId <~ emailTextField.rac_text
        
        self.imagePicker.delegate = self
        progressView.contentView.backgroundColor = UIColor.clearColor()
        hideProgressView()
        
        // Add contact button pressed
        addContactButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (obj) in
            // 2 seperate functions to falicitate unit testing
            self.viewModel!.addContact()
            self.saveButtonPressed()
        }
        
        //Make image picker button circular
        pickImageButton.addTarget(self, action: #selector(getImage), forControlEvents: .TouchUpInside)
        pickImageButton.imageView?.contentMode = .ScaleToFill
        pickImageButton.layer.cornerRadius = pickImageButton.frame.width / 2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: self.view.window)
        
        //Dismiss keyboard if user touches anywhere on screen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    func hideKeyBoard(){
        self.view.endEditing(true)
    }
    // Change frame to handle keyboard coming on screen
    func keyboardWillShow(sender: NSNotification){
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        addContactButtonBottumSpaceContraint.constant = keyboardSize.height + 20
    }
    func keyboardWillHide(sender: NSNotification){
        addContactButtonBottumSpaceContraint.constant = 20
    }
    func saveButtonPressed(){
        self.showProgressView()
        self.view.endEditing(true)
        self.viewModel!.saveContactsDataSignal?.on(started: {
            () -> Void in
            },
                                                   failed:{[weak self](error) -> Void in
                                                    //Handaling unit test case, where is always main thread
                                                    //Todo: Move the repeating lines to a seperate function
                                                    if !NSThread.isMainThread() {
                                                        dispatch_async(dispatch_get_main_queue()) {
                                                            self?.progressView.hideProgressView()
                                                            print(error.domain)
                                                            self?.showErrorPopUp(error.domain)
                                                            self?.hideProgressView()
                                                        }
                                                    } else {
                                                        self?.progressView.hideProgressView()
                                                        print(error.domain)
                                                        self?.showErrorPopUp(error.domain)
                                                        self?.hideProgressView()
                                                        self?.message = error.domain
                                                    }
        
            }, completed: {
                [weak self]() -> Void in
                //Handaling unit test case, where is always main thread
                //Todo: Move the repeating lines to a seperate function
                if !NSThread.isMainThread() {
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.hideProgressView()
                        self?.message = Constants.SUCCESS
                        self?.showSuccessPopUp(Constants.SUCCESS)
                    }
                } else {
                    self?.hideProgressView()
                    self?.message = Constants.SUCCESS
                    self?.showSuccessPopUp(Constants.SUCCESS)
                }
            },
               next: {
                [weak self] (message) -> Void in
                //Handaling unit test case, where is always main thread
                //Todo: Move the repeating lines to a seperate function
                if !NSThread.isMainThread() {
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.hideProgressView()
                        self?.message = ErrorMessages.GENERIC_ERROR
                        self?.showGoBackPopUp(message)
                    }
                } else {
                    self?.hideProgressView()
                    self?.message = ErrorMessages.GENERIC_ERROR
                    self?.showGoBackPopUp(message)
                }
            }).start()
    }
    // show error message with ok button, which dismissed the popup
    func showErrorPopUp(message : String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func hideProgressView(){
        progressView.hideProgressView()
        progressView.hidden = true
    }
    
    func showProgressView(){
        progressView.showProgressView()
        progressView.hidden = false
    }
    
    //Shows pop Up, "Ok" button dismisses the popUp and user can retry and cancel button closes the add contact page
    func showGoBackPopUp(message : String) {
        let refreshAlert = UIAlertController(
            title: message,
            message: nil,
            preferredStyle: .Alert
        )
        refreshAlert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .Default,
                handler: nil
            )
        )
        refreshAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .Default,
                handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                }
            )
        )
        self.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    //Shows popUp with ok button, which closes the current view and takes user back to previous page
    func showSuccessPopUp(message : String) {
        let refreshAlert = UIAlertController(
            title: message,
            message: nil,
            preferredStyle: .Alert
        )
        refreshAlert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .Default,
                handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                }
            )
        )
        self.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    //PickUp image from camera or gallery
    func getImage(view: UIView) {
        let alertController = UIAlertController(title: nil , message: nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alertController.addAction(
                UIAlertAction(
                    title: "Take Photo",
                    style: .Default,
                    handler: { (action: UIAlertAction) in
                        self.imagePicker.allowsEditing = false
                        self.imagePicker.sourceType = .Camera
                        self.presentViewController(self.imagePicker, animated: true, completion: nil)
                    }
                )
            )
        }
        alertController.addAction(
            UIAlertAction(
                title: "Photo Library",
                style: .Default,
                handler: { (action: UIAlertAction) in
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.sourceType = .PhotoLibrary
                    self.presentViewController(self.imagePicker, animated: true, completion: nil)
                }
            )
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.bounds
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Image picked delegate call back
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickImageButton.setImage(pickedImage, forState: UIControlState.Normal)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension AddContactViewController: UITextFieldDelegate{
    //Close keboard on pressing return button on keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
}
