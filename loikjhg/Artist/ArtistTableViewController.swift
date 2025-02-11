//
//  ArtistTableViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/22/24.
//

import UIKit
import CoreData
class ArtistTableViewController:UITableViewController,ArtistViewControllerDelegate {

    weak var delegate: ArtistViewControllerDelegate?
    var Artists: [ArtistData] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        tableView.reloadData()
        super.viewDidLoad()
        
        fetchArtists()
        // Register the cell class with the table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Reload table view to display fetched data
        tableView.reloadData()
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Artists"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }

    // MARK: - Table view data source
    func fetchArtists(with searchText: String? = nil) {
       
        let fetchRequest: NSFetchRequest<ArtistData> = ArtistData.fetchRequest()
        
        // Add a predicate to filter the results based on the search text
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        }
        
        do {
           
            Artists = try context.fetch(fetchRequest)
            
            // Reload table view to display fetched data
            tableView.reloadData()
        } catch {
            print("Error fetching artists: \(error.localizedDescription)")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Artists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let artist = Artists[indexPath.row]
        
        
        cell.textLabel?.text = artist.name
        
       
        cell.detailTextLabel?.text = String(artist.id)
        
        // Convert the binary data of the logo attribute to a UIImage object
        if let logoData = artist.logo {
            if let logoImage = UIImage(data: logoData) {
                // Set the logo image as the cell's image view
                cell.imageView?.image = logoImage
            }
        } else {
            // Handle case where logo data is nil, e.g., display a placeholder image or hide the image view
            cell.imageView?.image = nil
        }
        // Configure the appearance of the logo in the cell's image view
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.clipsToBounds = true
        
        // Add a details disclosure button
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let selectedArtist = Artists[indexPath.row]

        
        performSegue(withIdentifier: "showArtistDetails", sender: selectedArtist)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
       
        let selectedArtist = Artists[indexPath.row]

        
        performSegue(withIdentifier: "showArtistDetails", sender: selectedArtist)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArtistDetails" {
            if let artistDetailsVC = segue.destination as? ArtistDetailsViewController {
                if let selectedArtist = sender as? ArtistData {
                   
                    artistDetailsVC.Artist = selectedArtist
                }
            }
        } else if segue.identifier == "addartist" {
            if let artistDetailsVC = segue.destination as? ArtistViewController {
                artistDetailsVC.delegate = self
            }
        }else if segue.identifier == "updateartist" {
            if let updateArtistVC = segue.destination as? ArtistViewController {
                updateArtistVC.delegate = self
            }
        }
    }

    func didAddArtist(Artist: ArtistData) {
       
        Artists.append(Artist)

       
       
        tableView.reloadData()
    }
    
    func didUpdateArtist(Artist: ArtistData) {
        do {
               try context.save()
               print("Artist updated successfully")
               // Reload the table view to display the updated data
               tableView.reloadData()
           } catch {
               print("Error updating artist: \(error.localizedDescription)")
           }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let selectedArtist = Artists[indexPath.row]
            let artistId = selectedArtist.id
            
            // Check if any albums are associated with this artist
            let orderFetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
            orderFetchRequest.predicate = NSPredicate(format: "artist_id == %ld", artistId)
            
            do {
                let orders = try context.fetch(orderFetchRequest)
                if !orders.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "There are albums associated with this artist id. Please disassociate or delete them before deleting the artist.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }
            }
            catch let error {
                // Handle any errors that occur during fetch
                let alert = UIAlertController(title: "Error", message: "Failed to fetch artists associated with id with error: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
         
            
    

           
            context.delete(selectedArtist)
            do {
                try context.save()
                
                Artists.remove(at: indexPath.row)
                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting artist: \(error.localizedDescription)")
            }
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ArtistTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Get the search text from the search bar
        if let searchText = searchController.searchBar.text {
            // Call a method to fetch companies with the search text
            fetchArtists(with: searchText)
        }
    }
}
