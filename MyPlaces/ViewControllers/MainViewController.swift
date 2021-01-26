//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
	
	private let searchController = UISearchController(searchResultsController: nil)
	private var places: Results<Place>!
	private var filteredPlaces: Results<Place>!
	private var ascendingSorting = true
	private var searchBarIsEmpty: Bool {
		guard let text = searchController.searchBar.text else { return false }
		return text.isEmpty
	}
	private var isFiltering: Bool {
		return searchController.isActive && !searchBarIsEmpty
	}
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var reversedSortingButton: UIBarButtonItem!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search"
		navigationItem.searchController = searchController
		definesPresentationContext = true
		
		places = realm.objects(Place.self)
    }
	
	@IBAction func sortSelection(_ sender: UISegmentedControl) {
		sorting()
	}
	
	@IBAction func reverseSorting(_ sender: UIBarButtonItem) {
		ascendingSorting.toggle()
		reversedSortingButton.image = ascendingSorting ?  UIImage(systemName: "arrow.down") : UIImage(systemName: "arrow.up")
		sorting()
	}
	
	private func sorting() {
		if segmentedControl.selectedSegmentIndex == 0 {
			places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
		} else {
			places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
		}
		tableView.reloadData()
	}
	
	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "showDetail":
			guard let index = tableView.indexPathForSelectedRow?.row,
				  let destVC = segue.destination as? NewPlaceViewController
			else { return }
			destVC.currentPlace = isFiltering ? filteredPlaces[index] : places[index]
			destVC.imageIsChanged = true
		default:
			return
		}
	}
	
	@IBAction func unwind(_ segue: UIStoryboardSegue) {
		guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
		newPlaceVC.savePlace()
		tableView.reloadData()
	}

}

extension MainViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	
	private func filterContentForSearchText(_ searchText: String) {
		filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText, searchText, searchText)
		tableView.reloadData()
	}
	
}

extension MainViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering {
			return filteredPlaces.count
		} else {
			return places.isEmpty ? 0 : places.count
		}
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
		
		let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
		
		cell.configure(name: place.name,
					   location: place.location,
					   type: place.type,
					   imageData: place.imageData!,
					   rating: place.rating)

        return cell
    }
}

extension MainViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let place = places[indexPath.row]
		let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completion) in
			StorageManager.deleteObject(place)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			completion(true)
		}
		deleteAction.image = UIImage(systemName: "trash")
		return UISwipeActionsConfiguration(actions: [deleteAction])
		
	}
}

