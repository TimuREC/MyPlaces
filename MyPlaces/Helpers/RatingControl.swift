//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Timur Begishev on 22.01.2021.
//

import UIKit

@IBDesignable
class RatingControl: UIStackView {
	
	var rating = 0 {
		didSet {
			updateButtonSelectionStates()
		}
	}
	
	@IBInspectable var starSize: CGSize = CGSize(width: 44, height: 44) {
		didSet {
			setupButtons()
		}
	}
	@IBInspectable var starCount: Int = 5 {
		didSet {
			setupButtons()
		}
	}
	
	private var ratingButtons = [UIButton]()

    // MARK: Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupButtons()
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
		setupButtons()
	}
	
	@objc func ratingButtonTapped(button: UIButton) {
		guard let index = ratingButtons.firstIndex(of: button) else { return }
		
		let selectedRating = index + 1
		if selectedRating == rating {
			rating = 0
		} else {
			rating = selectedRating
		}
		
	}
	
	// MARK: Private methods
	
	private func setupButtons() {
		
		for button in ratingButtons {
			removeArrangedSubview(button)
			button.removeFromSuperview()
		}
		
		ratingButtons.removeAll()
//		Trouble with images from Assets, doesn't shows
		let bundle = Bundle(for: type(of: self))
		let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
		let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
		let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
		
		for _ in 0..<starCount {
			let button = UIButton()
			
			button.setImage(emptyStar, for: .normal)
			button.setImage(highlightedStar, for: .highlighted)
			button.setImage(highlightedStar, for: [.highlighted, .selected])
			button.setImage(filledStar, for: .selected)
			button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
			
			button.translatesAutoresizingMaskIntoConstraints = false
			button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
			button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
			
			addArrangedSubview(button)
			ratingButtons.append(button)
		}
		
		updateButtonSelectionStates()
	}
	
	private func updateButtonSelectionStates() {
		for (index, button) in ratingButtons.enumerated() {
			button.isSelected = index < rating
		}
	}

}
