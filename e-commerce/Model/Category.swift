//
//  Category.swift
//  internProject
//
//  Created by Alperen Selçuk on 4.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation
import UIKit

class Category {
    
    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?
    
    init(_name: String, _imageName: String) {
        
        id = ""
        name = _name
        imageName = _imageName
        image = UIImage(named: _imageName)
    }
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kOBJECTID] as! String
        name = _dictionary[kNAME] as! String
        image = UIImage(named: _dictionary[kIMAGENAME] as? String ?? "")
    }
}

//MARK: Firebase'dan category indirme

func downloadCategoriesFromFirebase(completion: @escaping (_ categoryArray: [Category]) -> Void) {
    
    var categoryArray: [Category] = []
    
    FirebaseReference(.Category).getDocuments{(snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents{

                categoryArray.append(Category(_dictionary: categoryDict.data() as NSDictionary))
            }
        }
        completion(categoryArray)
    }
}

//MARK: Kategori kaydetme fonksiyonu

func saveCategoryToFirebase(_ category: Category) -> Void {
    let id = UUID().uuidString
    category.id = id
    
    FirebaseReference(.Category).document(id).setData(categoryDictionaryFrom(category) as! [String : Any])
}

func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
    return NSDictionary(objects: [category.id, category.name, category.imageName], forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGENAME as NSCopying])
}

func createCategorySet() -> Void {

    let womenClothing = Category(_name: "Kadin Giyim & Aksesuar", _imageName: "womanCloth")
    let footWaer = Category(_name: "Ayakkabi", _imageName: "footWaer")
    let electronics = Category(_name: "Elektronik", _imageName: "electronics")
    let menClothing = Category(_name: "Erkek Giyim & Aksesuar", _imageName: "menCloth")
    let health = Category(_name: "Saglik", _imageName: "health")
    let baby = Category(_name: "Bebek", _imageName: "baby")
    let home = Category(_name: "Ev", _imageName: "home")
    let car = Category(_name: "Araba", _imageName: "car")
    let luggage = Category(_name: "Valiz ve Canta", _imageName: "luggage")
    let jewelery = Category(_name: "Mucevher", _imageName: "jewelery")
    let hoby = Category(_name: "Hobi", _imageName: "hoby")
    let industry = Category(_name: "Endustriyel", _imageName: "industry")
    let garden = Category(_name: "Bahce", _imageName: "garden")
    let camera = Category(_name: "Kamera & Optik", _imageName: "camera")
    let pet = Category(_name: "Evcil Hayvan", _imageName: "pet")

    let categoryArray = [womenClothing, footWaer, electronics, menClothing, health, baby, home, car, luggage, jewelery, hoby, industry, garden, camera, pet]

    for category in categoryArray {
        saveCategoryToFirebase(category)
    }
}
