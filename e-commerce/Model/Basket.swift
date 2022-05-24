//
//  Basket.swift
//  internProject
//
//  Created by Alperen Selçuk on 7.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation


class Basket {
 
    var id: String!
    var ownerId: String!
    var itemId: [String]!
    
    
    init() {} 
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kOBJECTID] as? String
        ownerId = _dictionary[kOWNERID] as? String
        itemId = _dictionary[kITEMIDS] as? [String]
    }
}

//MARK: download Func
func downloadBasketFromFirestore(_ ownerId: String, completition: @escaping (_ basket: Basket?) -> Void) {
              
    FirebaseReference(.Basket).whereField(kOWNERID, isEqualTo: ownerId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completition(nil)
            return
        }
               
        if !snapshot.isEmpty && snapshot.documents.count > 0{
            let basket = Basket(_dictionary: snapshot.documents.first!.data() as NSDictionary) //.data string ve any donduruyor..
            completition(basket)
        } else {
            completition(nil)
        }
    }
}


//MARK: Save function
func saveBasketToFirestore(_ basket: Basket) {
    
    FirebaseReference(.Basket).document(basket.id).setData(basketDictionaryFrom(basket) as! [String : Any])
}

//MARK: Helper

func basketDictionaryFrom(_ basket: Basket) -> NSDictionary {
    return NSDictionary(objects: [basket.id, basket.ownerId, basket.itemId], forKeys: [kOBJECTID as NSCopying, kOWNERID as NSCopying, kITEMIDS as NSCopying])
}


func updateBasketInFirestore(_ basket: Basket, withvalues: [String : Any], completition: @escaping (_ error: Error?) -> Void) {
                                     
    FirebaseReference(.Basket).document(basket.id).updateData(withvalues) { (error) in
        completition(error)
    }
}
