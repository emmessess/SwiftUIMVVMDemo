//
//  CoinsViewModel.swift
//  SwiftNwetworking
//
//  Created by Muhammad on 19/10/2023.
//

import Foundation
class CoinsViewModel : ObservableObject{
    // Not using below anymore, since we are passing whole array
    @Published var coin = ""
    @Published var price = ""
    @Published var errorMessage : String?
    
    @Published var coins = [Coin]()
    
    private let service = CoinDataService()
    init() {
        Task{
            try await fetchCoins()
        }
        //        fetchPrice(coin: "bitcoin")
    }
    
    // This contain Network call now move APi call from VM to service
    //    func fetchPrice(coin:String){
    //        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coin)&vs_currencies=usd"
    //        guard let url = URL(string: urlString)else {return}
    //        URLSession.shared.dataTask(with: url) { data, response, error in
    //            DispatchQueue.main.async {
    //                if let error  = error{
    //                    self.errorMessage = error.localizedDescription
    //                    return
    //                }
    //                guard let httpResponse = response as? HTTPURLResponse else{
    //                    self.errorMessage = "Bas HTTP Response"
    //                    return
    //                }
    //                guard httpResponse.statusCode == 200 else{
    //                    self.errorMessage = "Failed to fetch with status code \(httpResponse.statusCode)"
    //                    return
    //                }
    //                print("DEBUG: Response Code \(httpResponse.statusCode)")
    //                guard let data = data else{ return }
    //                guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {return}
    //
    //                guard let value = jsonObject[coin] as? [String:Double] else {return}
    //                guard let price = value["usd"] as? Double else {return}
    //
    //                self.coin = coin.capitalized
    //                self.price = "\(price)"
    //            }
    //
    //        }.resume()
    //    }
    
    func fetchCoins()async throws{
        let result = try await service.fetchCoins()
        DispatchQueue.main.async {
            switch result {
            case .success(let success):
                self.coins = success
            case .failure(let failure):
                self.errorMessage = failure.localizedDescription
            }
        }
    }
    
    func fetchCoinsWithCompletionHandler(){
        
        // Since the completionHandler is escaping self may get into retain cycle so to avoid use weak self and the we need to add ? with self
        // This counViewModel self is object A which is holding the closure as object B then closure reference the self back strongly may leads to retain cycle if the application is closed the objects can never bt removed and become orphans.
        // So We use weak with self closure refer to weak self at any point in time self is removed the closure will let it go and closure can also be removed because there is no retain cycle.

        service.fetchCoins{[weak self]result in
            DispatchQueue.main.async {
                switch result{
                case .success(let coins):
                    self?.coins = coins
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    break
                }
            }
        }
    }
    
    
    func fetchPrice(coin:String){
        service.fetchPrice(coin: "bitcoin") { price in
            DispatchQueue.main.async {
                self.price = "$\(price)"
                self.coin = coin
            }
        }
    }
}
