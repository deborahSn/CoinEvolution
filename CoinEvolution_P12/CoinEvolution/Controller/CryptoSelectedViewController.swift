//
//  CryptoSelectedViewController.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 20/06/2022.
//

import Foundation
import Charts
import TinyConstraints
import UIKit

//
class CryptoSelectedViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var imagecrypto: UIImageView!
    @IBOutlet weak var labelCrypto: UILabel!
    @IBOutlet weak var chartVIew: UIView!
    @IBOutlet weak var valueCrypto: UILabel!
    @IBOutlet weak var upDownCrypto: UILabel!
    @IBOutlet weak var upDownImage: UIImageView!
    @IBOutlet weak var priceChangePercentage24h: UILabel!
    @IBOutlet weak var volumeCrypto: UILabel!
    
    var currentVSCurrency = "usd"
    var currentCryptoCurrencyName = "Bitcoin"
    var currentCryptoCurrencyID = "bitcoin"
    var cryptoArray = ["Bitcoin", "Ethereum", "Litecoin", "Monero", "Chainlink", "Tether", "Dash", "Aave", "Ripple", "Dogecoin"]
    
    var coinEvolutionService = CoinEvolutionService()
    var crypto: [String : CryptoModel]? = [:]
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground(viewToChange: viewGradient)
        refreshCryptoUI()
        chartSetup()
        lineChartView.delegate = self
        ///  Download values from API
        coinEvolutionService.getCryptoURL()
        coinEvolutionService.getCryptoCharts(vsCurrency: currentVSCurrency, cryptoCurrency: currentCryptoCurrencyID)
    }
    
    func chartSetup() {
        /// ChartView constraints
        chartVIew.addSubview(lineChartView)
        chartVIew.backgroundColor = .black
        lineChartView.width(to: chartVIew)
        lineChartView.bottom(to: chartVIew)
        lineChartView.top(to: chartVIew)
        /// ChartView customization
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.pinchZoomEnabled = false
        /// Legend text customization
        lineChartView.legend.textColor = .white
    }
    
    func refreshCryptoUI() {
        coinEvolutionService.getCryptoCharts(vsCurrency: currentVSCurrency, cryptoCurrency: currentCryptoCurrencyID)
        DispatchQueue.main.async {
            self.lineChartView.highlightValues([Highlight]())
            if self.crypto != nil {
                if let currentCrypto = self.crypto![self.currentCryptoCurrencyName]
                {
                    self.labelCrypto.text = "\(currentCrypto.cryptoName) (\(currentCrypto.cryptoSymbol))"
                    if let imageURL = URL(string: (currentCrypto.imageURL)) {
                        self.imagecrypto
                            .load(imageURL)
                    }
                    self.valueCrypto
                        .text = "$ \(currentCrypto.currentPrice)"
                    let dailyPriceChangeString = "\(currentCrypto.dailyPriceChange) $"
                    if currentCrypto.valueIsUp {
                        self.upDownImage.image = UIImage(systemName: "arrow.up.circle.fill")
                        self.upDownImage.tintColor = .green
                        self.upDownCrypto.text = dailyPriceChangeString
                    }
                    else {
                        self.upDownImage.image = UIImage(systemName: "arrow.down.circle.fill")
                        self.upDownImage.tintColor = .red
                        self.upDownCrypto.text = dailyPriceChangeString
                    }
                    self.priceChangePercentage24h.text = "\(currentCrypto.price_change_percentage_24h) %"
                    self.volumeCrypto.text = "\(currentCrypto.total_volume)"
                }
            } else {
                self.coinEvolutionService.getCryptoURL()
            }
        }
        self.dismiss(animated: false) {}
    }
}
