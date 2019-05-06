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
    
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subject.text = subjectText
        content.text = contentText
    }
}
