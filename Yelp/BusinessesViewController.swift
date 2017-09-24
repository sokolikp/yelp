//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar = UISearchBar()
    var searchEnabled: Bool = false
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView delegate/dataSource references already set via storyboard
        // table autolayout settings        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
        navigationController?.navigationBar.barTintColor = UIColor.red
        
        performDefaultSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performDefaultSearch () {
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // refilter businesses
        filteredBusinesses = businesses?.filter({ (business) -> Bool in
            return (business.name?.lowercased().contains(searchText.lowercased())) ?? false
        })
        searchEnabled = !searchText.isEmpty
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchEnabled {
            return filteredBusinesses?.count ?? 0
        } else {
            return businesses?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if searchEnabled {
            cell.business = filteredBusinesses[indexPath.row]
        } else {
            cell.business = businesses[indexPath.row]
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : Any]) {
        print(filters)
        let categories = filters["categories"] as? [String] ?? nil
        let dealsSelection = filters["deals"] as! Bool
        let distanceSelection = filters["distance"] as? Int ?? nil
        let sortSelection = filters["sort"] as! Int
        
        Business.searchWithTerm(term: "Restaurants", sort: YelpSortMode(rawValue: sortSelection), categories: categories, deals: dealsSelection, distance: distanceSelection, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    @IBAction func onClickClear(_ sender: Any) {
        performDefaultSearch()
    }
}
