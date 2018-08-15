//
//  GBooksViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/28/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import SVProgressHUD
import Kingfisher

//array to store multiple results
var books = [Book]()
//search variable for ISBN
var myQuery = ""


class GBooksViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardDoneButton()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if myQuery != "" {
            searchBar.text = myQuery
            self.searchGoogleBooks(query: myQuery)
        }
    }
    
    //create toolbar w/ done button
    func addKeyboardDoneButton() {
        let keyboardToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(GBooksViewController.dismissKeyboard))]
        keyboardToolbar.sizeToFit()
        searchBar.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    //search Google Books for a keyword
    func searchGoogleBooks(query: String) {
        
        SVProgressHUD.show(withStatus: "Searching")
        tableView.setContentOffset(.zero, animated: true)
        
        //clear previous caches of textbook images
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
        
        //encode keyword(s) to be appended to URL
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = "https://www.googleapis.com/books/v1/volumes?q=\(query)&&maxResults=40"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "\(error!.localizedDescription)")
            }else{
                
                let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                
                if let totalItems = json["totalItems"] as? Int {
                    if totalItems == 0 {
                        SVProgressHUD.showError(withStatus: "No matches found")
                        return
                    }
                }
                
                if let items = json["items"] as? [[String: AnyObject]] {
                    books = []
                    
                    //for each result make a book and add title
                    for item in items {
                        if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                            let book = Book()
                            book.title = volumeInfo["title"] as? String
                            

                            //putting all authors into one string
                            if let temp = volumeInfo["authors"] as? [String] {
                                var authors = ""
                                for i in 0..<temp.count {
                                    if temp.count > 1 {
                                        authors = authors + temp[i] + ", "
                                    }else{
                                        authors = authors + temp[i]
                                    }
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
                                    if firstIsbn["type"] == "ISBN_10" {
                                        book.isbn10 = firstIsbn["identifier"]
                                    }else{
                                        book.isbn13 = firstIsbn["identifier"]
                                    }
                                }
                            }
                            //adding book to an array of books
                            books.append(book)
                        }
                    }
                    DispatchQueue.main.async { self.tableView.reloadData() }
                    SVProgressHUD.dismiss()
                }
            }
        }.resume()
        
        //hide keyboard
        self.searchBar.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GBooksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("BookItemTableViewCell", owner: self, options: nil)?.first as! BookItemTableViewCell
        
        //title
        if books[indexPath.row].title != nil {
            cell.titleLabel.text = books[indexPath.row].title
        }else{
            cell.titleLabel.text = "(Title Unknown)"
        }
        //author
        if books[indexPath.row].author != nil{
            cell.authorLabel.text = "Author: \(books[indexPath.row].author!)"
        }else{
            cell.authorLabel.text = "Author Unknown"
        }
        //isbn
        if books[indexPath.row].isbn13 != nil {
            cell.isbnLabel.text = "ISBN: \(books[indexPath.row].isbn13!)"
        }else if books[indexPath.row].isbn10 != nil{
            cell.isbnLabel.text = "ISBN: \(books[indexPath.row].isbn10!)"
        }else{
            cell.isbnLabel.text = "ISBN Unknown"
        }
        
        //cover image
        if books[indexPath.row].imageURL != nil {
            let url = URL(string: books[indexPath.row].imageURL!)
            //cache image using Kingfisher
            cell.bookCoverView.kf.setImage(with: url)
        }else{
            cell.bookCoverView.image = #imageLiteral(resourceName: "noCoverImage")
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "sellSearchedBook", sender: self)
    }
}


extension GBooksViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        myQuery = searchBar.text!
        self.searchGoogleBooks(query: myQuery)
    }
}
