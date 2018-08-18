//
//  AuthoredListingsViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/14/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

var selectedListingKey = ""

class AuthoredListingsViewController: UIViewController {
    
    var listings = [Book]()
    var listingKeys = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 140
        
        viewAuthoredListings()
        // Do any additional setup after loading the view.
    }
    
    func viewAuthoredListings() {
        
        //clear previous caches of textbook images
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
        
        let userRef = myDatabase.child("users").child(userID!)
        
        userRef.child("authoredListings").observeSingleEvent(of: .value) { (snapshot) in
            if let books = snapshot.value as? [String:[String:String]] {
                for isbn in books {
                    for listing in isbn.value {
                        
                        
                        //fetch book data from listings
                        myDatabase.child("listings").child(isbn.key).child(listing.value).observeSingleEvent(of: .value) { (snapshot) in
                            
                            let bookData = snapshot.value as! [String: Any]
                            
                            let book = Book()
                            
                            book.title = bookData["title"] as? String
                            book.author = bookData["author"] as? String
                            book.isbn13 = bookData["isbn13"] as? String
                            book.isbn10 = bookData["isbn10"] as? String
                            book.imageURL = bookData["imageURL"] as? String
                            book.price = bookData["price"] as? Int
                            book.edition = bookData["edition"] as? String
                            book.condition = bookData["condition"] as? String
                            book.department = bookData["department"] as? String
                            book.course = bookData["course"] as? String
                            book.listedBy = bookData["listedBy"] as? String
                            
                            self.listings.append(book)
                            self.listingKeys.append(listing.key)
                            
                            DispatchQueue.main.async { self.tableView.reloadData() }
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension AuthoredListingsViewController: UITableViewDelegate,
UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("ListingDetailsTableViewCell", owner: self, options: nil)?.first as! ListingDetailsTableViewCell
        
        //title
        if listings[indexPath.row].title != nil {
            cell.titleLabel.text = listings[indexPath.row].title
        }else{
            cell.titleLabel.text = "(Title Unknown)"
        }
        //author
        if listings[indexPath.row].author != nil {
            cell.authorLabel.text = "Author: \(listings[indexPath.row].author!)"
        }else{
            cell.authorLabel.text = "Author Unknown"
        }
        
        //image
        if listings[indexPath.row].imageURL != nil && listings[indexPath.row].imageURL != "none" {
            let url = URL(string: listings[indexPath.row].imageURL!)
            //cache image using Kingfisher
            cell.bookImageView.kf.setImage(with: url)
        }else{
            cell.bookImageView.image =  #imageLiteral(resourceName: "noCoverImage")
        }
        
        //price
        if listings[indexPath.row].price != nil {
            cell.priceLabel.text = "$\(listings[indexPath.row].price!)"
        }
        
        //course
        if listings[indexPath.row].department != nil && listings[indexPath.row].course != nil && listings[indexPath.row].department != "- Other -" {
            cell.courseLabel.text = "\(listings[indexPath.row].department!) \(listings[indexPath.row].course!)"
        }else{
            cell.courseLabel.text = "Unspecified"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = listings[indexPath.row]
        selectedListingKey = listingKeys[indexPath.row]
        
        performSegue(withIdentifier: "editListing", sender: self)
    }
}


