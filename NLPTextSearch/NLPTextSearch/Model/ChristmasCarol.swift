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
    var tokenMessageDictionary: [String : Set<Int64>]
    var tokens = [String]()
    let allChristmasCarolWords: [String]
    let tokenisation = Tokenisation()
    
    init() {
        
        let christmasCarolText = ChristmasCarolMessages.christmasCarol()
        let linguisticTokens = tokenisation.collectLinguisticTokens(from: christmasCarolText)
        let dictionary = linguisticTokens.reduce([String : Set<Int64>](), { dict, token in
            
            var varDict = dict
            varDict[token] = Set<Int64>()
            return varDict
        })
        
        self.tokenMessageDictionary = dictionary
        self.tokens = dictionary.map { $0.key }
        self.allChristmasCarolWords = tokenisation.collectTokens(from: christmasCarolText)
    }
    
    private class func christmasCarol() -> String {
        
        let filepath = Bundle.main.path(forResource: "10000_Words", ofType: "txt")
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
        let allIndexes = try! managedObjectContext.fetch(Index.fetchRequest()) as! [Index]
        managedObjectContext.performAndWait {
            for index in allIndexes {
                managedObjectContext.delete(index)
            }
        }
        let allIndexedMessages = try! managedObjectContext.fetch(IndexedMessages.fetchRequest()) as! [IndexedMessages]
        managedObjectContext.performAndWait {
            for indexedMessages in allIndexedMessages {
                managedObjectContext.delete(indexedMessages)
            }
        }
        Persistence.shared.saveContext()
        
        /// MARK: - getting all picture filenames
        let path = Bundle.main.bundlePath
        let fileManager = FileManager.default
        let filenames = try? fileManager.contentsOfDirectory(atPath: path)
        let jpegFilenames = filenames?.filter { $0.hasSuffix(".jpg") } ?? [String]()
        let pngFilenames = filenames?.filter { $0.hasSuffix(".png") } ?? [String]()
        let pictureFilenames = jpegFilenames + pngFilenames
        
        var pictureIndexes = [Int : Int]()
        for pictureIndex in 0..<pictureFilenames.count {
            
            pictureIndexes[Int.random(in: 0..<numberOfMessages)] = pictureIndex
        }
        
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
            messageObject.messageID = Int64(messageNumber)
            messageObject.subject = "#" + String(messageNumber) + " " + subject
            messageObject.content = message
            if let filenameIndex = pictureIndexes[messageNumber] {
                messageObject.attachmentFilename = pictureFilenames[filenameIndex]
            }
            
            tokenizeMessage(messageObject)
        }
       
        tokenMessageDictionary.forEach { (key, value) in
            
            let indexObject = Index(context: managedObjectContext)
            indexObject.token = key
            
            value.forEach { messageId in
                
                let indexedMessages = IndexedMessages(context: managedObjectContext)
                indexedMessages.messageID = messageId
                indexObject.addToIndexedMessages(indexedMessages)
            }
        }
        
        Persistence.shared.saveContext()
        
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(tokenMessageDictionary)
        let size = jsonData.count
        print("Word count in dictionary: \(tokenMessageDictionary.count)")
        print("Size in bytes: \(size)")
        let persistentStore = Persistence.shared.persistentContainer.persistentStoreCoordinator.persistentStores.first
        let url = Persistence.shared.persistentContainer.persistentStoreCoordinator.url(for: persistentStore!)
        print("Persistent store URL: \(url.relativeString)")
        
//        let attribute = try! FileManager.default.attributesOfItem(atPath: url.relativeString)
//        let sizeULongLong = attribute[FileAttributeKey.size] as! NSNumber
//        let sizeMb = sizeULongLong.doubleValue / 1000000.0
//    
//        print("Size of Persistent Store in Mb: \(sizeMb)")
    }
    
    func tokenizeMessage(_ message: Message) {
        
        let subjectTokens = tokenisation.collectLinguisticTokens(from: message.subject!)
        let contentTokens = tokenisation.collectLinguisticTokens(from: message.content!)
        let tokenSet = Set(subjectTokens).union(Set(contentTokens))
        
        tokenSet.forEach { token in

            var messageNumbers = tokenMessageDictionary[token]
            messageNumbers?.insert(Int64(message.messageID))
            tokenMessageDictionary[token] = messageNumbers
        }
    }
}
