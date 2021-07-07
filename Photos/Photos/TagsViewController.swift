//
//  TagsViewController.swift
//  Photos
//
//  Created by Priyal PORWAL on 06/07/21.
//

import UIKit
class TagsViewController: UITableViewController {
    var photo: Photo?
    var photoStore: PhotoStore?
    var selectedTagsIndexPath = [IndexPath]()
    var tagDataStore = TagDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = tagDataStore
        tableView.delegate = self
    }
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addBarButton(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "Add new tag", message: nil, preferredStyle: .alert)
        alertView.addTextField { textField in
            textField.placeholder = "tag name"
            textField.autocapitalizationType = .words
        }
        
        let okAction = UIAlertAction(title: "Add", style: .default) { action in
            if let tagName = alertView.textFields?.first?.text,
               let context = self.photoStore?.persistentContainer.viewContext {
                let tag = Tag(context: context)
                tag.setValue(tagName, forKey: "name")
                do {
                    try context.save()
                } catch {
                    print("Core data could not save data \(error)")
                }
                self.updateTags()
            }
        }
        alertView.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertView.addAction(cancelAction)
        present(alertView, animated: true, completion: nil)
    }
    
    private func updateTags() {
        photoStore?.fetchAllTags(completion: { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case let .success(tags):
                self.tagDataStore.tags = tags
                guard  let photoTags = self.photo?.tags as? Set<Tag> else {
                    return
                }
                for tag in photoTags {
                    if let index = tags.firstIndex(of: tag) {
                        self.selectedTagsIndexPath.append(IndexPath(row: index, section: 0))
                    }
                }
                
            case let .failure(error):
                Logger.log.logDynamic(" Error Fetching Logs: \(error)")
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        })
    }
}

extension TagsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tagDataStore.tags[indexPath.row]
        if let index = selectedTagsIndexPath.firstIndex(of: indexPath) {
            selectedTagsIndexPath.remove(at: index)
            photo?.removeFromTags(tag)
        } else {
            selectedTagsIndexPath.append(indexPath)
            photo?.addToTags(tag)
        }
        
        do {
            try photoStore?.persistentContainer.viewContext.save()
        } catch {
            Logger.log.logDynamic("\(error)")
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedTagsIndexPath.firstIndex(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}
