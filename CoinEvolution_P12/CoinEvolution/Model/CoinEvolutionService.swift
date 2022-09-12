//
//  CoinEvolutionService.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 15/06/2022.
//

import Foundation

protocol CoinEvolutionServiceDelegate {
    func didUpdateCrypto(_ cryptoBackend: CoinEvolutionService, crypto: [String : CryptoModel]?)
    func didUpdateCharts(_ cryptoBackend: CoinEvolutionService, charts: [ChartsModel])
    func didFailWithError(error: Error)
}

struct CoinEvolutionService {
    
    var baseAPIURL = "https://api.coingecko.com/api/v3/"
    var delegate: CoinEvolutionServiceDelegate?
    let coinEvolutionSession: URLSession
    init(coinEvolutionSession: URLSession = URLSession(configuration: .default)) {
        self.coinEvolutionSession = coinEvolutionSession
    }
    
    func getCryptoURL() {
        let apiURL = "\(baseAPIURL)coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1"
        getCrypto(apiURL)
    }
/// get Cryptos
    func getCrypto(_ urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let data = data {
                    if urlString.contains("market_chart") {
                        if let charts = parseJSONCharts(data) {
                            delegate?.didUpdateCharts(self, charts: charts)
                        }
                    } else {
                        if let crypto = parseJSON(data) {
                            delegate?.didUpdateCrypto(self, crypto: crypto)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ cryptoData: Data) -> [ String : CryptoModel]?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([CryptoData].self, from: cryptoData)
            var cryptoMarkets: [ String : CryptoModel] = [:]
            for data in decodedData {
                let name = data.name
                let priceChange = data.price_change_24h
                let currentPrice = data.current_price
                let imageURL = data.image
                let symbol = data.symbol.uppercased()
                let id = data.id
                let marketCapRank = data.market_cap_rank
                let priceChangePercentage24h = data.price_change_percentage_24h
                let totalVolume = data.total_volume
                let cryptoModel = CryptoModel(currentPrice: currentPrice, cryptoName: name, dailyPriceChange: priceChange, imageURL: imageURL, cryptoSymbol: symbol, id: id, marketCapRank: marketCapRank, price_change_percentage_24h: priceChangePercentage24h, total_volume: totalVolume)
                cryptoMarkets[name] = cryptoModel
            }
            return cryptoMarkets
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
/// get Charts
    func getCryptoCharts(vsCurrency: String, cryptoCurrency: String) {
        /// Get historical market data include price, market cap, and 24h volume
        /// données sur 30j avec un interval d'1 jour
        let apiURLChart = "\(baseAPIURL)coins/\(cryptoCurrency)/market_chart?vs_currency=\(vsCurrency)&days=\(30)&interval=daily"
        getCrypto(apiURLChart)
    }
    func parseJSONCharts(_ chartsData: Data) -> [ChartsModel]?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ChartsData.self, from: chartsData)
            var charts: [ChartsModel] = []
            for dailyValue in decodedData.prices {
                let date = dailyValue[0]
                let price = dailyValue[1]
                charts.append(ChartsModel(date: date, price: price))
            }
            return charts
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
