//
//  GenreDetailsViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/19/24.
//

import UIKit
import CoreData
class GenreDetailsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Property to store the passed genre
    var Genre: GenreData?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update the text of the UITextView
        if let genre = Genre {
            let text = "Genre ID: \(genre.id)\nGenre Name: \(genre.name ?? "")"
            textView.text = text
            
            // Update the image in the UIImageView
            if let imageData = genre.logo, let image = UIImage(data: imageData) {
                logoImageView.image = image
                logoImageView.contentMode = .scaleAspectFill
            }
        }
    }
}
