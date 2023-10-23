//
//  CoinDataService.swift
//  SwiftNwetworking
//
//  Created by Muhammad on 19/10/2023.
//

import Foundation
class CoinDataService {
    private let urlString = "https://ap.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false&price+change_percentage=24h&locale=en"
    
    func fetchCoins() async throws -> Result<[Coin],CoinAPIError>{
        guard let url = URL(string: urlString)else {
            return .failure(.requestFailed(description: "Invalid URL"))
        }
        do{
            let (data,_) = try await URLSession.shared.data(from: url)// This creates suspension point and remove the need for adding completion handler
            let coins = try JSONDecoder().decode([Coin].self, from: data)
            return .success(coins)
//            print("DEBUG: Response \(response as! HTTPURLResponse)")
        }catch{
            print("DEBUG: Error \(error.localizedDescription)")
            return.failure(.requestFailed(description: error.localizedDescription))
        }
    }

}
extension CoinDataService{
    // Completion Handler stuff
    
    func fetchCoins(completion:@escaping([Coin]) -> Void){
        guard let url = URL(string: urlString)else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else{ return }
            guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else{
                print(String.init(data: data, encoding: .utf8))
                print("DEBUG: Coins decoded failed")
                return
            }
            completion(coins)
        }.resume()
    }
    // For Better error handling of above method
    
    func fetchCoins(completion:@escaping([Coin]?,Error?) -> Void){
        guard let url = URL(string: urlString)else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                completion(nil,error)
            }
            
            guard let data = data else{ return }
            guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else{
                print(String.init(data: data, encoding: .utf8))
                print("DEBUG: Coins decoded failed")
                return
            }
            completion(coins, nil)
        }.resume()
    }
//    This above methos is not that robust with 2 optionals to make it further better below ,ethod is used
    // next step use Custom error handling with result
    
    func fetchCoins(completion:@escaping(Result<[Coin],CoinAPIError>) -> Void){
    guard let url = URL(string: urlString)else {return}
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error{
            completion(.failure(.unknown(error: error)))
        }
        guard let httpResponse = response as? HTTPURLResponse else{
            completion(.failure(.requestFailed(description: "Request Failed")))
            return
        }
        guard httpResponse.statusCode == 200 else{
            completion(.failure(.invalidStatusCode(statusCode: httpResponse.statusCode)))
            return
        }
        guard let data = data else{
            completion(.failure(.invalidData))
            return
        }
        do{
            let coins = try JSONDecoder().decode([Coin].self, from: data)
            completion(.success(coins))
        }catch{
            print("JSON Parsing Failed \(error.localizedDescription)")
            completion(.failure(.jsonParsingFailure))
        }
    }.resume()
}
    // Now this closure may end up with retain cycle and we need additional work to avoid the situation
    // Instead we can use asyncAwait for asynchronous code without need of nested closure
    
    
    func fetchPrice(coin:String,completion:@escaping(Double) -> Void){
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coin)&vs_currencies=usd"
        guard let url = URL(string: urlString)else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error  = error{
                //                    self.errorMessage = error.localizedDescription
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else{
                //                    self.errorMessage = "Bas HTTP Response"
                return
            }
            guard httpResponse.statusCode == 200 else{
                //                    self.errorMessage = "Failed to fetch with status code \(httpResponse.statusCode)"
                return
            }
            guard let data = data else{ return }
            // Manual JSON Parsing
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {return}
            
            guard let value = jsonObject[coin] as? [String:Double] else {return}
            guard let price = value["usd"] as? Double else {return}
            completion(price)
            //                self.coin = coin.capitalized
            
        }.resume()
    }
}
