//
//  ContentView.swift
//  Winkors
//
//  Created by user on 14.09.2025.
//

import SwiftUI
import Combine

struct ContentViewApp: View {
    @StateObject private var viewModel = UserViewModel()
 
    
    var body: some View {
        ZStack {
        if viewModel.status == nil {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.012, green: 0.027, blue: 0.169), // 030B57
                    Color(red: 0.337, green: 0.678, blue: 0.875), // 56ADDF
                    Color(red: 0.424, green: 0.714, blue: 0.875), // 6CB6DF
                    Color(red: 0.012, green: 0.043, blue: 0.341)  // 030B57
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        } else if viewModel.status == true {
            ContentView().ignoresSafeArea()
                
        } else if viewModel.status == false {
                if let status = viewModel.status, status == false {
                    if let url = URL(string: viewModel.privacyPolicy ?? "") {
                        let model = WebLinkModel(homeURL: url)
                        let webViewModel = WebLinkViewModel(model: model)
                        WebLinkViewUI(vm: webViewModel)
                    }
                }
            
        }
        }
        .onAppear {
            viewModel.registerUser()
        }
    }
}


#Preview {
    ContentView()
}
