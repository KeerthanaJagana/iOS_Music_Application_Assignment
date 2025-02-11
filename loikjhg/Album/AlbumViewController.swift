//
//  AlbumViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/23/24.
//

import UIKit
import CoreData

protocol AlbumViewControllerDelegate: AnyObject {
    func didAddAlbum(Album: AlbumData)
    func didUpdateAlbum(Album: AlbumData)
}

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var AlbumIdField: UITextField!
    @IBOutlet weak var AlbumNameField: UITextField!
    @IBOutlet weak var AlbumReleaseDateField: UITextField!
    @IBOutlet weak var AlbumArtistIdField: UITextField!
  
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: AlbumViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func GoBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addAlbum(_ sender: UIButton) {
        print("Add Album button pressed")
        guard let albumIdText = AlbumIdField?.text, let albumId = Int(albumIdText),
              let albumNameText = AlbumNameField?.text, !albumNameText.isEmpty,
              
              let artistIdText = AlbumArtistIdField?.text, let artistId = Int(artistIdText)
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
        let fetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld OR name == %@", albumId, albumNameText)
        do {
            let existingAlbums = try context.fetch(fetchRequest)
            if existingAlbums.count > 0 {
                var errorMessage = "Album with the following already exists:\n"
                if existingAlbums.contains(where: { $0.id == albumId }) {
                    errorMessage += "ID: \(albumId)\n"
                }
                if existingAlbums.contains(where: { $0.name == albumNameText }) {
                    errorMessage += "Album Name: \(albumNameText)\n"
                }
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
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

        // Check if artist exists
        let artistFetchRequest: NSFetchRequest<ArtistData> = ArtistData.fetchRequest()
        artistFetchRequest.predicate = NSPredicate(format: "id == %ld", artistId)
        do {
            let artists = try context.fetch(artistFetchRequest)
            if artists.count == 0 {
                let alert = UIAlertController(title: "Error", message: "Artist ID does not exist", preferredStyle: .alert)
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
//        dateFormatter.dateFormat = "yyyy-MM-dd" // Replace with your desired date format
//        guard let date = dateFormatter.date(from: albumDateText) else {
//            let alert = UIAlertController(title: "Error", message: "Invalid Date Format \(String(describing: albumDateText))", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//            return
//        }

        let selectedDate = datePicker.date
        // Create new album object
        let newAlbum = AlbumData(context: context)
        newAlbum.id = Int64(albumId)
        newAlbum.name = albumNameText
        newAlbum.artist_id = Int64(artistId)
        newAlbum.release_date = selectedDate
        // Save changes

        // save changes to Core Data
        do {
            try context.save()
            let alert = UIAlertController(title: "Success", message: "Album added successfully", preferredStyle: .alert)
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
    
    @IBAction func updateAlbum(_ sender: UIButton) {
        print("Update Album Post button pressed")
        guard let albumIdText = AlbumIdField?.text, let albumId = Int(albumIdText),
              let albumNameText = AlbumNameField?.text, !albumNameText.isEmpty,
             
              let artistIdText = AlbumArtistIdField?.text, let artistId = Int(artistIdText)
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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


        // Update the album
        let fetchRequestToUpdate: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        fetchRequestToUpdate.predicate = NSPredicate(format: "id == %ld", albumId)
        do {
            let result = try context.fetch(fetchRequestToUpdate)
            
            if let albumToUpdate = result.first {
                if albumToUpdate.artist_id != Int64(artistId) {
                        let alert = UIAlertController(title: "Error", message: "You are not allowed to update the Artist ID", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                        return
                    }
                let date = datePicker.date
                albumToUpdate.id = Int64(albumId)
                albumToUpdate.artist_id = Int64(artistId)
                albumToUpdate.release_date = date
                albumToUpdate.name = albumNameText
                
                try context.save()
                
                let alert = UIAlertController(title: "Album Updated Successfully", message: "Press OK to continue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Album Id does not exist to update.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: "Failed to update album", preferredStyle: .alert)
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
