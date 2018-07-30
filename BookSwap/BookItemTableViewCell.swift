//
//  BookItemTableViewCell.swift
//  BookSwap
//
//  Created by David Shapiro on 7/29/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit

class BookItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookCoverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
