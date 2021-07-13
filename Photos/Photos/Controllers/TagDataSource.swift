//
//  TagDataSource.swift
//  Photos
//
//  Created by Priyal PORWAL on 06/07/21.
//

import UIKit
import CoreData

class TagDataSource: NSObject, UITableViewDataSource {
    var tags = [Tag]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tagTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell", for: indexPath)
        tagTableViewCell.textLabel?.text = tags[indexPath.row].name
        tagTableViewCell.accessibilityTraits = [.button]
        tagTableViewCell.accessibilityHint = "Toggles Selection"
        return tagTableViewCell
    }
    
    
}
