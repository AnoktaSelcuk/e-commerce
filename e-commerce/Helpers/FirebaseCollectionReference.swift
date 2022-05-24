//
//  FirebaseCollectionReference.swift
//  internProject
//
//  Created by Alperen Selçuk on 4.08.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Category
    case Items
    case Basket
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
