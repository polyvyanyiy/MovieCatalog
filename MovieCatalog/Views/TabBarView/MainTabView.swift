//
//  MainTabView.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "popcorn.fill")
                }
            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
        }
    }
}


//#Preview {
//    MainTabView()
//}
