//
//  ListingsViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/1/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import SVProgressHUD
import Kingfisher

//for textbook image covers
let cache = KingfisherManager.shared.cache

var defaultISBN = ""

class ListingsViewController: UIViewController {
    
    var listings = [Book]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var directionsTextLabel: UILabel!
    @IBOutlet weak var searchSuggestionTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardDoneButton()
        
        tableView.isHidden = true
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if myQuery != "" {
            searchBar.text = myQuery
            self.searchForSale(query: searchBar.text!, startingIndex: 0)
        }
    }
    
    //create toolbar w/ done button
    func addKeyboardDoneButton() {
        let keyboardToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ListingsViewController.dismissKeyboard))]
        keyboardToolbar.sizeToFit()
        searchBar.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //search Google Books for a keyword
    func searchForSale(query: String, startingIndex: Int) {
        
        directionsTextLabel.isHidden = true
        searchSuggestionTextLabel.isHidden = true
        tableView.setContentOffset(.zero, animated: true)
        tableView.isHidden = false
        listings.removeAll()
        DispatchQueue.main.async { self.tableView.reloadData() }
        SVProgressHUD.show(withStatus: "Searching")
        
        //clear previous caches of textbook images
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
        
        
        let url = "https://www.googleapis.com/books/v1/volumes?q=\(query)&&maxResults=40&startIndex=\(startingIndex)"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                
                let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                
                if json["error"] == nil {
                    
                    let totalItems = json["totalItems"] as? Int
                    if totalItems == 0 {
                        SVProgressHUD.showError(withStatus: "No matches found")
                        return
                    }
                    
                    if let items = json["items"] as? [[String: AnyObject]] {
                        
                        //for each result make a book and add title
                        for item in items {
                            
                            if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                                
                                let book = Book()
                                //default values
                                book.isbn13 = "isbn13"
                                book.isbn10 = "isbn10"
                                book.title = volumeInfo["title"] as? String
                                
                                //putting all authors into one string
                                if let temp = volumeInfo["authors"] as? [String] {
                                    var authors = ""
                                    for i in 0..<temp.count {
                                        authors = authors + temp[i]
                                    }
                                    book.author = authors
                                }
                                
                                if let imageLinks = volumeInfo["imageLinks"] as? [String: String] {
                                    book.imageURL = imageLinks["thumbnail"]
                                }
                                
                                //assign isbns
                                if let isbns = volumeInfo["industryIdentifiers"] as? [[String: String]] {
                                    
                                    for i in 0..<isbns.count {
                                        
                                        let firstIsbn = isbns[i]
                                        //checks if isbns have invalid characters
                                        let isImproperlyFormatted = firstIsbn["identifier"]!.contains {".$#[]/".contains($0)}
                                        
                                        if isImproperlyFormatted == false {
                                            if firstIsbn["type"] == "ISBN_10" {
                                                book.isbn10 = firstIsbn["identifier"]
                                            }else{
                                                book.isbn13 = firstIsbn["identifier"]
                                            }
                                        }
                                    }
                                }
                                
                                //adding book to an array of books
                                myDatabase.child("listings").child(book.isbn13!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.exists() {
                                        if self.listings.contains(book) == false{
                                            self.listings.append(book)
                                        }
                                        DispatchQueue.main.async { self.tableView.reloadData() }
                                    }
                                })
                                myDatabase.child("listings").child(book.isbn10!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.exists() {
                                        if self.listings.contains(book) == false{
                                            self.listings.append(book)
                                        }
                                        DispatchQueue.main.async { self.tableView.reloadData() }
                                    }
                                })
                            }
                        }
                    }
                }else{
                    return
                }
            }
            SVProgressHUD.dismiss()
            }.resume()
        
        
        //hide keyboard
        self.searchBar.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



extension ListingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  listings.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("BookItemTableViewCell", owner: self, options: nil)?.first as! BookItemTableViewCell
        
        //title
        if listings[indexPath.row].title != nil {
            cell.titleLabel.text = listings[indexPath.row].title
        }else{
            cell.titleLabel.text = "(Title Unknown)"
        }
        //author
        if listings[indexPath.row].author != nil{
            cell.authorLabel.text = "Author: \(listings[indexPath.row].author!)"
        }else{
            cell.authorLabel.text = "Author Unknown"
        }
        //isbn
        if listings[indexPath.row].isbn13 != nil {
            cell.isbnLabel.text = "ISBN: \(listings[indexPath.row].isbn13!)"
        }else if listings[indexPath.row].isbn10 != nil{
            cell.isbnLabel.text = "ISBN: \(listings[indexPath.row].isbn10!)"
        }else{
            cell.isbnLabel.text = "ISBN Unknown"
        }
        
        //cover image
        if listings[indexPath.row].imageURL != nil && listings[indexPath.row].imageURL != "none" {
            let url = URL(string: listings[indexPath.row].imageURL!)
            //cache image using Kingfisher
            cell.bookCoverView.kf.setImage(with: url)
        }else{
            cell.bookCoverView.image = #imageLiteral(resourceName: "noCoverImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedBook = listings[indexPath.row]
        
        if selectedBook.isbn13 != nil {
            defaultISBN = selectedBook.isbn13!
        }else if selectedBook.isbn10 != nil {
            defaultISBN = selectedBook.isbn10!
        }
        
        performSegue(withIdentifier: "listingDetails", sender: self)
    }
}

extension ListingsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        //encode keyword(s) to be appended to URL
        let query = text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        searchForSale(query: query, startingIndex: 0)
    }
}


