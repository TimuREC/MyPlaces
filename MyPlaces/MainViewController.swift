//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
	
	var places: Results<Place>!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var reversedSortingButton: UIBarButtonItem!
	
	var ascendingSorting = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
//		navigationItem.leftBarButtonItem = UIBarButtonItem
		
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
			destVC.currentPlace = places[index]
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

extension MainViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.isEmpty ? 0 : places.count
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
		let place = places[indexPath.row]
		// TO DO: - Refactor
		cell.nameLabel.text = place.name
		cell.locationLabel.text = place.location
		cell.typeLabel.text = place.type
		cell.imageOfPlace.image = UIImage(data: place.imageData!)
		
		cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2

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

