//
//  SettingsView.swift
//  ByeDPI-iOS
//
//  Created by Developer on 1/13/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("proxyHost") private var proxyHost = "127.0.0.1"
    @AppStorage("proxyPort") private var proxyPort = "1080"
    @AppStorage("enableFragmentation") private var enableFragmentation = true
    @AppStorage("fragmentationSize") private var fragmentationSize = 2
    @AppStorage("enableAutoStart") private var enableAutoStart = false
    @AppStorage("selectedMethod") private var selectedMethod = 0
    
    let methods = ["TCP Fragmentation", "HTTP Header Modification", "TLS Padding", "Random Techniques"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основные настройки")) {
                    TextField("Хост прокси", text: $proxyHost)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                    
                    TextField("Порт прокси", text: $proxyPort)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Методы обхода DPI")) {
                    Picker("Метод обхода", selection: $selectedMethod) {
                        ForEach(0..<methods.count, id: \.self) { index in
                            Text(methods[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Дополнительные опции")) {
                    Toggle("Включить фрагментацию TCP", isOn: $enableFragmentation)
                    
                    if enableFragmentation {
                        HStack {
                            Text("Размер фрагмента")
                            Spacer()
                            TextField("", value: $fragmentationSize, formatter: NumberFormatter())
                                .frame(width: 50)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    Toggle("Автозапуск при включении", isOn: $enableAutoStart)
                }
                
                Section(header: Text("Информация")) {
                    HStack {
                        Text("Версия приложения")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Статус лицензии")
                        Spacer()
                        Text("Бесплатная")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Сбросить настройки") {
                        resetSettings()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func resetSettings() {
        proxyHost = "127.0.0.1"
        proxyPort = "1080"
        enableFragmentation = true
        fragmentationSize = 2
        enableAutoStart = false
        selectedMethod = 0
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}