//
//  SongDetailsViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/23/24.
//

import UIKit

class SongDetailsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var Song: SongData?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update the text of the UITextView
        if let song = Song {
            let text = "Song ID: \(song.id)\nSong Name: \(song.name ?? "")Artist ID: \(song.artist_id)\nAlbum ID: \(song.album_id)\nGenre ID: \(song.genre_id)\nDuration: \(song.duration)\nFavourite: \(song.favourite)\n"
            textView.text = text
            

           
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
