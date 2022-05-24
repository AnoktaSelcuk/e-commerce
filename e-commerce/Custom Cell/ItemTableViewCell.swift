//
//  ItemTableViewCell.swift
//  internProject
//
//  Created by Alperen Selçuk on 5.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    
    //MARK: IBOutlet
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        priceLabel.text = convertToCurrency(item.price)
        priceLabel.adjustsFontSizeToFitWidth = true 
        

        if item.imageLinks != nil && item.imageLinks.count > 0 {
            
            downloadImages(imagesUrls: [item.imageLinks.first!]) { (images) in
                self.itemImageView.image = images.first as? UIImage
                
            }
        }
    }
}
