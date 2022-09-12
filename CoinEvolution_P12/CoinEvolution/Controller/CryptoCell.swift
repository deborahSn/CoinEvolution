//
//  CryptoCell.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 31/07/2022.
//

import UIKit

class CryptoCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var marketCapRank: UILabel!
    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var cryptoUpDown: UIImageView!
    @IBOutlet weak var cryptoDailyDifference: UILabel!
}
