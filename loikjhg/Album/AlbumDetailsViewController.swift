//
//  AlbumDetailsViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/23/24.
//

import UIKit
import CoreData
class AlbumDetailsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    
    // Property to store the passed company
    var Album: AlbumData?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update the text of the UITextView
        if let album = Album {
            let text = "ID: \(album.id)\nName: \(album.name ?? "")\nArtist ID: \(album.artist_id)\nDate: \(album.release_date ?? Date())"
            textView.text = text

        }
    }


}
