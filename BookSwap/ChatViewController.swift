//
//  ChatViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/15/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Kingfisher

class ChatViewController: UIViewController {
    
    let bookForSale: Book = selectedBook
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: bookForSale.imageURL!)
        bookImage.kf.setImage(with: url)
        titleLabel.text = bookForSale.title!
        authorLabel.text = "Author: \(bookForSale.author!)"
        priceLabel.text = "$ \(bookForSale.price!)"
    }
}
