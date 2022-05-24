//
//  CategoryCollectionViewCell.swift
//  internProject
//
//  Created by Alperen Selçuk on 3.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func generateCell(_ category: Category) -> Void {
        nameLabel.text = category.name
        imageView.image = category.image
    }
}
