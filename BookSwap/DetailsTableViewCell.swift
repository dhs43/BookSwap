//
//  DetailsTableViewCell.swift
//  BookSwap
//
//  Created by David Shapiro on 8/12/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var priceTextField: UILabel!
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var conditionTextField: UILabel!
    @IBOutlet weak var courseTextField: UILabel!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var isbn13TextField: UILabel!
    @IBOutlet weak var isbn10TextField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
