//
//  Item.swift
//  internProject
//
//  Created by Alperen Selçuk on 5.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchClient


class Item {
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kOBJECTID] as? String
        categoryId = _dictionary[kCATEGORYID] as? String
        name = _dictionary[kNAME] as? String
        description = _dictionary[kDESCRIPTION] as? String
        price = _dictionary[kPRICE] as? Double
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
    }
    init() {}
}


//MARK: Save function
func saveItemToFirebase(_ item: Item) -> Void {

    FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String : Any])
}


//MARK: helper func
func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id, item.categoryId, item.name, item.description, item.price, item.imageLinks], forKeys: [kOBJECTID as NSCopying, kCATEGORYID as NSCopying, kNAME as NSCopying, kDESCRIPTION as NSCopying, kPRICE as NSCopying, kIMAGELINKS as NSCopying])
}


//MARK: Download func
func downloadItemsFromFirebase(_ withCategoryId: String, completion: @escaping (_ itemArray: [Item]) -> Void) {
    var itemArray: [Item] = []
    
    FirebaseReference(.Items).whereField(kCATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents {
                
                itemArray.append(Item(_dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
}



func downloadItems(_ withIds: [String], completition: @escaping (_ itemArray: [Item]) -> Void) {
            
    var count = 0
    var itemArray: [Item] = []
    
    if withIds.count > 0 {
        for itemId in withIds {
                            
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    completition(itemArray)
                    return
                }
                if snapshot.exists {
                    
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                } else {
                    completition(itemArray)
                }
                
                if count == withIds.count {
                    completition(itemArray)
                }
            }
        }
    } else {
        completition(itemArray)
    }
}

//MARK: Algolia Func

func saveItemToAlgolia(item: Item) {
    
    let index = AlgoliaService.shared.index
    let itemToSave = itemDictionaryFrom(item) as! [String : Any]
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { (content, error) in
        
        if error != nil {
            print("error saving to algolia", error!.localizedDescription)
        } else {
            print("added to algolia")
        }
    }
}


//MARK: Algolia search funci
func searchAlgolia(searchString: String, completion: @escaping (_ itemArray: [String]) -> Void) {
    
    let index = AlgoliaService.shared.index
    var resultIds: [String] = []
        
    let query = Query(query: searchString)
    
    query.attributesToRetrieve = ["name", "description"]
    
  
    index.search(query) { (content, error) in
        
        if error == nil {

            let cont = content!["hits"] as! [[String : Any]]
            resultIds = []
            
            for result in cont {
                resultIds.append(result["objectID"] as! String)
            }
            
            completion(resultIds)
        } else {
            print("error algolia search", error!.localizedDescription)
            completion(resultIds)  //empty array
        }
    }
}
