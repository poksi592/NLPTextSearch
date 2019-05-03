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
    
    var numberOfRows: Int = 0
    private(set) var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 120.0
        
        let managedObjectContext = Persistence.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.fetchLimit = 100
        messages = try! managedObjectContext.fetch(fetchRequest)
        
        tableView.reloadData()
        
        print(messages)
    }
}

extension MessageListViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows > 100 ? 100 : numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as! MessageListCell
        cell.subjectLabel?.text = messages[indexPath.row].subject
        cell.contentLabel?.text = messages[indexPath.row].content
        return cell
    }
}
