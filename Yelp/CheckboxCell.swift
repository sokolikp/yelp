//
//  CheckboxCell.swift
//  Yelp
//
//  Created by Paul Sokolik on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class CheckboxCell: UITableViewCell {

    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
