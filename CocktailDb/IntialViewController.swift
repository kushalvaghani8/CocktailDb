//
//  IntialViewController.swift
//  CocktailDb
//
//  Created by Kushal Vaghani on 30/07/2022.
//

import UIKit
import SDWebImage
class IntialViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var Cocktails: [String : AnyObject] = [:]
   
    var CocktailList : [[String : AnyObject]] = [[:]]
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        Task{
            do{
                self.Cocktails = try await CocktailAPI_Helper.fetchCocktails()
                //print(self.Cocktails["drinks"])
                DispatchQueue.main.async {
                self.CocktailList = self.Cocktails["drinks"] as! [[String : AnyObject]]
                //print(self.Cocktails)
                    self.collectionView.reloadData()
                    
                }
                
            } catch let err{
                print("something went wrong: \(err)")
            }
        }
    }
    // Do any additional setup after loading the view.
}


extension IntialViewController: UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(CocktailList.count > 0)
        {
            return CocktailList.count
        }
        else{
         return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CocktailCell", for: indexPath) as! CocktailCell
        let imgURL = self.CocktailList[indexPath.row]["strDrinkThumb"]
        as? String ?? ""
        cell.drinkImageView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage())
        cell.drinkNamelbl.text = self.CocktailList[indexPath.row]["strDrink"]
 as? String ?? ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CocktailDetailsTableViewController") as! CocktailDetailsTableViewController
        vc.detail = CocktailList[indexPath.row]
        navigationController!.pushViewController(vc, animated: true)
    }
    
    
}
