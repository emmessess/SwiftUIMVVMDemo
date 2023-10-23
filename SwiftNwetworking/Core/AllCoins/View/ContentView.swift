//
//  ContentView.swift
//  SwiftNwetworking
//
//  Created by Muhammad on 19/10/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CoinsViewModel()
    var body: some View {
        List {
            ForEach (viewModel.coins){coin in
                HStack{
                    Text("\(coin.marketCapRank)")
                        .foregroundStyle(.gray)
                    VStack(alignment:.leading){
                        Text("\(coin.name)")
                            .fontWeight(.semibold)
                        Text(coin.symbol.uppercased())
                        
                    }
                }.font(.footnote)
            }
        }
        .overlay(content: {
            if let errorMessage = viewModel.errorMessage{
                Text(errorMessage)
            }
        })
        .padding()
    }
}

#Preview {
    ContentView()
}
