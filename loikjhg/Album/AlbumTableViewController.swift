//
//  AlbumTableViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/23/24.
//

import UIKit
import CoreData

class AlbumTableViewController: UITableViewController, AlbumViewControllerDelegate {

    weak var delegate: AlbumViewControllerDelegate?
    var Albums: [AlbumData] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch companies from CoreData
        fetchAlbums()
        // Register the cell class with the table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Reload table view to display fetched data
        tableView.reloadData()
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Albums"
        navigationItem.searchController = searchController
        definesPresentationContext = true
       
    }

    func fetchAlbums(with searchText: String? = nil) {
        // Fetch request for Company entity
        let fetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        
        // Add a predicate to filter the results based on the search text
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "id CONTAINS[cd] %@", searchText)
        }
        
        do {
           
            Albums = try context.fetch(fetchRequest)
            
            // Reload table view to display fetched data
            tableView.reloadData()
        } catch {
            print("Error fetching albums: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let album = Albums[indexPath.row]
        
     
        cell.textLabel?.text = String(album.id)
        
    
        cell.detailTextLabel?.text = String(album.id)
        
        // Add a details disclosure button
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected company from the companies array
        let selectedAlbums = Albums[indexPath.row]
        
        // Perform segue to CompanyDetailsViewController with the selected company
        performSegue(withIdentifier: "showAlbumDetails", sender: selectedAlbums)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // Get the selected company from the companies array
        let selectedAlbums = Albums[indexPath.row]
        
        // Perform segue to CompanyDetailsViewController with the selected company
        performSegue(withIdentifier: "showAlbumDetails", sender: selectedAlbums)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbumDetails" {
            if let albumDetailsVC = segue.destination as? AlbumDetailsViewController {
                if let selectedAlbum = sender as? AlbumData {
                    // Pass the selectedCompany object to CompanyDetailsViewController
                    albumDetailsVC.Album = selectedAlbum
                }
            }
        } else if segue.identifier == "addalbum" {
            if let addAlbumVC = segue.destination as? AlbumViewController {
                addAlbumVC.delegate = self
            }
        }else if segue.identifier == "updatealbum" {
            if let updateAlbumVC = segue.destination as? AlbumViewController {
                updateAlbumVC.delegate = self
            }
        }
    }
    
    func didAddAlbum(Album: AlbumData) {
        // Append the newly added company to the companies array
        Albums.append(Album)
        
        // Reload the table view to display the new data
        tableView.reloadData()
    }
    func didUpdateAlbum(Album: AlbumData) {
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let selectedAlbum = Albums[indexPath.row]
            let albumId = selectedAlbum.id // Assuming 'id' is the property
            
            let orderFetchRequest: NSFetchRequest<SongData> = SongData.fetchRequest()
            orderFetchRequest.predicate = NSPredicate(format: "album_id == %ld", albumId)
            
            do {
                let songs = try context.fetch(orderFetchRequest)
                if !songs.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "There are songs associated with this album id. Please disassociate or delete them before deleting the album.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }
            }
            catch let error {
                // Handle any errors that occur during fetch
                let alert = UIAlertController(title: "Error", message: "Failed to fetch albums associated with album id with error: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
         
            // Delete the selected post from Core Data
            context.delete(selectedAlbum)
            do {
                try context.save()
                // Remove the selected company from the posts array
                Albums.remove(at: indexPath.row)
                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting album: \(error.localizedDescription)")
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
extension AlbumTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Get the search text from the search bar
        if let searchText = searchController.searchBar.text {
            // Call a method to fetch companies with the search text
            fetchAlbums(with: searchText)
        }
    }
    
}
