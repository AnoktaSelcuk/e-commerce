//
//  CategoryCollectionViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 3.08.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit

class CategoryCollectionViewController: UICollectionViewController {

    //MARK: Vars
    var categoryArray: [Category] = []
    
    private let sectionInSet = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    private let itemsPerRaw: CGFloat = 3
    
    //MARK: View Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCategories()
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return categoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as!  CategoryCollectionViewCell
        cell.generateCell(categoryArray[indexPath.row])
        return cell
    }
    
    
    //MARK: UICollectionView Delegete
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItemSeg", sender: categoryArray[indexPath.row])
    }

    //MARK: kategorileri indirme
    private func loadCategories() -> Void {
        downloadCategoriesFromFirebase { (allCategories) in
//            print("we have ",allCategories.count)
            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "categoryToItemSeg" {
            
            let vc = segue.destination as! ItemsTableViewController
            vc.category = sender as! Category
        }
    }//secilen kategoriler uzerinde haberlesmeyi bu yapacak
}



extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInSet.left * (itemsPerRaw + 1)
        let availableWidth = view.frame.width - paddingSpace
        let withPerItem = availableWidth / itemsPerRaw
        
        return CGSize(width: withPerItem, height: withPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInSet
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInSet.left
    }
}
