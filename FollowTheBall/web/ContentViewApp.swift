//
//  ContentView.swift
//  Winkors
//
//  Created by user on 14.09.2025.
//

import SwiftUI
import Combine
import SdkPushExpress
struct ContentViewApp: View {
    @StateObject private var viewModel = UserViewModel()
 
    
    var body: some View {
        ZStack {
        if viewModel.status == nil {
            Image("mtbg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        } else if viewModel.status == true {
            ContentView().ignoresSafeArea()
                .onAppear{
                    do {
                        try PushExpressManager.shared.deactivate()
//                        print("❌ PushExpress деактивирован")
                    } catch {
                        print(" \(error)")
                    }
                }
        } else if viewModel.status == false {
                if let status = viewModel.status, status == false {
                    if let url = URL(string: viewModel.privacyPolicy ?? "") {
                        let model = WebLinkModel(homeURL: url)
                        let webViewModel = WebLinkViewModel(model: model)
                        WebLinkViewUI(vm: webViewModel)
                            .onAppear {
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                                  appDelegate.enablePushNotifications()
                                              }
                                                }
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
