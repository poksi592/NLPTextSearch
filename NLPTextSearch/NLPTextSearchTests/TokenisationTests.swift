//
//  TokensTests.swift
//  NLPTextSearchTests
//
//  Created by Mladen Despotovic on 02.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import NLPTextSearch

class TokenisationTests: XCTestCase {

    func test_collectTokensValidText() {
        
        let tokenisation = Tokenisation()
        let tokens = tokenisation.collectTokens(from: "This is a nice short  . - m, . story")
        
        XCTAssertEqual(tokens.count, 7)
    }
    
    func test_collectLinguisticTokensValidText() {
        
        let tokenisation = Tokenisation()
        let tokens = tokenisation.collectLinguisticTokens(from: "This Biking walking walker . - m, . story")
        
        XCTAssertEqual(tokens.count, 8)
    }
    
    func test_collectLinguisticTokensChristmasCarol() {
        
        let tokenisation = Tokenisation()
        let tokens = tokenisation.collectLinguisticTokens(ChristmasCarolMessages.shared.christmasCarol())
        
        XCTAssertEqual(tokens.count, 788)
    }

}
