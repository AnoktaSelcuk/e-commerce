//
//  imageCollectionViewCell.swift
//  internProject
//
//  Created by Alperen Selçuk on 7.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit


class imageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage: UIImage) -> Void {
    
        imageView.image = itemImage
    }
    
}
