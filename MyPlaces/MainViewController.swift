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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let restaurant = restaurants[indexPath.row]

		cell.textLabel?.text = restaurant
		cell.imageView?.image = UIImage(named: restaurant)
		cell.imageView?.layer.cornerRadius = cell.frame.size.height / 2
		cell.imageView?.clipsToBounds = true
		cell.imageView?.contentMode = .scaleAspectFit

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
