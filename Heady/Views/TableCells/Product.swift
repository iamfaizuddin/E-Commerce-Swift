//
//  Product.swift
//  Heady
//
//  Created by Faiz on 13/06/2018.
//  Copyright © 2018 iamfaizuddin. All rights reserved.
//

import UIKit

class Product: UITableViewCell {

    var nameLabel = UILabel()
    var taxLabel = UILabel()
    var colorLabel = UILabel()
    var colLabel = UILabel()
    var sizeLabel = UILabel()
    var priceLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colLabel.text = ""
        sizeLabel.text = ""
        priceLabel.text = ""
    }
}
