//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import Foundation

struct Place {
	
	let name: String
	let location: String
	let type: String
	var image: String
	
	static func getPlaces() -> [Place] {
		let restaurants = ["Vai Gogi", "DumBala", "Rock'n'Rolls", "Mishka", "InDe", "Hookah Place"]
		var places = [Place]()
		
		for place in restaurants {
			places.append(Place(name: place, location: "Набережные Челны", type: "Ресторан", image: place))
		}
		
		return places
	}
	
}
