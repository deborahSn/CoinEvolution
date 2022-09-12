//
//  CryptoBankViewController.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 18/08/2022.
//

import Foundation
import UIKit
import Charts


class CryptoBankViewController : UIViewController {
//    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var cryptoTableView: UITableView!
    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var cryptoValue: UILabel!
    
    var coinEvolutionService = CoinEvolutionService()
    var crypto: [String : CryptoModel]? = [:]
    // Default Starting Values
    var currentCryptoCurrencyName = "Bitcoin"
    var currentCryptoCurrencyID = "bitcoin"
    var currentUSD = "$"
    var cryptoArray = ["Bitcoin", "Ethereum", "Litecoin", "Monero", "Chainlink", "Tether", "Dash", "Aave", "Ripple", "Dogecoin"]
    // index for selectedcell
    var selectedIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CryptoCell", bundle: nil)
        cryptoTableView.register(nib, forCellReuseIdentifier: "CryptoCell")
        coinEvolutionService.delegate = self
        cryptoTableView.dataSource = self
        cryptoTableView.delegate = self
        /// Values from API
        coinEvolutionService.getCryptoURL()
    }
    
    func refreshCrypto() {
        coinEvolutionService.getCryptoCharts(vsCurrency: currentUSD, cryptoCurrency: currentCryptoCurrencyID)
        DispatchQueue.main.async {
            let indexPath = self.cryptoTableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
            self.cryptoTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            self.cryptoTableView.reloadData()
            if self.crypto != nil {
                if let currentCrypto = self.crypto![self.currentCryptoCurrencyName] {
                    self.cryptoLabel.text = "\(currentCrypto.cryptoName) (\(currentCrypto.cryptoSymbol))"
                    /// If imageURL != nil download the image and display it
                    if let imageURL = URL(string: (currentCrypto.imageURL)) {
                        self.cryptoImage.load(imageURL)
                    }
                    self.cryptoValue.text = "\(self.currentUSD) \(currentCrypto.currentPrice)"
                }
            } else {
                self.coinEvolutionService.getCryptoURL()
            }
        }
        self.dismiss(animated: false) {}
    }
}

extension CryptoBankViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cryptoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Big cell
        if selectedIndex == indexPath {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "selectedcell", for: indexPath) as? BigCell else {
                fatalError("error selectedcell")
            }
            cell.name.text =
            "\(self.cryptoArray[indexPath[1]]) (\(self.crypto![self.cryptoArray[indexPath[1]]]?.cryptoSymbol ?? "??"))"
            let imageURL = URL(string:(self.crypto![self.cryptoArray[indexPath[1]]]?.imageURL ?? "error"))
            cell.imageIcon.load(imageURL!)
            cell.value.text = "\(self.crypto![self.cryptoArray[indexPath[1]]]?.currentPrice ?? 0) "
            cell.labelTextField.text = "Your number of \(self.cryptoArray[indexPath[1]])"
            /// clean big cell
            cell.totalCrypto.text = " "
            cell.textField.text?.removeAll()
            return cell
        /// Normal cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CryptoCell",
                for: indexPath) as? CryptoCell else {
                return UITableViewCell()
            }
            cell.marketCapRank.text = "\(self.crypto![self.cryptoArray[indexPath[1]]]?.marketCapRank ?? 404)."
            cell.name.text =
            "\(self.cryptoArray[indexPath[1]]) (\(self.crypto![self.cryptoArray[indexPath[1]]]?.cryptoSymbol ?? "??"))"
            cell.value.text = "\(self.crypto![self.cryptoArray[indexPath[1]]]?.currentPrice ?? 0) \(self.currentUSD)"
            let imageURL = URL(string:(self.crypto![self.cryptoArray[indexPath[1]]]?.imageURL ?? "error"))
            cell.cryptoImage.load(imageURL!)
            cell.backgroundColor = UIColor.blue
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        currentCryptoCurrencyName = self.cryptoArray[indexPath.row]
        currentCryptoCurrencyID = self.crypto![self.cryptoArray[indexPath.row]]!.id
        refreshCrypto()
        if selectedIndex == indexPath {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath
        }
        tableView.reloadData()
    }
}

extension CryptoBankViewController: CoinEvolutionServiceDelegate, ChartViewDelegate {
    func didUpdateCharts(_ cryptoBackend: CoinEvolutionService, charts: [ChartsModel]) {
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    }
    func updateCryptoLabel(_ highlight: Double) {
    }
    ///UpdateCryptoCurrencyValues
    func didUpdateCrypto(_ cryptoBackend: CoinEvolutionService, crypto: [String : CryptoModel]?) {
        DispatchQueue.main.async {
            self.crypto = crypto
            self.cryptoArray = []
            var cryptoArrayMarketCap: [String] = []
            for cryptoCurrencyData in crypto! {
                cryptoArrayMarketCap.append("\(cryptoCurrencyData.value.marketCapRank).\(cryptoCurrencyData.value.cryptoName)")
            }
            cryptoArrayMarketCap.sort(by: {$0.localizedStandardCompare($1) == .orderedAscending})
            for cryptoRanking in cryptoArrayMarketCap {
                if let index = (cryptoRanking.range(of: ".")?.upperBound){
                    let onlyCryptoName = String(cryptoRanking.suffix(from: index))
                    self.cryptoArray.append("\(onlyCryptoName)")
                }
            }
            self.refreshCrypto()
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

