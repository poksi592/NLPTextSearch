//
//  GenerateMessagesViewController.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 02.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import UIKit
import CoreData

class GenerateMessagesViewController: UIViewController {

    @IBOutlet weak var noOfMessages: UITextField!
    @IBOutlet weak var noOfWordsInMessage: UITextField!
    @IBOutlet weak var generateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func generateMessages(_ sender: Any) {
        
        let numberOfMessages = Int(noOfMessages.text!)
        let numberOfWordsInMessage = Int(noOfWordsInMessage.text!)
        let christmasCarol = ChristmasCarolMessages.shared
       
        christmasCarol.generateMessages(numberOfMessages: numberOfMessages!,
                                        numberOfWordsInMessage: numberOfWordsInMessage!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageListSegue",
            let messageListViewController = segue.destination as? MessageListViewController {
            
            messageListViewController.numberOfRows = Int(noOfMessages.text!)!
        }
    }
}

