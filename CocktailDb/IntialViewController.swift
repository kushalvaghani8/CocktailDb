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
    var lastClick: Double = 0.0
    
    
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
            let cocktails = try managedContext.fetch(fetchRequest)
            return cocktails
        } catch let error as NSError {
            print("was not able to get any data" + error.description)
        }
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
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
        
        //adding tap gesture to the cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.drinkImageTappAction(_:)))
        cell.drinkImageView.addGestureRecognizer(tapGesture)
        cell.drinkImageView.isUserInteractionEnabled = true
        cell.drinkImageView.tag = indexPath.row
        
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
    
    @objc func drinkImageTappAction(_ sender: UITapGestureRecognizer) {
        
        let current = Date().timeIntervalSince1970 * 1000 //getting current time
        if (current - lastClick) < 500 { //if the click is below .5 seconds
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.openDetailScreen(_:)), object: sender) //user first click will be cancelled
            
            if let index = sender.view?.tag { //if the user last click is cancelled it will be a double tap on the image
                let data = self.cocktailArray[index]
                data.fav = !data.fav //if it's a double tap, drink will be added to fav.
                AppDelegate.shared.saveContext() //adding it to fav in data base
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } else {
            self.perform(#selector(self.openDetailScreen(_:)), with: sender, afterDelay: 0.4) //else if it's not a double tap the user will be taken to the detail screen.
        }
        
        lastClick = current
    }
    
    @objc func openDetailScreen(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag { //getting index - tag from the database, taking user to the selected drink detail view
            let data = self.cocktailArray[index]
            let vc = storyboard?.instantiateViewController(withIdentifier: "CocktailDetailsTableViewController") as! CocktailDetailsTableViewController
            vc.detail = data
            vc.title = data.name
            DispatchQueue.main.async {
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
}
