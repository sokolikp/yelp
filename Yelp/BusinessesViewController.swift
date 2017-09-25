//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, FiltersViewControllerDelegate {
    
    // MARK: controller variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewSettingButton: UIBarButtonItem!
    var searchBar: UISearchBar = UISearchBar()
    var searchEnabled: Bool = false
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var isMoreDataLoading: Bool = false
    var loadingMoreView: InfiniteScrollActivityView?
    var offset: Int = 0
    var isListView: Bool = false
    let PAGE_SIZE = 20
    
    // MARK: lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // note: tableView delegate/dataSource references already set via storyboard
        // table autolayout settings
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        mapView.isHidden = true
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        
        initInfiniteScroll()
        performDefaultSearch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
    // MARK: delegate handlers
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                offset += PAGE_SIZE
                loadingMoreView!.startAnimating()
                
                loadMoreData(offset: offset)
            }
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : Any]) {
        print(filters)
        let categories = filters["categories"] as? [String] ?? nil
        let dealsSelection = filters["deals"] as! Bool
        let distanceSelection = filters["distance"] as? Int ?? nil
        let sortSelection = filters["sort"] as! Int
        
        Business.searchWithTerm(term: "Restaurants", offset: 0, sort: YelpSortMode(rawValue: sortSelection), categories: categories, deals: dealsSelection, distance: distanceSelection, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    // MARK: helper functions
    func performDefaultSearch () {
        offset = 0
        Business.searchWithTerm(term: "Restaurants", offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func loadMoreData (offset: Int) {
        Business.searchWithTerm(term: "Restaurants", offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.loadingMoreView!.stopAnimating()
            self.isMoreDataLoading = false
            self.businesses! += businesses!
            self.tableView.reloadData()
        })
    }
    
    func initInfiniteScroll() {
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
         tableView.tableFooterView = loadingMoreView
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func initMapPins () {
        for business in businesses {
            print(business.name!)
            addAnnotationAtAddress(address: business.address!, title: business.name!)
        }
    }
    
    func addAnnotationAtAddress(address: String, title: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    // MARK: Actions
    @IBAction func onClickViewSetting(_ sender: Any) {
        tableView.isHidden = !tableView.isHidden
        mapView.isHidden = !mapView.isHidden
        
        if !mapView.isHidden {
            viewSettingButton.title = "List"
            let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
            goToLocation(location: centerLocation)
            initMapPins()
        } else {
            viewSettingButton.title = "Map"
        }
    }
    
    @IBAction func onClickClear(_ sender: Any) {
        performDefaultSearch()
    }
}
