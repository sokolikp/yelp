//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Paul Sokolik on 9/19/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: Any])
}

enum SectionRowIdentifier : String {
    case Deal     = "Deals"
    case Distance = "Distance"
    case Category = "Category"
    case Sort     = "Sort by"
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var sections:   [[String: String]]!
    var deals:      [[String: String]]!
    var radii:      [[String: Any]]!
    var categories: [[String: String]]!
    var sorts:      [[String: Any]]!
    
    var tableStructure: [[[String: Any]]]!
    var filterStates: [[Int: Bool]]! // store state for each row
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = getCategories()
        radii = getRadii()
        sorts = getSorts()
        deals = getDeals()
        initSections()
        setNavbarStyles()
        setDefaultFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]["name"]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // only need to handle selections for CheckboxCells
        if (sections[indexPath.section]["type"] == String(describing: CheckboxCell.self)) {
            
            // set all values to false and then set selection to true
            for idx in filterStates[indexPath.section].keys {
                filterStates[indexPath.section][idx] = false
            }
            filterStates[indexPath.section][indexPath.row] = true
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (sections[indexPath.section]["type"] == String(describing: SwitchCell.self)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            let cellData = tableStructure[indexPath.section][indexPath.row]
            cell.categoryLabel.text = cellData["name"] as? String
            cell.categorySwitch.isOn = filterStates[indexPath.section][indexPath.row] ?? false
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.delegate = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxCell", for: indexPath) as! CheckboxCell
            let cellData = tableStructure[indexPath.section][indexPath.row]
            cell.checkboxLabel.text = cellData["name"] as? String
            cell.checkboxButton.isHidden = filterStates[indexPath.section][indexPath.row] != true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
 
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        var filters = [String: Any]()
        var dealsSelection: Bool?
        var distanceSelection: Int!
        var sortSelection: Int!
        var selectedCategories = [String]()
        
        for (sectionIdx, section) in filterStates.enumerated() {
            for (cellIdx, isOn) in section {
                if (sectionIdx == 0) { // deals
                    dealsSelection = isOn
                } else if (sectionIdx == 1) { //distance
                    if isOn {
                        distanceSelection = radii[cellIdx]["meters"] as! Int
                    }
                } else if (sectionIdx == 2) { // sort
                    if isOn {
                        sortSelection = sorts[cellIdx]["code"] as! Int
                    }
                } else if (sectionIdx == 3) { // category
                    if isOn {
                        selectedCategories.append(categories[cellIdx]["code"]!)
                    }
                }
            }
        }
        
        filters["deals"] = dealsSelection ?? false
        if (distanceSelection != 0) {
            filters["distance"] = distanceSelection
        }
        filters["sort"] = sortSelection
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as [String]
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        
        filterStates[indexPath.section][indexPath.row] = switchCell.categorySwitch.isOn
    }
    
    func initSections() {
        self.sections = [
            ["name": "Deals",    "type": String(describing: SwitchCell.self)],
            ["name": "Distance", "type": String(describing: CheckboxCell.self)],
            ["name": "Sort By",  "type": String(describing: CheckboxCell.self)],
            ["name": "Category", "type": String(describing: SwitchCell.self)]
        ]
        self.tableStructure = [deals, radii, sorts, categories]
        self.filterStates = [[Int: Bool]](repeating: [:], count: sections.count)
    }
    
    func getRadii() -> [[String: Any]] {
        return [
            ["name": "Default", "meters": 0],
            ["name": "0.5 mi",  "meters": 805],
            ["name": "1 mi",    "meters": 1609],
            ["name": "3 mi",    "meters": 4828],
            ["name": "5 mi",    "meters": 8045]
        ]
    }
    
    func getSorts() -> [[String: Any]] {
        return [
            ["name": "Best match",    "code": 0],
            ["name": "Distance",      "code": 1],
            ["name": "Highest rated", "code": 2],
        ]
    }
    
    func getDeals() -> [[String: String]] {
        return [["name": "Offering a deal"]]
    }
    
    func setDefaultFilters() {
        // init only check states to the first element in collection
        for (idx, section) in sections.enumerated() {
            if section["type"] == String(describing: CheckboxCell.self) {
                filterStates[idx][0] = true
            }
        }
    }
    
    func setNavbarStyles() {
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
    }
    
    // Hard-coded categories from yelp's API docs.
    // Downloaded and converted to dictionary.
    // See all possible categories here: https://www.yelp.com/developers/documentation/v2/all_category_list
    func getCategories() -> [[String: String]] {
        return [
            [ "name": "Afghan", "code": "afghani" ],
            [ "name": "African", "code": "african" ],
            [ "name": "Arabian", "code": "arabian" ],
            [ "name": "Argentine", "code": "argentine" ],
            [ "name": "Armenian", "code": "armenian" ],
            [ "name": "Asian Fusion", "code": "asianfusion" ],
            [ "name": "Australian", "code": "australian" ],
            [ "name": "Austrian", "code": "austrian" ],
            [ "name": "Bangladeshi", "code": "bangladeshi" ],
            [ "name": "Basque", "code": "basque" ],
            [ "name": "Barbeque", "code": "bbq" ],
            [ "name": "Belgian", "code": "belgian" ],
            [ "name": "Brasseries", "code": "brasseries" ],
            [ "name": "Brazilian", "code": "brazilian" ],
            [ "name": "Breakfast & Brunch", "code": "breakfast_brunch" ],
            [ "name": "British", "code": "british" ],
            [ "name": "Buffets", "code": "buffets" ],
            [ "name": "Burgers", "code": "burgers" ],
            [ "name": "Burmese", "code": "burmese" ],
            [ "name": "Cafes", "code": "cafes" ],
            [ "name": "Cafeteria", "code": "cafeteria" ],
            [ "name": "Cajun/Creole", "code": "cajun" ],
            [ "name": "Cambodian", "code": "cambodian" ],
            [ "name": "Caribbean", "code": "caribbean" ],
            [ "name": "Catalan", "code": "catalan" ],
            [ "name": "Cheesesteaks", "code": "cheesesteaks" ],
            [ "name": "Chicken Wings", "code": "chicken_wings" ],
            [ "name": "Chicken Shop", "code": "chickenshop" ],
            [ "name": "Chinese", "code": "chinese" ],
            [ "name": "Comfort Food", "code": "comfortfood" ],
            [ "name": "Creperies", "code": "creperies" ],
            [ "name": "Cuban", "code": "cuban" ],
            [ "name": "Czech", "code": "czech" ],
            [ "name": "Delis", "code": "delis" ],
            [ "name": "Diners", "code": "diners" ],
            [ "name": "Dinner Theater", "code": "dinnertheater" ],
            [ "name": "Ethiopian", "code": "ethiopian" ],
            [ "name": "Filipino", "code": "filipino" ],
            [ "name": "Fish & Chips", "code": "fishnchips" ],
            [ "name": "Fondue", "code": "fondue" ],
            [ "name": "Food Court", "code": "food_court" ],
            [ "name": "Food Stands", "code": "foodstands" ],
            [ "name": "French", "code": "french" ],
            [ "name": "Game Meat", "code": "gamemeat" ],
            [ "name": "Gastropubs", "code": "gastropubs" ],
            [ "name": "German", "code": "german" ],
            [ "name": "Gluten-Free", "code": "gluten_free" ],
            [ "name": "Greek", "code": "greek" ],
            [ "name": "Guamanian", "code": "guamanian" ],
            [ "name": "Halal", "code": "halal" ],
            [ "name": "Hawaiian", "code": "hawaiian" ],
            [ "name": "Himalayan/Nepalese", "code": "himalayan" ],
            [ "name": "Hong Kong Style Cafe", "code": "hkcafe" ],
            [ "name": "Honduran", "code": "honduran" ],
            [ "name": "Hot Dogs", "code": "hotdog" ],
            [ "name": "Fast Food", "code": "hotdogs" ],
            [ "name": "Hot Pot", "code": "hotpot" ],
            [ "name": "Hungarian", "code": "hungarian" ],
            [ "name": "Iberian", "code": "iberian" ],
            [ "name": "Indonesian", "code": "indonesian" ],
            [ "name": "Indian", "code": "indpak" ],
            [ "name": "Irish", "code": "irish" ],
            [ "name": "Italian", "code": "italian" ],
            [ "name": "Japanese", "code": "japanese" ],
            [ "name": "Kebab", "code": "kebab" ],
            [ "name": "Korean", "code": "korean" ],
            [ "name": "Kosher", "code": "kosher" ],
            [ "name": "Laotian", "code": "laotian" ],
            [ "name": "Latin American", "code": "latin" ],
            [ "name": "Malaysian", "code": "malaysian" ],
            [ "name": "Mediterranean", "code": "mediterranean" ],
            [ "name": "Mexican", "code": "mexican" ],
            [ "name": "Middle Eastern", "code": "mideastern" ],
            [ "name": "Modern European", "code": "modern_european" ],
            [ "name": "Mongolian", "code": "mongolian" ],
            [ "name": "Moroccan", "code": "moroccan" ],
            [ "name": "American (New)", "code": "newamerican" ],
            [ "name": "New Mexican Cuisine", "code": "newmexican" ],
            [ "name": "Nicaraguan", "code": "nicaraguan" ],
            [ "name": "Noodles", "code": "noodles" ],
            [ "name": "Pakistani", "code": "pakistani" ],
            [ "name": "Pan Asian", "code": "panasian" ],
            [ "name": "Persian/Iranian", "code": "persian" ],
            [ "name": "Peruvian", "code": "peruvian" ],
            [ "name": "Pizza", "code": "pizza" ],
            [ "name": "Polish", "code": "polish" ],
            [ "name": "Pop-Up Restaurants", "code": "popuprestaurants" ],
            [ "name": "Portuguese", "code": "portuguese" ],
            [ "name": "Poutineries", "code": "poutineries" ],
            [ "name": "Live/Raw Food", "code": "raw_food" ],
            [ "name": "Russian", "code": "russian" ],
            [ "name": "Salad", "code": "salad" ],
            [ "name": "Sandwiches", "code": "sandwiches" ],
            [ "name": "Scandinavian", "code": "scandinavian" ],
            [ "name": "Scottish", "code": "scottish" ],
            [ "name": "Seafood", "code": "seafood" ],
            [ "name": "Singaporean", "code": "singaporean" ],
            [ "name": "Slovakian", "code": "slovakian" ],
            [ "name": "Soul Food", "code": "soulfood" ],
            [ "name": "Soup", "code": "soup" ],
            [ "name": "Southern", "code": "southern" ],
            [ "name": "Spanish", "code": "spanish" ],
            [ "name": "Sri Lankan", "code": "srilankan" ],
            [ "name": "Steakhouses", "code": "steak" ],
            [ "name": "Supper Clubs", "code": "supperclubs" ],
            [ "name": "Sushi Bars", "code": "sushi" ],
            [ "name": "Syrian", "code": "syrian" ],
            [ "name": "Taiwanese", "code": "taiwanese" ],
            [ "name": "Tapas Bars", "code": "tapas" ],
            [ "name": "Tapas/Small Plates", "code": "tapasmallplates" ],
            [ "name": "Tex-Mex", "code": "tex-mex" ],
            [ "name": "Thai", "code": "thai" ],
            [ "name": "American (Traditional)", "code": "tradamerican" ],
            [ "name": "Turkish", "code": "turkish" ],
            [ "name": "Ukrainian", "code": "ukrainian" ],
            [ "name": "Uzbek", "code": "uzbek" ],
            [ "name": "Vegan", "code": "vegan" ],
            [ "name": "Vegetarian", "code": "vegetarian" ],
            [ "name": "Vietnamese", "code": "vietnamese" ],
            [ "name": "Waffles", "code": "waffles" ],
            [ "name": "Wraps", "code": "wraps" ]
        ]
    }

}









