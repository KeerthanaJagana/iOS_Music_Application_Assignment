//
//  GenreTableViewController.swift
//  loikjhg
//
//  Created by Keerthana Jagana on 3/19/24.
//

import UIKit
import CoreData

class GenreTableViewController: UITableViewController, GenreViewControllerDelegate {
    
    weak var delegate: GenreViewControllerDelegate?
    var Genres: [GenreData] = [] // Define productTypes as an array of Companies objects
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchGenres()
        // Register the cell class with the table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Reload table view to display fetched data
        tableView.reloadData()
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Genres"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }

    func fetchGenres(with searchText: String? = nil) {
        // Fetch request for Company entity
        let fetchRequest: NSFetchRequest<GenreData> = GenreData.fetchRequest()
        
        // Add a predicate to filter the results based on the search text
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        }
        
        do {
            // Fetch genres from CoreData
            Genres = try context.fetch(fetchRequest)
            
            // Reload table view to display fetched data
            tableView.reloadData()
        } catch {
            print("Error fetching genres: \(error.localizedDescription)")
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let genre = Genres[indexPath.row]
        
        // Set the company name as the cell's text label
        cell.textLabel?.text = genre.name
        
        // Set the company ID as the cell's detail text label
        cell.detailTextLabel?.text = String(genre.id)
        
        // Convert the binary data of the logo attribute to a UIImage object
        if let logoData = genre.logo {
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
        // Get the selected company from the companies array
        let selectedGenre = Genres[indexPath.row]

        // Perform segue to CompanyDetailsViewController with the selected company
        performSegue(withIdentifier: "showGenreDetails", sender: selectedGenre)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // Get the selected company from the companies array
        let selectedGenre = Genres[indexPath.row]

        // Perform segue to CompanyDetailsViewController with the selected company
        performSegue(withIdentifier: "showGenreDetails", sender: selectedGenre)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGenreDetails" {
            if let genreDetailsVC = segue.destination as? GenreDetailsViewController {
                if let selectedGenre = sender as? GenreData {
                    // Pass the selectedCompany object to CompanyDetailsViewController
                    genreDetailsVC.Genre = selectedGenre
                }
            }
        } else if segue.identifier == "addgenre" {
            if let genreDetailsVC = segue.destination as? GenreViewController {
                genreDetailsVC.delegate = self
            }
        }else if segue.identifier == "updategenre" {
            if let updateGenreVC = segue.destination as? GenreViewController {
                updateGenreVC.delegate = self
            }
        }
    }

    func didAddGenre(Genre: GenreData) {
        // Append the newly added company to the companies array
        Genres.append(Genre)

        configureSearchController()
        // Reload the table view to display the new data
        tableView.reloadData()
    }
    func configureSearchController() {
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Genres"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    func didUpdateGenre(Genre: GenreData) {
        // Update the product type in your data source
        // Reload the table view to display the updated data
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the selected genre from the genres array
            let selectedGenre = Genres[indexPath.row]
            let genreId = selectedGenre.id // Assuming 'id' is the property that represents the genre ID

            // Check if any songs are associated with this company
            let songFetchRequest: NSFetchRequest<SongData> = SongData.fetchRequest()
            songFetchRequest.predicate = NSPredicate(format: "genre_id == %ld", genreId)
            do {
                let genres = try context.fetch(songFetchRequest)
                if !genres.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "There are songs associated with this genre id. Please disassociate or delete them before deleting the genre", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }
            } catch let error {
                // Handle any errors that occur during fetch
                let alert = UIAlertController(title: "Error", message: "Failed to fetch songs associated with this genre with error: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            

            // Delete the selected company from Core Data
            context.delete(selectedGenre)
            do {
                try context.save()
                // Remove the selected company from the companies array
                Genres.remove(at: indexPath.row)
                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting genre: \(error.localizedDescription)")
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
extension GenreTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Get the search text from the search bar
        if let searchText = searchController.searchBar.text {
            // Call a method to fetch companies with the search text
            fetchGenres(with: searchText)
        }
    }
}
