//
//  CoinAPIError.swift
//  SwiftNwetworking
//
//  Created by Muhammad on 23/10/2023.
//

import Foundation
enum CoinAPIError:Error {
case invalidData
    case jsonParsingFailure
    case requestFailed(description:String)
    case invalidStatusCode(statusCode:Int)
    case unknown(error:Error)
    var customDescription : String{
        switch self {
        case .invalidData:
            return "Invalid Data"
        case .jsonParsingFailure:
            return "Failed to parse JSON"
        case .requestFailed(let description):
            return "Request Failed \(description)"
        case .invalidStatusCode(let statusCode):
            return "Invalid Status Code \(statusCode)"
        case .unknown(let error):
            return "An unknown error occured \(error.localizedDescription)"
        }
    }
}
