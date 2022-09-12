//
//  BigCell.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 23/08/2022.
//

import Foundation
import UIKit

class BigCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var totalCrypto: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var labelTextField: UILabel!
    
    @IBAction func addNumberCrypto(){
        let num = Double(textField.text!)
        let convertLabelToString = value.text!
        let stringToDouble = (NumberFormatter().number(from: convertLabelToString)?.doubleValue)
        let result = (num ?? 0) * (stringToDouble ?? 0)
        totalCrypto.text = String(result)
    }

}
