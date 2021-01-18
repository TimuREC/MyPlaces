//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit

class MainViewController: UITableViewController {
	
	let places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
		let place = places[indexPath.row]

		cell.nameLabel.text = place.name
		cell.imageOfPlace.image = UIImage(named: place.image)
		cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
		cell.locationLabel.text = place.location
		cell.typeLabel.text = place.type

        return cell
    }
	
	// MARK: - Table view delegate

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func cancelAction(_ segue: UIStoryboardSegue) {
		
	}

}
