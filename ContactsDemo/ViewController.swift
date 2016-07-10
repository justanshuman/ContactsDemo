//
//  ViewController.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 06/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var modelView: ContactsTableCellViewModel?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    func setupView(){
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageView.frame.width / 2
    }
}
// Denotes the landing page of the app
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var noContactsView: UIView!
    @IBOutlet weak var networkErrorView: UIView!
    var textField = UITextField()
    var modelView: ViewModel!
    var refreshControl: UIRefreshControl!
    
    let contactDetailsegueIdentifiew = "showContactDetails"
    let addContactSegueIdentifier = "showAddContactSegue"
    let contactsCellIdentifier = "ContactsTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.showProgressView()
        self.title = modelView.title
        // Make add contact button circular
        addContactButton.clipsToBounds = true
        addContactButton.layer.cornerRadius = addContactButton.layer.frame.width / 2
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading")
        refreshControl.addTarget(self, action: #selector(fetchDataAgain), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        //Means favorite state of a contact has changes, reload UI
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(reloadTableView),
            name: Constants.CONTACTS_DICT_UPDATED,
            object: nil
        )
        
        //Marks user has added new contact, makes a fresh API call, validates and updates API
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(fetchDataAgain),
            name: Constants.CONTACTS_UPDATED,
            object: nil
        )
        refreshData()
        
    }

    
    func reloadTableView(){
        tableView.reloadData()
    }
    // Reload the table view data after coming back to home, handles cases where user might have inverted favorite state of a contact
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func fetchDataAgain(){
        modelView.refreshData()
        refreshData()
    }
    func refreshData(){
       
        modelView.contactsFetchedSignal?.on( completed: {
            () -> Void in
            
            self.modelView.contactDetailsFetchedSignal?.on(started: {
                () -> Void in
                },
                failed:{[weak self](error) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.networkErrorView.hidden = false
                        self?.progressView.hideProgressView()
                        self?.refreshControl.endRefreshing()
                    }
                }, completed: {
                    [weak self]() -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.progressView.hideProgressView()
                        self?.refreshControl.endRefreshing()
                        if sections.count == 0 {
                            self?.noContactsView.hidden = false
                        } else {
                            self?.tableView.reloadData()
                        }
                    }
                },
                next: {
                    (str) -> Void in
            }).start()} ,
            failed: {
                [weak self](error) -> Void in
                self?.networkErrorView.hidden = false
                self?.progressView.hideProgressView()
                self?.refreshControl.endRefreshing()
                
            }
        ).start()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == contactDetailsegueIdentifiew {
            if let contactDetailsViewController =  segue.destinationViewController as? ContactDetailsViewController, index = sender as? NSIndexPath {
                if let m = contactsDictionary[sections[index.section]] {
                    contactDetailsViewController.viewModel = ContactDetailsViewModel(contact: m[index.row].contact)
                    contactDetailsViewController.imageData = m[index.row].contact.imageData
                }
                
            }
        }
        else if segue.identifier == addContactSegueIdentifier {
            if let addContactViewController =  segue.destinationViewController as? AddContactViewController {
                    addContactViewController.viewModel = AddContactViewModel()
            }
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
         headerView.backgroundColor = UIColor(red: 240, green: 244, blue: 245)
        let headerTitle = UILabel(frame: CGRect(x: 20, y: 10, width: 120, height: 15))
        headerTitle.text = sections[section]
        headerTitle.textColor = UIColor.blackColor()
        headerView.addSubview(headerTitle)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(contactsCellIdentifier) as! ContactsTableViewCell
        if let m = contactsDictionary[sections[indexPath.section]] {
            cell.modelView = m[indexPath.row]
            cell.nameLabel.text = m[indexPath.row].getContactFullName()
            //Reload user profile pic image after it is successfully fetched
            m[indexPath.row].image.producer.startWithNext {[weak cell](newValue) in
                dispatch_async(dispatch_get_main_queue()) {
                    cell?.contactImageView.image = newValue.image
                    cell?.setNeedsLayout()
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsDictionary[sections[section]]!.count
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return Constants.ABCD
    }
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let i = sections.indexOf(title) {
            return i
        }
        else {
            return index
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier(contactDetailsegueIdentifiew, sender: indexPath)
    }
}