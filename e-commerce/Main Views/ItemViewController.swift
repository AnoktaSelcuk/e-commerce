//
//  ItemViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 5.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import JGProgressHUD


class ItemViewController: UIViewController {

    
    //MARK: IBOutlet
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    //MARK: Vars
    var item: Item! //optional degil cunku buraya gelenin zaten itemi vardir
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    private let sectionInSet = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHeight : CGFloat = 196.0
    private let itemsPerRaw: CGFloat = 1
    

    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("item name is", item.name!) itemin ismini gormek icin debug..
        SetupIU()
        downloadPictures()
    
        
        //item menusunden geri gitme bari
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))]
                                            
    
                                                    
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "basket"), style: .plain, target: self, action: #selector(self.addToBasketButtonPressed))]
        
    }

    //MARK: Item image donwloader
    
    private func downloadPictures() -> Void {
        
        if item != nil && item.imageLinks != nil {
            
            downloadImages(imagesUrls: item.imageLinks) { (allImages) in
                
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Setup UI(bilgileri bizim seguesiz olan viewimza gecirecek..)
    private func SetupIU() -> Void {
        
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
            
        }
    }
    
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: IBaction for basket
    @objc func addToBasketButtonPressed() {

        downloadBasketFromFirestore(MUser.currentID()) { (basket) in

            if MUser.currentUser() != nil {
                    
                if basket == nil {
                    self.createNewBasket()
                } else {
                    basket!.itemId.append(self.item.id)
                    self.updateBasket(basket: basket!, withValues: [kITEMIDS : basket!.itemId])
                }
            } else {
                self.showLoginView()
            }
        }
    }
    
    //MARK: add to basket
    private func createNewBasket() {
        
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = MUser.currentID()
        newBasket.itemId = [self.item.id]
        saveBasketToFirestore(newBasket)
        
        self.hud.textLabel.text = "Added to basket"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
        
    }
    
    private func updateBasket(basket: Basket, withValues: [String : Any]) {
        updateBasketInFirestore(basket, withvalues: withValues) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                print("error updating basket: ", error!.localizedDescription)
                
                
                
            } else { //error yok..
                
                self.hud.textLabel.text = "Added to basket"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView() //success yaptim cunku gostermiyor.
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    
    private func showLoginView() {
    
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
        
    }
}
extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemImages.count == 0 ? 1 : itemImages.count //if else
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! imageCollectionViewCell
        
        if itemImages.count > 0 {
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
        }
        
        return cell
    }
    
    
}

extension ItemViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

        let availableWidth = collectionView.frame.width - sectionInSet.left
        
        return CGSize(width: availableWidth, height: cellHeight) 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInSet
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInSet.left
    }
}
