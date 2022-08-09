//
//  DrinkDetailsTableViewCell.swift
//  CocktailDb
//
//  Created by Kushal Vaghani on 30/07/2022.
//

import UIKit

class DrinkDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblInstruction: UILabel!
    @IBOutlet weak var lblInstructionsDetail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
