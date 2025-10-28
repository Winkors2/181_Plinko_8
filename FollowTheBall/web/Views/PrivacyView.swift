////
////  PrivacyView.swift
////  Winkors
////
////  Created by user on 14.09.2025.
////
//
//import SwiftUI
//
//struct PrivacyView: View {
//    let privacyURL: String
//    @Environment(\.dismiss) private var dismiss
//    @State private var isLoading = true
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                WebView(url: privacyURL, isLoading: $isLoading)
//                    .ignoresSafeArea()
//                
//                if isLoading {
//                    VStack {
//                        ProgressView()
//                            .scaleEffect(1.5)
//                        Text("Загрузка...")
//                            .padding(.top, 8)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color(.systemBackground))
//                }
//            }
//            .navigationTitle("Политика конфиденциальности")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Закрыть") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//        .presentationDetents([.medium, .large])
//        .presentationDragIndicator(.visible)
//    }
//}
//
