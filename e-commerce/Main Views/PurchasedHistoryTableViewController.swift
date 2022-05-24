//
//  PurchasedHistoryTableViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 16.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PurchasedHistoryTableViewController: UITableViewController {

    //MARK: vars
    var itemArray: [Item] = []
    
    //MARK: view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetDelegate = self 
        tableView.emptyDataSetSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadItems()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(itemArray[indexPath.row])
        // Configure the cell...

        return cell
    }


    //MARK: load items
    
    private func loadItems() {
        downloadItems(MUser.currentUser()!.purchasedItemIds) { (allItems) in
            
            print("we have ", self.itemArray.count) //closure filan diyor yine 
            self.itemArray = allItems
            self.tableView.reloadData()
        }
    }
}


//MARK: Extend
extension PurchasedHistoryTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "No items to Display")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "Please Check Back Later")
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        
        return UIImage(named: "search")
    }

}// extend end
