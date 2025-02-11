//
//  GenreViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/19/24.
//

import UIKit
import CoreData

protocol GenreViewControllerDelegate: AnyObject {
    func didAddGenre(Genre: GenreData)
    func didUpdateGenre(Genre: GenreData)
}

class GenreViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var GenreIdField: UITextField!
    @IBOutlet weak var GenreNameField: UITextField!
    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var logoImageView: UIImageView!


    let imagePicker = UIImagePickerController()
    
    weak var delegate: GenreViewControllerDelegate?
    
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
    
    @IBAction func AddGenre(_ sender: UIButton) {
        print("Add Genre button pressed")
        guard let idText = GenreIdField?.text, let genreId = Int(idText) ,
        let genreName = GenreNameField?.text, !genreName.isEmpty else {
            // handle case where required fields are empty
            let alert = UIAlertController(title: "Error", message: "Please fill out all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // check if an artist with the same id or name already exists
        let fetchRequest: NSFetchRequest<GenreData> = GenreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d OR name == %@", genreId, genreName)
        do {
            let existingGenres = try context.fetch(fetchRequest)
            if !existingGenres.isEmpty {
                var errorMessage = "Genre with the following already exists:\n"
                if existingGenres.contains(where: { $0.id == genreId }) {
                    errorMessage += "ID: \(genreId)"
                }
                if existingGenres.contains(where: { $0.name == genreName }) {
                    errorMessage += "\nGenre Name: \(genreName)"
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
        
        // create a new Genre object and set its properties
        let newGenre = GenreData(context: context)
        newGenre.id = Int64(genreId)
        newGenre.name = genreName
        
        // save changes to Core Data
        do {
            try context.save()
            let alert = UIAlertController(title: "Success", message: "Genre added successfully", preferredStyle: .alert)
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
    
    @IBAction func UpdateGenre(_ sender: UIButton) {
        
        
        print("Update Genre button pressed")
        guard let genreIdText = GenreIdField?.text, let genreId = Int(genreIdText),
              let genreName = GenreNameField?.text, !genreName.isEmpty
               
               else {
                   let alert = UIAlertController(title: "Error", message: "Please enter a valid details", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   present(alert, animated: true, completion: nil)
                   return
           }
           
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           let fetchRequest: NSFetchRequest<GenreData> = GenreData.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "id == %d", genreId)
           
           do {
               let result = try context.fetch(fetchRequest)
               
               if let genreToUpdate = result.first {
                   genreToUpdate.name = genreName
                   
                   
                   try context.save()
                   
                   let alert = UIAlertController(title: "Genre Updated Successfully", message: "Press OK to continue", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   present(alert, animated: true, completion: nil)
               } else {
                   let alert = UIAlertController(title: "Error", message: "Genre ID does not exist to update.", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   present(alert, animated: true, completion: nil)
               }
           } catch {
               let alert = UIAlertController(title: "Error", message: "Failed to update company", preferredStyle: .alert)
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
