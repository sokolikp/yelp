//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Paul Sokolik on 9/19/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String: String]]!
    var switches = [Int: Bool]()          // store switch state for each row
        
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = [
            ["name": "American", "code": "americantrad"],
            ["name": "Chinese", "code": "chinese"],
            ["name": "Mediterranean", "code": "mediterranean"],
            ["name": "American", "code": "americantrad"],
            ["name": "Chinese", "code": "chinese"],
            ["name": "Mediterranean", "code": "mediterranean"],
            ["name": "American", "code": "americantrad"],
            ["name": "Chinese", "code": "chinese"],
            ["name": "Mediterranean", "code": "mediterranean"],
            ["name": "American", "code": "americantrad"],
            ["name": "Chinese", "code": "chinese"],
            ["name": "Mediterranean", "code": "mediterranean"]
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        cell.categoryLabel.text = categories[indexPath.row]["name"]
        cell.delegate = self
        
        cell.categorySwitch.isOn = switches[indexPath.row] ?? false
        
        return cell
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        var filters = [String: AnyObject]()
        var selectedCategories = [String]()
        for (idx, isOn) in switches {
            if isOn {
                selectedCategories.append(categories[idx]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        
        print(indexPath.row)
        
        switches[indexPath.row] = switchCell.categorySwitch.isOn
    }

}
