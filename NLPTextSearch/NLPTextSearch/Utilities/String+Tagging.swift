//
//  String+Tagging.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 07.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func tag(phrases: [String],
             size: CGFloat,
             bold: Bool,
             color: UIColor) -> NSAttributedString {
        
        let attrString = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attrString.length)
        
        // Font Size
        let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
        attrString.addAttribute(NSAttributedString.Key.font,
                                value: font,
                                range: NSRange(location: range.location,
                                               length: self.count))
        attrString.addAttribute(NSAttributedString.Key.font,
                                value: font,
                                range: NSRange(location: range.location,
                                               length: self.count))
        
        
        let inputLength = attrString.string.count
        
        for phrase in phrases {
            let searchLength = phrase.count
            var range = NSRange(location: 0, length: attrString.length)
            
            while (range.location != NSNotFound) {
                range = (attrString.string as NSString).range(of: phrase,
                                                              options: [],
                                                              range: range)
                if range.length == 0 { break }
                
                let rangeMinusOne = NSRange(location: range.location - 1, length: 1)
                var stringMinusOne = ""
                if range.location >= 0 {
                    stringMinusOne = (attrString.string as NSString).substring(with: rangeMinusOne)
                }
                if range.location != NSNotFound && (range.location == 0 || stringMinusOne == " ") {
                    
                    attrString.addAttribute(NSAttributedString.Key.backgroundColor,
                                            value: color,
                                            range: NSRange(location: range.location,
                                                           length: searchLength))
                }
                range = NSRange(location: range.location + range.length,
                                length: inputLength - (range.location + range.length))
            }
        }
        return NSAttributedString(attributedString: attrString)
    }
}
