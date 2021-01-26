//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 25.01.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
	func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

	var mapViewControllerDelegate: MapViewControllerDelegate?
	var place = Place()
	let annotationIdentifier = "annotationIdentifier"
	let locationManager = CLLocationManager()
	let regionInMeters = 1000.0
	var incomeSegueId = ""
	var placeCoordinate: CLLocationCoordinate2D?
	var directionsArray = [MKDirections]()
	var previousLocation: CLLocation? {
		didSet {
			startTrackingUserLocation()
		}
	}
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var pinImage: UIImageView!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var goButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		addressLabel.text = ""
		
		mapView.delegate = self
		
		setupMapView()
		checkLocationServices()
    }
	
	
	@IBAction
	func doneButtonPressed() {
		mapViewControllerDelegate?.getAddress(addressLabel.text)
		dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func goButtonPressed() {
		getDirections()
	}
	
	@IBAction
	func centerViewInUserLocation() {
		showUserLocation()
	}
	
	@IBAction
	func closeViewController() {
		dismiss(animated: true, completion: nil)
	}
	
	private func setupMapView() {
		goButton.isHidden = true
		if incomeSegueId == "showPlace" {
			setupPlacemark()
			pinImage.isHidden = true
			addressLabel.isHidden = true
			doneButton.isHidden = true
			goButton.isHidden = false
		}
	}
	
	private func resetMapView(withNew directions: MKDirections) {
		mapView.removeOverlays(mapView.overlays)
		directionsArray.append(directions)
		let _ = directionsArray.map { $0.cancel() }
		directionsArray.removeAll()
	}
	
	private func setupPlacemark() {
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
			annotation.title = self.place.name
			annotation.subtitle = self.place.type
			
			guard let placemarkLocation = placemark?.location else { return }
			annotation.coordinate = placemarkLocation.coordinate
			self.placeCoordinate = placemarkLocation.coordinate
			
			self.mapView.showAnnotations([annotation], animated: true)
			self.mapView.selectAnnotation(annotation, animated: true)
		}
	}
	
	private func checkLocationServices() {
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			checkLocationAuthorization()
		} else {
			showAlert(title: "Error", message: "Location services disabled")
		}
	}
	
	private func setupLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	private func checkLocationAuthorization() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse:
			mapView.showsUserLocation = true
			if incomeSegueId == "getAddress" { showUserLocation() }
			break
		case .denied:
			showAlert(title: "Error", message: "Authorization required")
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
	
	private func showUserLocation() {
		guard let location = locationManager.location?.coordinate else { return }
		let region = MKCoordinateRegion(center: location,
										latitudinalMeters: regionInMeters,
										longitudinalMeters: regionInMeters)
		mapView.setRegion(region, animated: true)
	}
	
	private func startTrackingUserLocation() {
		guard let previousLocation = previousLocation else { return }
		
		let center = getCenterLocation(for: mapView)
		guard center.distance(from: previousLocation) > 50 else { return }
		self.previousLocation = center
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.showUserLocation()
		}
		
	}
	
	private func getDirections() {
		guard let location = locationManager.location?.coordinate else {
			showAlert(title: "Error", message: "Location not found")
			return
		}
		locationManager.startUpdatingLocation()
		previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
		
		guard let request = createDirectionsRequest(from: location) else {
			showAlert(title: "Error", message: "Destination not found")
			return
		}
		
		let directions = MKDirections(request: request)
		resetMapView(withNew: directions)
		
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
				self.mapView.addOverlay(route.polyline)
				self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
				
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
	
	private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
		let latitude = mapView.centerCoordinate.latitude
		let longitude = mapView.centerCoordinate.longitude
		
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
	private func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		
		alert.addAction(okAction)
		present(alert, animated: true, completion: nil)
	}
	
}

extension MapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKUserLocation) else { return nil }
		
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
		
		if annotationView == nil {
			annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
			annotationView?.canShowCallout = true
			
		}
		if let imageData = place.imageData {
			let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
			imageView.layer.cornerRadius = 10
			imageView.clipsToBounds = true
			imageView.image = UIImage(data: imageData)
			annotationView?.rightCalloutAccessoryView = imageView
		}
		
		return annotationView
		
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let center = getCenterLocation(for: mapView)
		let geocoder = CLGeocoder()
		
		if incomeSegueId == "showPlace" && previousLocation != nil {
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
				self.showUserLocation()
			}
		}
		geocoder.cancelGeocode()
		geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
			if let error = error {
				print(error)
				return
			}
			
			guard let placemarks = placemarks else { return }
			let placemark = placemarks.first
			let streetName = placemark?.thoroughfare
			let buldNumber = placemark?.subThoroughfare
			DispatchQueue.main.async {
				if streetName != nil, buldNumber != nil {
					self.addressLabel.text = streetName! + buldNumber!
				} else if streetName != nil {
					self.addressLabel.text = streetName!
				} else {
					self.addressLabel.text = ""
				}
			}
		}
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
		renderer.strokeColor = .blue
		
		return renderer
	}
	
}

extension MapViewController: CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		checkLocationAuthorization()
	}
}
