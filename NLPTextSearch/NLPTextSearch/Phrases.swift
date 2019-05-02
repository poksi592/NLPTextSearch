//
//  Phrases.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 02.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation

class Phrases {
    
    static let shared = Phrases()
    
    lazy var phraseDictionary: [String : [Int]] = {
        
        collectPhrases()
    }
    
    func collectPhrases() {}
}
