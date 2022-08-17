//
//  CocktailDetailsTableViewController.swift
//  CocktailDb
//
//  Created by Kushal Vaghani on 30/07/2022.
//

import UIKit

class CocktailDetailsTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource  {
    
    var detail: Cocktail?
    
    @IBOutlet weak var drinkNamelbl: UILabel!
    
    var cocktailDetail: [String : AnyObject] = [:]
    var cocktailInfo : [[String : AnyObject]] = [[:]]
    var indList = [String]()
    
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
          
        Task{
            do{
                self.cocktailDetail = try await CocktailDetail_Helper.fetchCocktailDetails(id: detail?.id ?? "")
              
                DispatchQueue.main.async { [self] in
                
               self.cocktailInfo = self.cocktailDetail["drinks"] as! [[String : AnyObject]]
             
                   
                    if(self.cocktailInfo[0]["strIngredient1"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient1"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient2"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient2"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient3"]as? String   != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient3"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient4"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient4"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient5"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient5"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient6"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient6"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient7"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient7"] as! String)
                    }
                    if(self.cocktailInfo[0]["strIngredient8"] as? String != nil)
                    {
                        self.indList.append(cocktailInfo[0]["strIngredient8"] as! String)
                    }
            
                    self.tblView.reloadData()
                    
                }
            } catch let err{
                print("something went wrong: \(err)")
            }
        }
        
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
         return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return indList.count + 1
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if(indexPath.row == indList.count)
            
         {
         let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkDetailsTableViewCell", for: indexPath) as! DrinkDetailsTableViewCell

        // Configure the cell...
             cell.lblInstruction.text = "Instruction"
         cell.lblInstructionsDetail.text = self.cocktailInfo[0]["strInstructions"] as? String ?? ""
        return cell
         }
         else{
             let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsTableViewCell", for: indexPath) as! IngredientsTableViewCell
             let imgURL = "https://www.thecocktaildb.com/images/ingredients/\(indList[indexPath.row])-small.png".replacingOccurrences(of: " ", with: "%20")
             cell.indImage.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage())
            // Configure the cell...
             cell.indLbl.text = self.indList[indexPath.row]
            return cell
         }
    }

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
