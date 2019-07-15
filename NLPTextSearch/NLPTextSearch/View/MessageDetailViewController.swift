//
//  MessageDetailViewController.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 05.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class MessageDetailViewController: UIViewController {
    
    var subjectText = ""
    var contentText = ""
    var selectedMessageID = 0
    var searchPhrases = [String]()
    
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subject.attributedText = subjectText.tag(phrases: searchPhrases,
                                                 size: 24.0,
                                                 bold: true,
                                                 color: UIColor.cyan)
        content.attributedText = contentText.tag(phrases: searchPhrases,
                                                 size: 20.0,
                                                 bold: true,
                                                 color: UIColor.cyan)
        updateImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationItem.searchController?.isActive = false
        super.viewWillDisappear(animated)
    }
    
    func updateImage() {
        
        if let imagePath = ChristmasCarolMessages.shared.imagePath(forMessageID: selectedMessageID) {
            
            let image = UIImage(named: imagePath)
            photo.image = image
        }
    }
    
    func tag(string: String,
             phrases: [String],
             size: CGFloat,
             bold: Bool) -> NSAttributedString {
        
        let attrString = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: attrString.length)
        
        // Font Size
        let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
        attrString.addAttribute(NSAttributedString.Key.font,
                                value: font,
                                range: NSRange(location: range.location,
                                               length: string.count))
        attrString.addAttribute(NSAttributedString.Key.font,
                                value: font,
                                range: NSRange(location: range.location,
                                               length: string.count))
        
        
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
                                            value: UIColor.cyan,
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
