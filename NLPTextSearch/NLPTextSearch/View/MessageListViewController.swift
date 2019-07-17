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

class MessageListViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {

    var numberOfRows: Int?
    private(set) var messages = [Message]()
    private(set) var searchedMessageIndexes = [Int64]()
    private(set) var messageFetchedResultsController: NSFetchedResultsController<Message>?
    private(set) var messageFetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
    private(set) var searchPhrases = [String]()
    private var selectedRow: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 120.0
        
        setupSearchController()
        setupFetchResultsController()
    }
    
    func setupFetchResultsController() {
        
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        messageFetchRequest.fetchLimit = 1000
        messageFetchRequest.sortDescriptors = [NSSortDescriptor(key: "messageID", ascending: true)]
        
        messageFetchedResultsController = NSFetchedResultsController(fetchRequest: messageFetchRequest,
                                                                     managedObjectContext: managedObjectContext,
                                                                     sectionNameKeyPath: nil,
                                                                     cacheName: nil)
        searchedMessageIndexes = Array<Int64>(0...Int64(ChristmasCarolMessages.shared.tokens.count-1))
        fetchMessages()
    }
    
    func fetchMessages() {
        
        messageFetchRequest.predicate = NSPredicate(format: "SELF.messageID IN %@", searchedMessageIndexes)
        try! messageFetchedResultsController?.performFetch()
        numberOfRows = messageFetchedResultsController?.fetchedObjects?.count
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageDetailSegue",
            let messageDetailViewController = segue.destination as? MessageDetailViewController,
            let messageCell = sender as? MessageListCell {
            
            messageDetailViewController.subjectText = messageCell.subjectLabel.text!
            messageDetailViewController.contentText = messageCell.contentLabel.text!
            messageDetailViewController.selectedMessageID = selectedRow
            messageDetailViewController.searchPhrases = searchPhrases
        }
    }
}

extension MessageListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercased(),
            searchText.count > 0 else { return }
        
        searchPhrases = searchText.split(separator: " ").map { String($0) }
        searchedMessageIndexes = mailIds(forPhrases: searchPhrases)
        fetchMessages()
    }
    
    func setupSearchController() {
        
        let resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.obscuresBackgroundDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        resultSearchController.searchBar.sizeToFit()
        self.navigationItem.searchController  = resultSearchController
    }
    
    func mailIds(forPhrases phrases:[String]) -> [Int64] {
        
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        let indexesFetchRequest: NSFetchRequest<Index> = Index.fetchRequest()
        var predicates = [NSPredicate]()
        for phrase in phrases {
            predicates.append(NSPredicate(format: "SELF.token BEGINSWITH %@", phrase))
        }
        
        indexesFetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        let indexes = try! managedObjectContext.fetch(indexesFetchRequest)
        
        var mailIDs = Set<Int64>()
        indexes.forEach { index in

            for indexedMessage in index.indexedMessages ?? Set<IndexedMessages>() {
                mailIDs.update(with: indexedMessage.messageID)
            }
        }
        return Array(mailIDs)
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
        
        guard let message = messageFetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.subjectLabel?.attributedText = message.subject?.tag(phrases: searchPhrases,
                                                                 size: 22.0,
                                                                 bold: true,
                                                                 color: UIColor.cyan)
        cell.contentLabel?.attributedText = message.content?.tag(phrases: searchPhrases,
                                                                 size: 18.0,
                                                                 bold: false,
                                                                 color: UIColor.cyan)
        if let _ = ChristmasCarolMessages.shared.imagePath(forMessageID: indexPath.row) {
            cell.attachmentIcon.isHidden = false
        } else {
            cell.attachmentIcon.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! MessageListCell
        selectedRow = indexPath.row
        performSegue(withIdentifier: "messageDetailSegue", sender: selectedCell)
    }
}
