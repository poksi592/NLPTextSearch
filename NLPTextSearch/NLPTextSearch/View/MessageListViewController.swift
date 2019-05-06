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
    private(set) var searchedMessageIndexes = [Int32]()
    private(set) var fetchedResultsController: NSFetchedResultsController<Message>?
    private(set) var fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
    
    var resultSearchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 120.0
        
        setupSearchController()
        setupFetchResultsController()
    }
    
    func setupFetchResultsController() {
        
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        fetchRequest.fetchLimit = 100
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "messageID", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        searchedMessageIndexes = Array<Int32>(0...Int32(ChristmasCarolMessages.shared.tokens.count-1))
        fetchMessages()
    }
    
    func fetchMessages() {
        
        fetchRequest.predicate = NSPredicate(format: "SELF.messageID IN %@", searchedMessageIndexes)
        try! fetchedResultsController?.performFetch()
        numberOfRows = fetchedResultsController?.fetchedObjects?.count
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageDetailSegue",
            let messageDetailViewController = segue.destination as? MessageDetailViewController,
            let messageCell = sender as? MessageListCell {
            
            messageDetailViewController.subjectText = messageCell.subjectLabel.text!
            messageDetailViewController.contentText = messageCell.contentLabel.text!
        }
    }
}

extension MessageListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercased(),
            searchText.count > 0 else { return }
        
        var searchedMessageIndexSet = Set<Int32>()
        let searchPhrases = searchText.split(separator: " ")
        searchPhrases.forEach {searchPhrase in
            
            let foundTokens = ChristmasCarolMessages.shared.tokens.filter { token in
                
                if token.prefix(searchPhrase.count) == searchPhrase {
                    return true
                }
                else {
                    return false
                }
            }
            
            let resultMessages = foundTokens.reduce(Set<Int32>(), { result, token in
                
                let messageIndexes = ChristmasCarolMessages.shared.tokenMessageDictionary[token]
                let newResult = result.union(messageIndexes!)
                return newResult
            })
            
            if searchedMessageIndexSet.count > 0 {
                searchedMessageIndexSet = searchedMessageIndexSet.intersection(resultMessages)
            }
            else {
                searchedMessageIndexSet = resultMessages
            }
        }
        
        searchedMessageIndexes = Array(searchedMessageIndexSet)
        fetchMessages()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! MessageListCell
        performSegue(withIdentifier: "messageDetailSegue", sender: selectedCell)
    }
}
