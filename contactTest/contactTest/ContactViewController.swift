//
//  ContactViewController.swift
//  contactTest
//
//  Created by Yasser-iOS on 4/17/17.
//  Copyright © 2017 ioS. All rights reserved.
//

import UIKit
import Contacts

class ContactViewController: UIViewController {

    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactFullName: UILabel!
    @IBOutlet weak var contactFirstNumber: UILabel!
    @IBOutlet weak var contactSecondNumber: UILabel!
    @IBOutlet weak var contactEmail: UILabel!
    
    var cntct: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = cntct?.givenName
        contactEmail.isHidden = true
        contactFirstNumber.isHidden = true
        contactSecondNumber.isHidden = true
        contactImageView.isHidden = true
        contactFullName.text = (cntct?.givenName)! + " " + (cntct?.familyName)!
        if (cntct?.emailAddresses.count)! > 0
        {
            contactEmail.isHidden = false
            contactEmail.text = String(describing: (cntct?.emailAddresses[0].value)!)
        }
        if (cntct?.phoneNumbers.count)! > 0
        {
            contactFirstNumber.isHidden = false
            contactFirstNumber.text = cntct?.phoneNumbers[0].value.stringValue
            if (cntct?.phoneNumbers.count)! > 1
            {
                contactSecondNumber.isHidden = false
                contactSecondNumber.text = cntct?.phoneNumbers[1].value.stringValue
            }
        }
        
        
        if let imageData = cntct?.imageData
        {
            contactImageView.isHidden = false
            contactImageView.image = UIImage(data: imageData)
        }
        else
        {
            let fce = ViewController()
            contactImageView.isHidden = false
            contactImageView.image = fce.generateAvatar(first: (cntct?.givenName)!, second: (cntct?.familyName)!)
        }
        
        
    }
}
