//
//  ItemsTableViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 4.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

//categoryId'nin aynisi..
import UIKit
import EmptyDataSet_Swift


class ItemsTableViewController: UITableViewController {

    //MARK: vary
    var category: Category? //optional olmali
    
    var itemArray: [Item] = []
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.title = category?.name
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if category != nil {
            loadItems()
        }
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell

        cell.generateCell(itemArray[indexPath.row])

        return cell
    }

    //MARK: tableview Delegate (itemi secmek icin)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(_item: itemArray[indexPath.row])
    }


    
     //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToAddItemSeg" {
            
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    
    private func showItemView(_item: Item) {
        //main.Storyboad
        let itemVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVc.item = _item
        
        self.navigationController?.pushViewController(itemVc, animated: true)

    }
    

    //MARK: Load Items func
    private func loadItems() {
        downloadItemsFromFirebase(category!.id) { (allItems) in
            self.itemArray = allItems
            self.tableView.reloadData() 
        }
    }
}//class end

//MARK: Extend
extension ItemsTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "No items to Display")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "Please Check Back Later")
    }
}// extend end


