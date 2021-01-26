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

	let mapManager = MapManager()
	var mapViewControllerDelegate: MapViewControllerDelegate?
	
	var place = Place()
	let annotationIdentifier = "annotationIdentifier"
	var incomeSegueId = ""


	var previousLocation: CLLocation? {
		didSet {
			mapManager.startTrackingUserLocation(for: mapView, location: previousLocation) { (currentLocation) in
				self.previousLocation = currentLocation
				DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
					self.mapManager.showUserLocation(mapView: self.mapView)
				}
			}
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
    }
	
	@IBAction
	func doneButtonPressed() {
		mapViewControllerDelegate?.getAddress(addressLabel.text)
		dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func goButtonPressed() {
		mapManager.getDirections(for: mapView) { (location) in
			self.previousLocation = location
		}
	}
	
	@IBAction
	func centerViewInUserLocation() {
		mapManager.showUserLocation(mapView: mapView)
	}
	
	@IBAction
	func closeViewController() {
		dismiss(animated: true, completion: nil)
	}
	
	private func setupMapView() {
		goButton.isHidden = true
		
		mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueId) {
			mapManager.locationManager.delegate = self
		}
		
		if incomeSegueId == "showPlace" {
			mapManager.setupPlacemark(place: place, mapView: mapView)
			pinImage.isHidden = true
			addressLabel.isHidden = true
			doneButton.isHidden = true
			goButton.isHidden = false
		}
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
		
		let center = mapManager.getCenterLocation(for: mapView)
		let geocoder = CLGeocoder()
		
		if incomeSegueId == "showPlace" && previousLocation != nil {
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
				self.mapManager.showUserLocation(mapView: self.mapView)
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
					self.addressLabel.text = "\(streetName!), \(buldNumber!)"
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
		mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueId)
	}
}
