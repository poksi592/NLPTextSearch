//
//  Tokenisation.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 02.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation
import NaturalLanguage

class Tokenisation {
    
    func collectTokens(from string: String) -> [String] {
        
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = string
        let range = string.startIndex ..< string.endIndex
        
        let tokenRanges = tokenizer.tokens(for: range)
        let tokens = tokenRanges.map { String(string[$0]).lowercased() }
        
        return tokens
    }
    
    func collectLinguisticTokens(from string: String) -> [String] {

        let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .language], options: 0)

        tagger.string = string
        let nsRange = NSRange(location: 0, length: string.utf16.count)

        //Setting various options, such as ignoring white spaces and punctuations
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]

        var tokens = Set<String>()
        tagger.enumerateTags(in: nsRange,
                             unit: .word,
                             scheme: .lemma,
                             options: options) { tag, tokenRange, stop in
            
            let range = Range(tokenRange, in: string)
            let token = String(string[range!]).lowercased()
            tokens.insert(token)
                                
            if let tag = tag?.rawValue {
                tokens.insert(tag.lowercased())
            }
        }
        return Array(tokens)
    }
}
