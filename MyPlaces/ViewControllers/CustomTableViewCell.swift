//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

	@IBOutlet weak var imageOfPlace: UIImageView! {
		didSet {
			imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
		}
	}
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var ratingControl: RatingControl!

	func configure(name: String, location: String?, type: String?, imageData: Data, rating: Double) {
		nameLabel.text = name
		locationLabel.text = location
		typeLabel.text = type
		imageOfPlace.image = UIImage(data: imageData)
		ratingControl.rating = Int(rating)
	}
}
