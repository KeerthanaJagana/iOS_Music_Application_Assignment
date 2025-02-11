//
//  SongViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/23/24.
//

import UIKit
import CoreData

protocol SongViewControllerDelegate: AnyObject {
    func didAddSong(Song: SongData)
    func didUpdateSong(Song: SongData)
}

class SongViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate  {

    @IBOutlet weak var SongIdField: UITextField!
    @IBOutlet weak var SongNameField: UITextField!
    @IBOutlet weak var SongArtistIdField: UITextField!
    @IBOutlet weak var SongAlbumIdField: UITextField!
    @IBOutlet weak var SongGenreIdField: UITextField!
    @IBOutlet weak var SongDurationField: UITextField!
    @IBOutlet weak var SongFavouriteField: UITextField!
   
    weak var delegate: SongViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func GoBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addSong(_ sender: UIButton) {
        
        print("Add Product Post button pressed")
        guard let songIdText = SongIdField?.text, let songId = Int(songIdText),
              let songNameText = SongNameField?.text, !songNameText.isEmpty,
              let artistIdText = SongArtistIdField?.text, let artistId = Int(artistIdText),
              let albumIdText = SongAlbumIdField?.text, let albumId = Int(albumIdText),
              let durationText = SongDurationField?.text, let songDurationId = Double(durationText),
              let genreidText = SongGenreIdField?.text, let genreId = Int(genreidText),
              let songFavText = SongFavouriteField?.text?.lowercased()
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let songFavBool: Bool
        switch songFavText {
        case "true", "yes", "1":
            songFavBool = true
        case "false", "no", "0":
            songFavBool = false
        default:
            let alert = UIAlertController(title: "Error", message: "Invalid value for Favorite. Please use 'yes', 'no', '0', '1', 'true', or 'false'.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            songFavBool = false
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Check if artist exists
        let artistFetchRequest: NSFetchRequest<ArtistData> = ArtistData.fetchRequest()
        artistFetchRequest.predicate = NSPredicate(format: "id == %@", String(artistId))
        do {
            let artists = try context.fetch(artistFetchRequest)
            if artists.count == 0 {
                let alert = UIAlertController(title: "Error", message: "Artist ID does not exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch let error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Check if album exists
        let albumFetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        albumFetchRequest.predicate = NSPredicate(format: "id == %ld", albumId)
        do {
            let albums = try context.fetch(albumFetchRequest)
            if albums.count == 0 {
                let alert = UIAlertController(title: "Error", message: "Album ID does not exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Check if genre exists
        let genreFetchRequest: NSFetchRequest<GenreData> = GenreData.fetchRequest()
        genreFetchRequest.predicate = NSPredicate(format: "id == %ld", genreId)
        do {
            let genres = try context.fetch(genreFetchRequest)
            if genres.count == 0 {
                let alert = UIAlertController(title: "Error", message: "Genre ID does not exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Check if song already exists
        let songFetchRequest: NSFetchRequest<SongData> = SongData.fetchRequest()
        songFetchRequest.predicate = NSPredicate(format: "id == %ld", songId)
        do {
            let songs = try context.fetch(songFetchRequest)
            if songs.count > 0 {
                let alert = UIAlertController(title: "Error", message: "Song with the following already exists:\nID: \(songId)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Create new Song object
        let newSong = SongData(context: context)
        newSong.id = Int64(songId)
        newSong.album_id = Int64(albumId)
        newSong.artist_id = Int64(artistId)
        newSong.genre_id = Int64(genreId)
        newSong.name = songNameText
        newSong.favourite = songFavBool
        newSong.duration = Double(songDurationId)

        // Save changes
        do {
            try context.save()
            let alert = UIAlertController(title: "Success", message: "Song added successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

}
    
    @IBAction func updateSong(_ sender: UIButton) {
        print("Update Song button pressed")

        guard let songIdText = SongIdField?.text,
              let songId = Int(songIdText),
              let songNameText = SongNameField?.text,
              !songNameText.isEmpty,
              let artistIdText = SongArtistIdField?.text,
              let artistId = Int(artistIdText),
              let albumIdText = SongAlbumIdField?.text,
              let albumId = Int(albumIdText),
              let durationText = SongDurationField?.text,
              let songDurationId = Double(durationText),
              let genreidText = SongGenreIdField?.text,
              let genreId = Int(genreidText),
              let songFavText = SongFavouriteField?.text?.lowercased()
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        var songFavBool: Bool
        switch songFavText {
        case "true", "yes", "1":
            songFavBool = true
        case "false", "no", "0":
            songFavBool = false
        default:
            let alert = UIAlertController(title: "Error", message: "Invalid value for Favorite. Please use 'yes', 'no', '0', '1', 'true', or 'false'.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            songFavBool = false
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Check if artist exists
        let artistFetchRequest: NSFetchRequest<ArtistData> = ArtistData.fetchRequest()
        artistFetchRequest.predicate = NSPredicate(format: "id == %@", String(artistId))
        do {
            let artists = try context.fetch(artistFetchRequest)
            if artists.isEmpty {
                let alert = UIAlertController(title: "Error", message: "Artist ID does not exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch let error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Check if album exists
        let albumFetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        albumFetchRequest.predicate = NSPredicate(format: "id == %ld", albumId)
        do {
            let albums = try context.fetch(albumFetchRequest)
            if albums.isEmpty {
                let alert = UIAlertController(title: "Error", message: "Album ID does not exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Check if Genre exists
        let genreRequest: NSFetchRequest<GenreData> = GenreData.fetchRequest()
        genreRequest.predicate = NSPredicate(format: "id == %ld", genreId)
        do {
            let genres = try context.fetch(genreRequest)
            if genres.isEmpty {
                let alert = UIAlertController(title: "Error", message: "Genre ID does not exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Update the song
        let fetchRequestToUpdate: NSFetchRequest<SongData> = SongData.fetchRequest()
        fetchRequestToUpdate.predicate = NSPredicate(format: "id == %ld", songId)
        do {
            let result = try context.fetch(fetchRequestToUpdate)
            
            if let songToUpdate = result.first {
                songToUpdate.id = Int64(songId)
                
                // Check if the artist ID is different from the existing one
                    if songToUpdate.artist_id != Int64(artistId) {
                        let alert = UIAlertController(title: "Error", message: "You are not allowed to update the Artist ID", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    // Check if the album ID is different from the existing one
                    if songToUpdate.album_id != Int64(albumId) {
                        let alert = UIAlertController(title: "Error", message: "You are not allowed to update the Album ID", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    // Check if the genre ID is different from the existing one
                    if songToUpdate.genre_id != Int64(genreId) {
                        let alert = UIAlertController(title: "Error", message: "You are not allowed to update the Genre ID", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                        return
                    }
                
                songToUpdate.album_id = Int64(albumId)
                songToUpdate.artist_id = Int64(artistId)
                songToUpdate.genre_id = Int64(genreId)
                songToUpdate.name = songNameText
                songToUpdate.duration = Double(songDurationId)
                songToUpdate.favourite = songFavBool
                
                try context.save()
                
                let alert = UIAlertController(title: "Song Updated Successfully", message: "Press OK to continue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Song ID does not exist to update.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: "Failed to update song", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
