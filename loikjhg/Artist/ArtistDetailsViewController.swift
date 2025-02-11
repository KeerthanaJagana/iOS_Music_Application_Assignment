//
//  ArtistDetailsViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/22/24.
//

import UIKit

class ArtistDetailsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Property to store the passed artist
    var Artist: ArtistData?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update the text of the UITextView
        if let artist = Artist {
            let text = "Artist ID: \(artist.id)\nArtist Name: \(artist.name ?? "")"
            textView.text = text
            
            // Update the image in the UIImageView
            if let imageData = artist.logo, let image = UIImage(data: imageData) {
                logoImageView.image = image
                logoImageView.contentMode = .scaleAspectFill
            }
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
