//
//  FallbackView.swift
//  Winkors
//
//  Created by user on 14.09.2025.
//

import SwiftUI

struct FallbackView: View {
    @ObservedObject var viewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Ошибка регистрации")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Не удалось зарегистрировать пользователя. Проверьте подключение к интернету и попробуйте снова.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                Button("Попробовать снова") {
                    viewModel.registerUser()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
    }
}

