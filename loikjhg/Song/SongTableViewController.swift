//
//  SongTableViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/23/24.
//

import UIKit
import CoreData
class SongTableViewController: UITableViewController,SongViewControllerDelegate {

    weak var delegate: SongViewControllerDelegate?
    var Songs: [SongData] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch companies from CoreData
        fetchSongs()
        // Register the cell class with the table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Reload table view to display fetched data
        tableView.reloadData()
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Songs"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    func fetchSongs(with searchText: String? = nil) {
        // Fetch request for Company entity
        let fetchRequest: NSFetchRequest<SongData> = SongData.fetchRequest()
        
        // Add a predicate to filter the results based on the search text
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "id CONTAINS[cd] %@", searchText)
        }
        
        do {
           
            Songs = try context.fetch(fetchRequest)
            
            // Reload table view to display fetched data
            tableView.reloadData()
        } catch {
            print("Error fetching songs: \(error.localizedDescription)")
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let song = Songs[indexPath.row]
        
     
        cell.textLabel?.text = String(song.id)
        
    
        cell.detailTextLabel?.text = String(song.id)
        
        // Add a details disclosure button
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected company from the companies array
        let selectedSongs = Songs[indexPath.row]
        
        // Perform segue to CompanyDetailsViewController with the selected company
        performSegue(withIdentifier: "showSongDetails", sender: selectedSongs)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // Get the selected company from the companies array
        let selectedSongs = Songs[indexPath.row]
        
        // Perform segue to CompanyDetailsViewController with the selected company
        performSegue(withIdentifier: "showSongDetails", sender: selectedSongs)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSongDetails" {
            if let songDetailsVC = segue.destination as? SongDetailsViewController {
                if let selectedSong = sender as? SongData {
                    // Pass the selectedCompany object to CompanyDetailsViewController
                    songDetailsVC.Song = selectedSong
                }
            }
        } else if segue.identifier == "addsong" {
            if let addSongVC = segue.destination as? SongViewController {
                addSongVC.delegate = self
            }
        }else if segue.identifier == "updatesong" {
            if let updateSongVC = segue.destination as? SongViewController {
                updateSongVC.delegate = self
            }
        }
    }
    
    func didAddSong(Song: SongData) {
        // Append the newly added company to the companies array
        Songs.append(Song)
        
        // Reload the table view to display the new data
        tableView.reloadData()
    }
    func didUpdateSong(Song: SongData) {
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let selectedSong = Songs[indexPath.row]
            let songId = selectedSong.id // Assuming 'id' is the property
           
            // Delete the selected post from Core Data
            context.delete(selectedSong)
            do {
                try context.save()
                // Remove the selected company from the posts array
                Songs.remove(at: indexPath.row)
                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting song: \(error.localizedDescription)")
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
extension SongTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Get the search text from the search bar
        if let searchText = searchController.searchBar.text {
            // Call a method to fetch companies with the search text
            fetchSongs(with: searchText)
        }
    }
    
}
