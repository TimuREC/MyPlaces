//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
	
	var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		 places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
	
	// MARK: - Table view delegate

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let place = places[indexPath.row]
		let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completion) in
			StorageManager.deleteObject(place)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			completion(true)
		}
		deleteAction.image = UIImage(systemName: "trash")
		return UISwipeActionsConfiguration(actions: [deleteAction])
		
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
