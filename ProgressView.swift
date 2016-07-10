//
//  ProgressView.swift
//  ContactsDemo
//
//  Created by Anshuman Srivastava on 07/07/16.
//  Copyright © 2016 Anshuman Srivastava. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        if let view = loadViewFromNib() {
            contentView = view
            view.frame = bounds
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            addSubview(view)
        }
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ProgressView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as? UIView
        return view
    }
    func hideProgressView(){
        contentView.hidden = true
        self.userInteractionEnabled = false
        indicatorView.stopAnimating()
    }
    func showProgressView(){
        contentView.hidden = false
        self.userInteractionEnabled = true
        indicatorView.startAnimating()
    }
}

