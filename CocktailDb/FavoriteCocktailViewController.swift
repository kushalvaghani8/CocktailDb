//
//  FavoriteCocktailViewController.swift
//  CocktailDb
//
//  Created by hyperlink on 13/08/22.
//

import UIKit
import CoreData

class FavoriteCockailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var drinkNamelbl: UILabel!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkFavBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

class FavoriteCocktailViewController: UIViewController {

    @IBOutlet weak var favTbl: UITableView!
    
    var cocktailArray: [Cocktail] = []
    
    func setUpView() {
        
        self.favTbl.delegate = self
        self.favTbl.dataSource = self
        self.cocktailArray = self.fetchFavCocktailDataFromCoreData()
      
    }
    
    func fetchFavCocktailDataFromCoreData() -> [Cocktail] {
        let managedContext = AppDelegate.shared.persistentContainer.viewContext //
        
        let fetchRequest = NSFetchRequest<Cocktail>(entityName: "Cocktail")
        fetchRequest.predicate = NSPredicate(format: "fav == %@", NSNumber(value: true)) //getting data only if its a fav in the database
        do {
            let cocktails = try managedContext.fetch(fetchRequest)
            return cocktails
        } catch let error as NSError {
            print("was not able to get any data" + error.description)
        }
        return []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        self.favTbl.reloadData()
    }
}


extension FavoriteCocktailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cocktailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCockailTableViewCell", for: indexPath) as! FavoriteCockailTableViewCell
        cell.selectionStyle = .none
        
        let data = self.cocktailArray[indexPath.row]
        cell.drinkNamelbl.text = data.name
        
        if let imgURL = data.image {
            cell.drinkImageView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage())
        } else {
            cell.drinkImageView.image = nil
        }
        return cell
    }
}
