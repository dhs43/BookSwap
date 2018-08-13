//
//  ListingDetailsViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/12/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ListingDetailsViewController: UIViewController {

    var listings = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewBooksByISBN()
        // Do any additional setup after loading the view.
    }
    
    func viewBooksByISBN() {
        
        let listingsRef = myDatabase.child("listings")
        
        listingsRef.child(isbn13).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                
                if snapshot.exists() {
                    
                    let data = child as! DataSnapshot //each listing
                    let bookData = data.value as! [String: Any]
                    
                    let book = Book()
                    
                    book.title = bookData["title"] as? String
                    book.author = bookData["author"] as? String
                    book.isbn13 = bookData["isbn13"] as? String
                    book.isbn10 = bookData["isbn10"] as? String
                    book.imageURL = bookData["imageURL"] as? String
                    book.edition = bookData["edition"] as? String
                    book.condition = bookData["condition"] as? String
                    book.department = bookData["department"] as? String
                    book.course = bookData["course"] as? String
                    book.listedBy = bookData["listedBy"] as? String
                }
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ListingDetailsViewController: UITableViewDelegate,
UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("DetailsTableViewCell", owner: self, options: nil)?.first as! DetailsTableViewCell
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
