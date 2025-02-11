//
//  ArtistViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/22/24.
//

import UIKit
import CoreData

protocol ArtistViewControllerDelegate: AnyObject {
    func didAddArtist(Artist: ArtistData)
    func didUpdateArtist(Artist: ArtistData)
}

class ArtistViewController: UIViewController , UIImagePickerControllerDelegate & UINavigationControllerDelegate{

    @IBOutlet weak var ArtistIdField: UITextField!
    @IBOutlet weak var ArtistNameField: UITextField!
   
    @IBOutlet weak var logoImageView: UIImageView!

    let imagePicker = UIImagePickerController()
    
    weak var delegate: ArtistViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pickImageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            logoImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func GoBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddArtist(_ sender: UIButton) {
        print("Add Artist button pressed")
        guard let idText = ArtistIdField?.text, let artistId = Int(idText) ,
        let artistName = ArtistNameField?.text, !artistName.isEmpty else {
            // handle case where required fields are empty
            let alert = UIAlertController(title: "Error", message: "Please fill out all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let imageData = logoImageView.image?.jpegData(compressionQuality: 1.0) else {
                    let alert = UIAlertController(title: "Error", message: "Failed to convert image to data", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // check if an artist with the same id or name already exists
        let fetchRequest: NSFetchRequest<ArtistData> = ArtistData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d OR name == %@", artistId, artistName)
        do {
            let existingArtists = try context.fetch(fetchRequest)
            if !existingArtists.isEmpty {
                var errorMessage = "Artist with the following already exists:\n"
                if existingArtists.contains(where: { $0.id == artistId }) {
                    errorMessage += "ID: \(artistId)"
                }
                if existingArtists.contains(where: { $0.name == artistName }) {
                    errorMessage += "\nArtist Name: \(artistName)"
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
        
        
        let newArtist = ArtistData(context: context)
        newArtist.id = Int64(artistId)
        newArtist.name = artistName
        newArtist.logo = imageData
        // save changes to Core Data
        do {
            try context.save()
            let alert = UIAlertController(title: "Success", message: "Artist added successfully", preferredStyle: .alert)
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
    
    @IBAction func UpdateArtist(_ sender: UIButton) {
        
        
        print("Update Artist button pressed")
        guard let artistIdText = ArtistIdField?.text, let artistId = Int(artistIdText),
              let artistName = ArtistNameField?.text, !artistName.isEmpty
               
               else {
                   let alert = UIAlertController(title: "Error", message: "Please enter valid details", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   present(alert, animated: true, completion: nil)
                   return
           }
           
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           let fetchRequest: NSFetchRequest<ArtistData> = ArtistData.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "id == %d", artistId)
           
           do {
               let result = try context.fetch(fetchRequest)
               
               if let artistToUpdate = result.first {
                   artistToUpdate.name = artistName
                   
                   
                   try context.save()
                   
                   let alert = UIAlertController(title: "Artist Updated Successfully", message: "Press OK to continue", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   present(alert, animated: true, completion: nil)
               } else {
                   let alert = UIAlertController(title: "Error", message: "Artist ID does not exist to update.", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   present(alert, animated: true, completion: nil)
               }
           } catch {
               let alert = UIAlertController(title: "Error", message: "Failed to update artist", preferredStyle: .alert)
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
