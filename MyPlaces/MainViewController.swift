//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit

class MainViewController: UITableViewController {
	
	let restaurants = ["Vai Gogi", "DumBala", "Rock'n'Rolls", "Mishka", "InDe", "Hookah Place"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
		let restaurant = restaurants[indexPath.row]

		cell.nameLabel.text = restaurant
		cell.imageOfPlace.image = UIImage(named: restaurant)
		cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2

        return cell
    }
	
	// MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 85
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
