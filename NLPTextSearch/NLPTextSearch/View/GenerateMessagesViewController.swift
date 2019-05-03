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
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        
        // MARK: Delete all data
        let allMessages = try! managedObjectContext.fetch(Message.fetchRequest()) as! [Message]
        managedObjectContext.performAndWait {
            for message in allMessages {
                managedObjectContext.delete(message)
            }
        }
        Persistence.shared.saveContext()
        
        for messageNumber in 1...numberOfMessages! {
            
            var message = ""
            for _ in 1...numberOfWordsInMessage! {
                
                let randomWordIndex = Int.random(in: 0..<christmasCarol.allChristmasCarolWords.count)
                message.append(christmasCarol.allChristmasCarolWords[randomWordIndex])
                message.append(" ")
            }

            var subject = ""
            for _ in 1...5 {
                
                let randomWordIndex = Int.random(in: 0..<christmasCarol.allChristmasCarolWords.count)
                subject.append(christmasCarol.allChristmasCarolWords[randomWordIndex])
                subject.append(" ")
            }
            
            let messageObject = Message(context: managedObjectContext)
            messageObject.messageID = Int32(messageNumber)
            messageObject.subject = "#" + String(messageNumber) + " " + subject
            messageObject.content = message
            
        }
        Persistence.shared.saveContext()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageListSegue",
            let messageListViewController = segue.destination as? MessageListViewController {
            
            messageListViewController.numberOfRows = Int(noOfMessages.text!)!
        }
    }
}

