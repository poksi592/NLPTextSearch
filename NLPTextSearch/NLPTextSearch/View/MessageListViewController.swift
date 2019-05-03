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
    private(set) var fetchedResultsController: NSFetchedResultsController<Message>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 120.0
        
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.fetchLimit = 100
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "messageID", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        try! fetchedResultsController?.performFetch()
        numberOfRows = fetchedResultsController?.fetchedObjects?.count
        
        tableView.reloadData()
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
