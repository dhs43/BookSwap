//
//  fullDetailsViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/17/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import SVProgressHUD

class FullDetailsViewController: UIViewController {

    //save data from global variable
    let bookForSale: Book = selectedBook
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //clear global variable
        selectedBook = Book()

        let url = URL(string: bookForSale.imageURL!)
        bookImage.kf.setImage(with: url)
        titleLabel.text = bookForSale.title!
        authorLabel.text = "Author: \(bookForSale.author!)"
        editionLabel.text = "Edition: \(bookForSale.edition!)"
        courseLabel.text = "Course: \(bookForSale.department!) \(bookForSale.course!)"
        conditionLabel.text = "Condition: \(bookForSale.condition!)"
        isbn13Label.text = "ISBN 13: \(bookForSale.isbn13!)"
        isbn10Label.text = "ISBN 10: \(bookForSale.isbn10!)"
        myDatabase.child("users").child(bookForSale.listedBy!).child("userData").child("username").observe(.value) { (snapshot) in
            self.sellerLabel.text = "Seller: \(snapshot.value!)"
        }
        priceLabel.text = "$\(bookForSale.price!)"
        
    }
    @IBAction func chatWithSellerButton(_ sender: Any) {
        if bookForSale.listedBy == userID {
            SVProgressHUD.showError(withStatus: "You are the seller of this listing.")
            return
        }
        selectedBook = bookForSale
        performSegue(withIdentifier: "goToChat", sender: self)
    }
}
