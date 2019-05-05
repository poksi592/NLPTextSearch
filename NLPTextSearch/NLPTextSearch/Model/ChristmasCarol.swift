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
    var tokenMessageDictionary: [String : Set<Int>]
    let allChristmasCarolWords: [String]
    let tokenisation = Tokenisation()
    
    init() {
        
        let christmasCarolText = ChristmasCarolMessages.christmasCarol()
        let linguisticTokens = tokenisation.collectLinguisticTokens(from: christmasCarolText)
        let dictionary = linguisticTokens.reduce([String : Set<Int>](), { dict, token in
            
            var varDict = dict
            varDict[token] = Set<Int>()
            return varDict
        })
        
        self.tokenMessageDictionary = dictionary
        self.allChristmasCarolWords = tokenisation.collectTokens(from: christmasCarolText)
    }
    
    private class func christmasCarol() -> String {
        
        let filepath = Bundle.main.path(forResource: "A Christmas Carol", ofType: "txt")
        let url = URL(fileURLWithPath: filepath!)
        return try! String(contentsOf: url)
    }
    
}

extension ChristmasCarolMessages {
    
    func generateMessages(numberOfMessages: Int, numberOfWordsInMessage: Int) {
        
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
        
        for messageNumber in 1...numberOfMessages {
            
            var message = ""
            for _ in 1...numberOfWordsInMessage {
                
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
            
            tokenizeMessage(messageObject)
        }
        Persistence.shared.saveContext()
    }
    
    func tokenizeMessage(_ message: Message) {
        
        let subjectTokens = tokenisation.collectLinguisticTokens(from: message.subject!)
        let contentTokens = tokenisation.collectLinguisticTokens(from: message.content!)
        let tokenSet = Set(subjectTokens).union(Set(contentTokens))
        
        tokenSet.forEach { token in

            var messageNumbers = tokenMessageDictionary[token]
            messageNumbers?.insert(Int(message.messageID))
            tokenMessageDictionary[token] = messageNumbers
        }
    }
}
