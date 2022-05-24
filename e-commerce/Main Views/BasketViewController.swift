//
//  BasketViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 7.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import JGProgressHUD

class BasketViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var checkOutButtonOutlet: UIButton!
    
    //MARK: VAR
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds: [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    
    //MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
        //TODO: chechk if user logged
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        } else {
            self.updateToLabels(true)
        }
        
    }
    
    //MARK: IBAction

    @IBAction func checkOutButtonPressed(_ sender: Any) {
        
        if MUser.currentUser()!.onBoard == true {
            tempFunction()
            
            addItemsToPurchaseHistory(self.purchasedItemIds)
            emptyTheBasket()
            
        } else {
           
            self.hud.textLabel.text = "Please Complete Your Profile!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
            
        }
    }
    

    //MARK: Download basket
    private  func loadBasketFromFirestore() {
        downloadBasketFromFirestore(MUser.currentID()) { (basket) in
            
            self.basket = basket
            self.getBasketItems()
        }
        
    }
    
    //MARK: Helper function
    
    func tempFunction() {
        for item in allItems {
            purchasedItemIds.append(item.id)
        }
    }
    
    

    private func updateToLabels(_ isEmpty: Bool) {
        
        if isEmpty {
            totalItemsLabel.text = "0"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        } else {
            totalItemsLabel.text = "\(allItems.count)"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        }
        
        checkoutButtonStatusUpdate()
        
    }
    
    private func returnBasketTotalPrice() -> String {
        
        var totalPrice: Double = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Total Price: " + convertToCurrency(totalPrice)
    }
    
    private func emptyTheBasket() {
        
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemId = []
        
        updateBasketInFirestore(basket!, withvalues: [kITEMIDS : basket!.itemId]) { (error) in
            
            if error != nil {
                
                print("error updating basket", error!.localizedDescription)
                
            }
            self.getBasketItems()
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        
        if MUser.currentUser() != nil {
            
            let newItemIds = MUser.currentUser()!.purchasedItemIds + itemIds
            
            updateCurrentUserInFirestore(withvalues: [kPURCHASEDITEMIDS : newItemIds]) { (error) in
                
                if error != nil {
                    print("error adding purchased items", error!.localizedDescription)
                }
            }
            
        }
        
        
    }
    

    private func showItemView(withItem: Item) {
        //main.Storyboad
        let itemVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVc.item = withItem
        
        self.navigationController?.pushViewController(itemVc, animated: true)
  
    }
    

    // MARK: Control checkout button
    private func checkoutButtonStatusUpdate() {
        checkOutButtonOutlet.isEnabled = allItems.count > 0
        

        
        if checkOutButtonOutlet.isEnabled {
            checkOutButtonOutlet.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        } else {
            disableCheckoutButton()
        }
    }
    
    private func disableCheckoutButton() {
        checkOutButtonOutlet.isEnabled = false
        checkOutButtonOutlet.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

    }

    private func removeItemFromBasket(itemId: String) {
        
        for i in 0..<basket!.itemId.count {
            
            if itemId == basket!.itemId[i] {
                basket!.itemId.remove(at: i)
                return
            }
        }
    
    }

    private func getBasketItems() {
        

        if basket != nil {
            downloadItems(basket!.itemId) { (allItems) in
                self.allItems = allItems
                self.updateToLabels(false)
                self.tableView.reloadData()
            }
        }
    }
}


extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(allItems[indexPath.row])
        
        return cell
    }
    
    
    
    //MARK: -UITableview Delegete(basketten veri silmek icin kullanacagim..)

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let itemDelete = allItems[indexPath.row]
            
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            
            
            removeItemFromBasket(itemId: itemDelete.id)
                                                        
            updateBasketInFirestore(basket!, withvalues: [kITEMIDS : basket!.itemId]) { (error) in
                
                if error != nil {
                    
                    print("error updating the basket", error!.localizedDescription)
                }
  
                self.getBasketItems()
            }
        }
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
    }
}



