//
//  ChristmasCarolMessages.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 03.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation

class ChristmasCarolMessages {
    
    static let shared = ChristmasCarolMessages()
    let tokenMessageDictionary: [String : [Int]]
    let allChristmasCarolWords: [String]
    
    init() {
        
        let christmasCarolText = ChristmasCarolMessages.christmasCarol()
        let tokenisation = Tokenisation()
        let dictionary = Dictionary(uniqueKeysWithValues: zip(tokenisation.collectLinguisticTokens(from: christmasCarolText), [[Int]]()))
        self.tokenMessageDictionary = dictionary
        self.allChristmasCarolWords = tokenisation.collectTokens(from: christmasCarolText)
    }
    
    private class func christmasCarol() -> String {
        
        let filepath = Bundle.main.path(forResource: "A Christmas Carol", ofType: "txt")
        let url = URL(fileURLWithPath: filepath!)
        return try! String(contentsOf: url)
    }
    
}
