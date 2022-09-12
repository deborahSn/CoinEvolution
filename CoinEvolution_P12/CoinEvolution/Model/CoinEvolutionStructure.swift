//
//  CoinEvolutionStructure.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 15/06/2022.
//

import Foundation

/// Crypto
struct CryptoModel {
    let currentPrice: Double
    let cryptoName: String
    let dailyPriceChange: Double
    let imageURL: String
    let cryptoSymbol: String
    let id: String
    let marketCapRank: Int
    let price_change_percentage_24h: Double
    let total_volume: Double
    
    var valueIsUp: Bool {
        if dailyPriceChange < 0 {
            return false
        } else {
            return true
        }
    }
}
struct CryptoData: Decodable {
    let current_price: Double
    let price_change_24h: Double
    let name: String
    let image: String
    let symbol: String
    let id: String
    let market_cap_rank: Int
    let price_change_percentage_24h: Double
    let total_volume: Double
}

/// Charts
struct ChartsModel {
    let date: Double
    let price: Double
}
struct ChartsData: Decodable {
    let prices: [[Double]]
}
