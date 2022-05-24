//
//  AlgoliaService.swift
//  internProject
//
//  Created by Alperen Selçuk on 17.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation
import InstantSearchClient


class AlgoliaService {

    static let shared = AlgoliaService()
    
    let client = Client(appID: kALGOLIA_APP_ID, apiKey: kALGOLIA_ADMIN_KEY)
    let index = Client(appID: kALGOLIA_APP_ID, apiKey: kALGOLIA_ADMIN_KEY).index(withName: "item_name")
    
    private init() {}
    
}
