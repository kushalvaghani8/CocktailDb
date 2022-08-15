//
//  IntialViewController.swift
//  CocktailDb
//
//  Created by Kushal Vaghani on 30/07/2022.
//

import UIKit
import SDWebImage
import CoreData

class CocktailModel : NSObject { //created model for data

    var id : String!
    var name : String!
    var image : String!
    var fav : Bool = false

   
    init(fromJson json: [String: Any]){
        if json.isEmpty{
            return
        }
        id = json["idDrink"] as? String
        image = json["strDrinkThumb"] as? String
        name = json["strDrink"] as? String
    }


}


class IntialViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cocktailModelArray: [CocktailModel] = []
    var cocktailArray: [Cocktail] = []
    
    
    func setUpView() {
        self.cocktailArray = self.fetchCocktailDataFromCoreData() //fetching data from core
        if self.cocktailArray.count == 0 { //if data does not exist in core data then fetching it from api
            self.fetchCocktailsDataFromApi()
        } else {
            self.collectionView.reloadData() //reloading data once data is found from either
        }
    }
    
    func fetchCocktailsDataFromApi() {
        Task{
            do {
                let resultObject = try await CocktailAPI_Helper.fetchCocktails()
                let drinks = resultObject["drinks"] as! [[String : Any]]
                self.cocktailModelArray = drinks.map { CocktailModel(fromJson: $0) } //converting dictionary to model object
                
                let managedContext = AppDelegate.shared.persistentContainer.viewContext
                self.cocktailArray.removeAll()
                for cocktailModel in self.cocktailModelArray {
                    let entity = NSEntityDescription.entity(forEntityName: "Cocktail", in: managedContext)!
                    let cocktail = Cocktail(entity: entity, insertInto: managedContext)
                    cocktail.id = cocktailModel.id
                    cocktail.name = cocktailModel.name
                    cocktail.image = cocktailModel.image
                   
                    self.cocktailArray.append(cocktail)
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                do {
                    try managedContext.save()//saving all data to core data
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            } catch let err{
                print("something went wrong: \(err)")
            }
        }
    }
    
    func fetchCocktailDataFromCoreData() -> [Cocktail] { //method to fetch data from core
        let managedContext = AppDelegate.shared.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Cocktail>(entityName: "Cocktail")
        
        do {
            let users = try managedContext.fetch(fetchRequest)
            return users
        } catch let error as NSError {
            print("was not able to get any data" + error.description)
        }
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
}


extension IntialViewController: UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.cocktailArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CocktailCell", for: indexPath) as! CocktailCell
        
        let data = self.cocktailArray[indexPath.row]
        cell.drinkNamelbl.text = data.name
        
        if let imgURL = data.image {
            cell.drinkImageView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage())
        } else {
            cell.drinkImageView.image = nil
        }
        
        cell.drinkFavBtn.isSelected = data.fav
        cell.drinkFavBtn.tag = indexPath.row //giving tag for fav 
        cell.drinkFavBtn.addTarget(self, action: #selector(self.btnFavTapped(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = self.cocktailArray[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CocktailDetailsTableViewController") as! CocktailDetailsTableViewController
        vc.detail = data
        vc.title = data.name
        navigationController!.pushViewController(vc, animated: true)
    }
    
    //UIButton Action Method for fav button
    @objc func btnFavTapped(_ sender: UIButton) {
        
        sender.isSelected.toggle() //toogle for fav
        let data = self.cocktailArray[sender.tag] //giving it to specific drink
        data.fav = sender.isSelected
        
        AppDelegate.shared.saveContext() //saving fav to database
    }
    
}
