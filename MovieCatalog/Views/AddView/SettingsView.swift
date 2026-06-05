//
//  SettingsView.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct SettingsView: View {
    // Сохраняем в UserDefaults.
    // 0 = Системная, 1 = Светлая, 2 = Тёмная
    @AppStorage("appThemeSelection") private var appThemeSelection = 0
    // 1 = Крупно, 2 = Стандарт, 3 = Компактно
    @AppStorage("gridColumnsCount") private var gridColumnsCount = 2
    
    var body: some View {
        NavigationStack {
            Form {
                // Тема
                Section(header: Text("Внешний вид")) {
                    Picker("Тема оформления", selection: $appThemeSelection) {
                        Text("Как в системе").tag(0)
                        Text("Светлая").tag(1)
                        Text("Тёмная").tag(2)
                    }
                    .pickerStyle(.menu)
                }
                
                // Отображение списка (главный экран)
                Section(header: Text("Отображение каталога")) {
                    Picker("Сетка каталога", selection: $gridColumnsCount) {
                        Text("1 в ряд (Крупно)").tag(1)
                        Text("2 в ряд (Стандарт)").tag(2)
                        Text("3 в ряд (Компактно)").tag(3)
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("Настройки")
        }
    }
}

#Preview {
    SettingsView()
}
