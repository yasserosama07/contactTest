//
//  ViewController.swift
//  contactTest
//
//  Created by ioS on 4/10/17.
//  Copyright © 2017 ioS. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UITableViewController, UISearchResultsUpdating {
    var cnContacts = [CNContact]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredContacts = [CNContact]()
    
    func filterContentForSearchText(searchText: String, scope: String = "All")
    {
        filteredContacts = cnContacts.filter{ cnc in
            return cnc.givenName.lowercased().contains(searchText.lowercased()) || cnc.familyName.lowercased().contains(searchText.lowercased())
        }
        //tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) {
            granted, error in
            
            guard granted else {
                print("No acces for Contacts")
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactEmailAddressesKey, CNContactThumbnailImageDataKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            
            do {
                try store.enumerateContacts(with: request){
                    (contact, cursor) -> Void in
                    self.cnContacts.append(contact)
                    self.tableView.reloadData()
                }
            } catch let error {
                NSLog("Fetch contact error: \(error)")
            }
            print("cont \(self.cnContacts.count)")
            
            for contact in self.cnContacts
            {
                let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                print(fullName)
                for i in 0..<contact.phoneNumbers.count
                {
                    print(contact.phoneNumbers[i].value)
                }
                print(contact.thumbnailImageData ?? "no Thumbnail Data")
            }
            
        }
        tableView.reloadData()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""
        {
            return filteredContacts.count
        }
        else
        {
            return cnContacts.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let contact: CNContact
        
        if searchController.isActive && searchController.searchBar.text != ""
        {
            contact = filteredContacts[indexPath.row]
        }
        else
        {
            contact = cnContacts[indexPath.row]
        }
        
//        cell.contactNameLabel?.text = "\(contact.givenName) \(contact.familyName)"
//        cell.contactPhoneLabel.text = contact.phoneNumbers[0].value.stringValue
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        cell.detailTextLabel?.text = contact.phoneNumbers[0].value.stringValue

        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
        cell.imageView?.clipsToBounds = true
        cell.imageView?.contentMode = .scaleAspectFill

        if let imageData = contact.imageData
        {
//            cell.contactImageView?.layer.cornerRadius = cell.contactImageView.frame.size.width / 2
//            cell.contactImageView?.image = UIImage(data: imageData)
            cell.imageView?.image = imageWithImage(image: UIImage(data: imageData)!)
        }
        else
        {
            let firstName = contact.givenName
            let secondName = contact.familyName
            
            cell.imageView?.image = imageWithImage(image: generateAvatar(first: firstName, second: secondName))
            
//            cell.contactImageView?.layer.cornerRadius = cell.contactImageView.frame.size.width / 2
//            cell.imageView?.image = generateAvatar(first: firstName, second: secondName)
        }
        return cell
    }
    

    func imageWithImage(image: UIImage) -> UIImage
    {
        let size = CGSize(width: 80, height: 80)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contact: CNContact
        
        if segue.identifier == "contactDetail"
        {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell)
            {
                if searchController.isActive && searchController.searchBar.text != ""
                {
                    contact = filteredContacts[indexPath.row]
                }
                else
                {
                    contact = cnContacts[indexPath.row]
                }
                let contactDetail = segue.destination as! ContactViewController
                contactDetail.cntct = contact
            }
        }
    }
    
    func generateAvatar(first: String, second: String) -> UIImage
    {
        let lblName = UILabel()
        lblName.frame.size = CGSize(width: 80, height: 80)
        lblName.textColor = UIColor.white
        lblName.text = String(describing: first.characters.first!) + String(describing: second.characters.first!)
        lblName.textAlignment = .center
        lblName.backgroundColor = UIColor.darkGray
        lblName.layer.cornerRadius = 40.0
        lblName.layer.masksToBounds = true
        
        UIGraphicsBeginImageContext(lblName.frame.size)
        lblName.layer.render(in: UIGraphicsGetCurrentContext()!)
        let avatar = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return avatar
    }

}

class contactCell: UITableViewCell
{
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    
}
