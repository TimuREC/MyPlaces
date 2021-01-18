//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Timur Begishev on 18.01.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {

	@IBOutlet weak var imageOfPlace: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.tableFooterView = UIView()
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
		imageOfPlace.image = info[.editedImage] as? UIImage
		imageOfPlace.contentMode = .scaleAspectFill
		dismiss(animated: true, completion: nil)
	}
	
}