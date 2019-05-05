//
//  MessageListViewController.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 03.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MessageListViewController: UITableViewController {

    var numberOfRows: Int?
    private(set) var messages = [Message]()
    private(set) var searchedMessageIndexes = [Int]()
    private(set) var fetchedResultsController: NSFetchedResultsController<Message>?
    
    var resultSearchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 120.0
        
        setupFetchResultsController()
    }
    
    func setupFetchResultsController() {
        
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.fetchLimit = 100
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "messageID", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchMessages(fetchRequest: fetchRequest)
    }
    
    func fetchMessages(fetchRequest: NSFetchRequest<Message>) {
        
        if searchedMessageIndexes.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "SELF.messageID contains[cd] ANY %K IN %@", 1)
        }
        
        try! fetchedResultsController?.performFetch()
        numberOfRows = fetchedResultsController?.fetchedObjects?.count
        tableView.reloadData()
    }
}

extension MessageListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchPhrase = searchController.searchBar.text?.lowercased(),
            searchPhrase.count > 0 {

            let foundTokens = ChristmasCarolMessages.shared.tokens.filter { token in
                
                if token.prefix(searchPhrase.count) == searchPhrase {
                    return true
                }
                else {
                    return false
                }
            }
            
            let resultMessages = foundTokens.reduce(Set<Int>(), { result, token in
                
                var varResult = result
                let messageIndexes = ChristmasCarolMessages.shared.tokenMessageDictionary[token]
                messageIndexes?.forEach { varResult.insert($0) }
                return messageIndexes!
            })
            
            searchedMessageIndexes = Array(resultMessages)
        }
    }
    
    func setupSearchController() {
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        resultSearchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = resultSearchController.searchBar
    }
}

extension MessageListViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows! > 100 ? 100 : numberOfRows!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as! MessageListCell
        
        guard let message = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.subjectLabel?.text = message.subject
        cell.contentLabel?.text = message.content
        return cell
    }
}
