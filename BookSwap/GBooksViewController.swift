//
//  GBooksViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/28/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit

class GBooksViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //array to store multiple results
    var books = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    //search Google Books for a keyword
    func searchGoogleBooks(query: String){
        
        //encode keyword(s) to be appended to URL
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = "https://www.googleapis.com/books/v1/volumes?q=\(query)"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                
                let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                
                if let items = json["items"] as? [[String: AnyObject]] {
                    print("got items", items)
                    self.books = []
                    
                    //for each result make a book and add title
                    for item in items {
                        if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                            let book = Book()
                            book.title = volumeInfo["title"] as? String
                            
                            //putting all authors into one string
                            if let temp = volumeInfo["authors"] as? [String] {
                                var authors = " "
                                for i in 0..<temp.count {
                                    authors = authors + temp[i]
                                }
                                book.author = authors
                                print("Author - \(book.author!)")
                            }
                            
                            if let imageLinks = volumeInfo["imageLinks"] as? [String: String] {
                                book.imageURL = imageLinks["thumbnail"]
                            }
                            
                            //assign isbn10
                            if let isbns = volumeInfo["industryIdentifiers"] as? [[String: String]] {
                                if isbns.count > 0 {
                                let isbnTen = isbns[0]
                                book.isbn10 = isbnTen["identifier"]
                                print("isbn10 - \(book.isbn10!)")
                                }
                                
                                //isbn13
                                if isbns.count > 1 {
                                let isbnThirteen = isbns[1]
                                book.isbn13 = isbnThirteen["identifier"]
                                print("isbn13 - \(book.isbn13!)")
                                }
                            }
                            //adding book to an array of books
                            self.books.append(book)
                        }
                    }
                    print(self.books)
                    
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }.resume()
        
        print("URL: \(url)")
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
        return self.books.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookItemTableViewCell
        
        cell.titleLabel.text = books[indexPath.row].title!
        if books[indexPath.row].author != nil{
        cell.authorLabel.text = books[indexPath.row].author!
        }
        
        return cell
    }
}


extension GBooksViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        self.searchGoogleBooks(query: text!)
    }
    
}
