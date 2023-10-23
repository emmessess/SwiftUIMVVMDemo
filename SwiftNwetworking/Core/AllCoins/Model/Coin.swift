//
//  Coin.swift
//  SwiftNwetworking
//
//  Created by Muhammad on 19/10/2023.
//

import Foundation
struct Coin : Codable,Identifiable {
    let id, name, symbol : String
    let currentPrice : Double
    let marketCapRank : Int
    
    enum CodingKeys : String, CodingKey{
        case id,symbol,name
        case currentPrice = "current_price"
        case marketCapRank = "market_cap_rank"
    }
}
