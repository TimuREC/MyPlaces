//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {

	@IBOutlet weak var placeImage: UIImageView!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var placeName: UITextField!
	@IBOutlet weak var placeLocation: UITextField!
	@IBOutlet weak var placeType: UITextField!
	
	var currentPlace: Place?
	var imageIsChanged = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.tableFooterView = UIView(frame: CGRect(x: .zero,
														 y: .zero,
														 width: tableView.frame.size.width,
														 height: 1))
		
		placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
		
		setupEditScreen()
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 0 {
			
			let cameraIcon = UIImage(systemName: "camera")
			let photoIcon = UIImage(systemName: "photo")
			
			let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			
			let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
				// TODO: Call Camera method
				self.chooseImagePicker(source: .camera)
			}
			camera.setValue(cameraIcon, forKey: "image")
			camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			
			let photo = UIAlertAction(title: "Photo", style: .default) { (_) in
				// To Do: Choose image picker
				self.chooseImagePicker(source: .photoLibrary)
			}
			photo.setValue(photoIcon, forKey: "image")
			photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			actionSheet.addAction(camera)
			actionSheet.addAction(photo)
			actionSheet.addAction(cancel)
			present(actionSheet, animated: true, completion: nil)
			
		} else {
			view.endEditing(true)
		}
	}
	
	func savePlace() {
		let imageData = !imageIsChanged ? UIImage(systemName: "pin.circle")?.pngData() : placeImage.image?.pngData()
		
		let newPlace = Place(name: placeName.text!,
							 location: placeLocation.text!,
							 type: placeType.text!,
							 imageData: imageData)
		if currentPlace != nil {
			try! realm.write {
				currentPlace?.name = newPlace.name
				currentPlace?.location = newPlace.location
				currentPlace?.type = newPlace.type
				currentPlace?.imageData = newPlace.imageData
			}
		} else {
			StorageManager.saveObject(newPlace)
		}
	}
	
	@IBAction
	func cancelAction() {
		dismiss(animated: true, completion: nil)
	}
	
	private func setupEditScreen() {
		guard let currentPlace = currentPlace,
			  let data = currentPlace.imageData,
			  let image = UIImage(data: data)
		else { return }
		setupNavBar()
		
		placeImage.image = image
		placeName.text = currentPlace.name
		placeLocation.text = currentPlace.location
		placeType.text = currentPlace.type
	}
	
	private func setupNavBar() {
		if let topItem = navigationController?.navigationBar.topItem {
			topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		}
		navigationItem.leftBarButtonItem = nil
		title = currentPlace?.name
		saveButton.isEnabled = true
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

extension NewPlaceViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	@objc
	private func textFieldChanged() {
		if placeName.text == nil || placeName.text!.isEmpty {
			saveButton.isEnabled = false
		} else {
			saveButton.isEnabled = true
		}
	}
	
}

// MARK: Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func chooseImagePicker(source: UIImagePickerController.SourceType) {
		if UIImagePickerController.isSourceTypeAvailable(source) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.allowsEditing = true
			imagePicker.sourceType = source
			present(imagePicker, animated: true, completion: nil)
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		placeImage.image = info[.editedImage] as? UIImage
		placeImage.contentMode = .scaleAspectFill
		imageIsChanged = true
		dismiss(animated: true, completion: nil)
	}
	
}
