//
//  CryptoViewController.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 15/06/2022.
//

import UIKit
import Charts

class CryptoViewController: UIViewController {
    
//    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var cryptoTableView: UITableView!
    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var cryptoValue: UILabel!
    @IBOutlet weak var cryptoUpDown: UIImageView!
    @IBOutlet weak var cryptoDailyDifference: UILabel!
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        return chartView
    }()
    
    var coinEvolutionService = CoinEvolutionService()
    var crypto: [String : CryptoModel]? = [:]
    /// segue to next VC
    private let segueToCryptoSelected = "segueToCryptoSelectedVC"
    /// Default Starting Values
    var currentCryptoCurrencyName = "Bitcoin"
    var currentCryptoCurrencyID = "bitcoin"
    var currentVSCurrency = "usd"
    var lastCurrencyIndex = 0
    var cryptoArray = ["Bitcoin", "Ethereum", "Litecoin", "Monero", "Chainlink", "Tether", "Dash", "Aave", "Ripple", "Dogecoin"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// load nib CryptoCell
        let nib = UINib(nibName: "CryptoCell", bundle: nil)
        cryptoTableView.register(nib, forCellReuseIdentifier: "CryptoCell")
        /// delegate
        coinEvolutionService.delegate = self
        /// delegate tableView
        cryptoTableView.dataSource = self
        cryptoTableView.delegate = self
        /// Download values from API
        coinEvolutionService.getCryptoURL()
    }
    
    // refresh values (refreshCrypto())
    func refreshCrypto() {
        /// Refresh values for Labels and Charts
        coinEvolutionService.getCryptoCharts(vsCurrency: currentVSCurrency, cryptoCurrency: currentCryptoCurrencyID)
        
        DispatchQueue.main.async {
            ///   Refresh TableView
            let indexPath = self.cryptoTableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
            self.cryptoTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            self.cryptoTableView.reloadData()
            self.lineChartView.highlightValues([Highlight]())
            
            if self.crypto != nil {
                if let currentCrypto = self.crypto![self.currentCryptoCurrencyName] {
                    self.cryptoLabel.text = "\(currentCrypto.cryptoName) (\(currentCrypto.cryptoSymbol))"
                    if let imageURL = URL(string: (currentCrypto.imageURL)) {
                        self.cryptoImage.load(imageURL)
                    }
                    self.cryptoValue.text = "$ \(currentCrypto.currentPrice)"
                    let dailyPriceChangeString = "\(currentCrypto.price_change_percentage_24h.rounded()) %"
                    if currentCrypto.valueIsUp { /// if crypto is up
                        self.cryptoUpDown.image = UIImage(systemName: "arrow.up.circle.fill")
                        self.cryptoUpDown.tintColor = .green
                        self.cryptoDailyDifference.text = dailyPriceChangeString
                    } else { /// if crypto is down
                        self.cryptoUpDown.image = UIImage(systemName: "arrow.down.circle.fill")
                        self.cryptoUpDown.tintColor = .red
                        self.cryptoDailyDifference.text = dailyPriceChangeString
                    }
                }
            } else {
                self.coinEvolutionService.getCryptoURL()
            }
        }
        self.dismiss(animated: false) {}
    }
}

extension CryptoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cryptoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CryptoCell",
            for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        cell.marketCapRank.text = "\(self.crypto![self.cryptoArray[indexPath[1]]]?.marketCapRank ?? 404)."
        cell.name.text =
        "\(self.cryptoArray[indexPath[1]]) (\(self.crypto![self.cryptoArray[indexPath[1]]]?.cryptoSymbol ?? "??"))"
        cell.value.text = "\(self.crypto![self.cryptoArray[indexPath[1]]]?.currentPrice ?? 0) $"
        cell.cryptoDailyDifference.text = "\(self.crypto![self.cryptoArray[indexPath[1]]]?.price_change_percentage_24h ?? 404) %"
        let imageURL = URL(string:(self.crypto![self.cryptoArray[indexPath[1]]]?.imageURL ?? "error"))
        cell.cryptoImage.load(imageURL!)
        if (self.crypto![self.cryptoArray[indexPath[1]]]?.valueIsUp ?? (404 != 0)) {            cell.cryptoUpDown.image = UIImage(systemName: "arrow.up.circle.fill")
            cell.cryptoUpDown.tintColor = .green
        } else {
            cell.cryptoUpDown.image = UIImage(systemName: "arrow.down.circle.fill")
            cell.cryptoUpDown.tintColor = .red
        }
        cell.backgroundColor = UIColor.blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCryptoCurrencyName = self.cryptoArray[indexPath.row]
        currentCryptoCurrencyID = self.crypto![self.cryptoArray[indexPath.row]]!.id
        refreshCrypto()
        self.performSegue(withIdentifier: self.segueToCryptoSelected, sender: self)
    }
    
    /// ANIMATION: cell openings
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -30, 0, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0.5
        UIView.animate(withDuration: 0.8){
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
}

extension CryptoViewController: CoinEvolutionServiceDelegate, ChartViewDelegate {
    /// Update charts
    func didUpdateCharts(_ cryptoBackend: CoinEvolutionService, charts: [ChartsModel]) {
        DispatchQueue.main.async {
            /// Create empty ChartDataEntry array
            var priceChartDataSet: [ChartDataEntry] = []
            /// Fill the array with ChartData
            for dailyValue in charts {
                priceChartDataSet.append(ChartDataEntry(x: dailyValue.date, y: dailyValue.price))
            }
            let pricesSet = LineChartDataSet(entries: priceChartDataSet, label: "Monthly price for \(self.crypto![self.currentCryptoCurrencyName]?.cryptoSymbol ?? "404") in $ ")
            let priceChartData = LineChartData(dataSet: pricesSet)
            self.lineChartView.data = priceChartData
            self.lineChartView.fitScreen()
            /// custom chart
            pricesSet.drawCirclesEnabled = true
            pricesSet.drawValuesEnabled = false
            pricesSet.mode = .cubicBezier
            pricesSet.lineWidth = 3
            pricesSet.setColor(.white)
            pricesSet.fill = Fill(color: .cyan)
            pricesSet.fillAlpha = 0.8
            pricesSet.drawFilledEnabled = true
            pricesSet.circleRadius = 4
        }
    }
    
    /// Update CryptoCurrency Values
    func didUpdateCrypto(_ cryptoBackend: CoinEvolutionService, crypto: [String : CryptoModel]?) {
        DispatchQueue.main.async {
            self.crypto = crypto
            ///  create cryptoArray and cryptoArrayMarketCap
            self.cryptoArray = []
            var cryptoArrayMarketCap: [String] = []
            ///   fill cryptoArrayMarketCap with CryptoCurrency Ranks
            for cryptoActualData in crypto! {
                cryptoArrayMarketCap.append("\(cryptoActualData.value.marketCapRank).\(cryptoActualData.value.cryptoName)")
            }
            /// sort cryptoArrayMarketCap by growing numbers
            cryptoArrayMarketCap.sort(by: {$0.localizedStandardCompare($1) == .orderedAscending})
            ///  delete marketCapRank from cryptoArray
            for cryptoRanking in cryptoArrayMarketCap {
                if let index = (cryptoRanking.range(of: ".")?.upperBound){
                    /// delete everything before & including the dot
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

extension CryptoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToCryptoSelected {
            guard let cryptoSelectedVC = segue.destination as? CryptoSelectedViewController else { return }
            cryptoSelectedVC.currentCryptoCurrencyName = currentCryptoCurrencyName
            cryptoSelectedVC.currentCryptoCurrencyID = currentCryptoCurrencyID
            cryptoSelectedVC.crypto = crypto
            cryptoSelectedVC.lineChartView = lineChartView
        }
    }
}

