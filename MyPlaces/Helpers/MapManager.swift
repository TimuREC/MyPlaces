//
//  MapManager.swift
//  MyPlaces
//
//  Created by Timur Begishev on 26.01.2021.
//

import UIKit
import MapKit

class MapManager {
	
	let locationManager = CLLocationManager()
	
	private let regionInMeters = 1000.0
	private var placeCoordinate: CLLocationCoordinate2D?
	private var directionsArray = [MKDirections]()
	
	func setupPlacemark(place: Place, mapView: MKMapView) {
		guard let location = place.location else { return }
		
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(location) { (placemarks, error) in
			if let error = error {
				print(error)
				return
			}
			guard let placemarks = placemarks else { return }
			let placemark = placemarks.first
			
			let annotation = MKPointAnnotation()
			annotation.title = place.name
			annotation.subtitle = place.type
			
			guard let placemarkLocation = placemark?.location else { return }
			annotation.coordinate = placemarkLocation.coordinate
			self.placeCoordinate = placemarkLocation.coordinate
			
			mapView.showAnnotations([annotation], animated: true)
			mapView.selectAnnotation(annotation, animated: true)
		}
	}
	
	func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse:
			mapView.showsUserLocation = true
			if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
			break
		case .denied:
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.showAlert(title: "Error", message: "Authorization required")
			}
			break
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .restricted:
			showAlert(title: "Error", message: "Authorization required")
			break
		case .authorizedAlways:
			break
		@unknown default:
			print("New case")
		}
	}
	
	func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> Void) {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
			closure()
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.showAlert(title: "Error", message: "Location services disabled")
			}
		}
	}
	
	func showUserLocation(mapView: MKMapView) {
		guard let location = locationManager.location?.coordinate else { return }
		let region = MKCoordinateRegion(center: location,
										latitudinalMeters: regionInMeters,
										longitudinalMeters: regionInMeters)
		mapView.setRegion(region, animated: true)
	}
	
	func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
		guard let location = locationManager.location?.coordinate else {
			showAlert(title: "Error", message: "Location not found")
			return
		}
		locationManager.startUpdatingLocation()
		previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
		
		guard let request = createDirectionsRequest(from: location) else {
			showAlert(title: "Error", message: "Destination not found")
			return
		}
		
		let directions = MKDirections(request: request)
		resetMapView(withNew: directions, mapView: mapView)
		
		directions.calculate { (response, error) in
			if let error = error {
				print(error)
				return
			}
			
			guard let response = response else {
				self.showAlert(title: "Error", message: "Direction is not available")
				return
			}
			
			for route in response.routes {
				mapView.addOverlay(route.polyline)
				mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
				
				let distance = String(format: "%.1f", route.distance / 1000)
				let timeInterval = route.expectedTravelTime
				
				print("Distance: \(distance) km, Time: \(timeInterval)")
			}
		}
	}
	
	private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
		guard let destinationCoordinate = placeCoordinate else { return nil }
		
		let startingLocation = MKPlacemark(coordinate: coordinate)
		let destination = MKPlacemark(coordinate: destinationCoordinate)
		
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: startingLocation)
		request.destination = MKMapItem(placemark: destination)
		request.transportType = .automobile
		request.requestsAlternateRoutes = true
		
		return request
	}
	
	func startTrackingUserLocation(for mapView: MKMapView, location: CLLocation?, closure: (_ currentLocation: CLLocation) -> Void) {
		guard let location = location else { return }
		
		let center = getCenterLocation(for: mapView)
		guard center.distance(from: location) > 50 else { return }
		closure(center)
	}
	
	private func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
		mapView.removeOverlays(mapView.overlays)
		directionsArray.append(directions)
		let _ = directionsArray.map { $0.cancel() }
		directionsArray.removeAll()
	}
	
	func getCenterLocation(for mapView: MKMapView) -> CLLocation {
		let latitude = mapView.centerCoordinate.latitude
		let longitude = mapView.centerCoordinate.longitude
		
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
	private func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		
		alert.addAction(okAction)
		
		let alertWindow = UIWindow(frame: UIScreen.main.bounds)
		alertWindow.rootViewController = UIViewController()
		alertWindow.windowLevel = UIWindow.Level.alert + 1
		alertWindow.makeKeyAndVisible()
		alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
	}
}
