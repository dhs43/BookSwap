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


class ListingsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let cache = KingfisherManager.shared.cache
    
    //array to store listings
    var listings = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    //search database for books for sale
    func searchForSale(query: String) {
        
        SVProgressHUD.show(withStatus: "Searching")
        
        //clear previous caches of textbook images
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
        
        SVProgressHUD.dismiss()
        
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
        return self.listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("BookItemTableViewCell", owner: self, options: nil)?.first as! BookItemTableViewCell
        
        //title
        cell.titleLabel.text = listings[indexPath.row].title!
        //author
        cell.authorLabel.text = listings[indexPath.row].author!
        //isbn
        if listings[indexPath.row].isbn13 != nil {
            cell.isbnLabel.text = "ISBN: \(listings[indexPath.row].isbn13!)"
        }else if listings[indexPath.row].isbn10 != nil{
            cell.isbnLabel.text = "ISBN: \(listings[indexPath.row].isbn10!)"
        }else{
            cell.isbnLabel.text = "ISBN Unknown"
        }
        
        return cell
    }
}

extension ListingsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        //call the search function here
        
    }
}











