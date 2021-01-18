//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit

struct Place {
	
	let name: String
	let location: String?
	let type: String?
	var image: UIImage?
	
	static func getPlaces() -> [Place] {
		let restaurants = ["Vai Gogi", "DumBala", "Rock'n'Rolls", "Mishka", "InDe", "Hookah Place"]
		var places = [Place]()
		
		for place in restaurants {
			places.append(Place(name: place, location: "Набережные Челны", type: "Ресторан", image: UIImage(named: place)))
		}
		
		return places
	}
	
}
