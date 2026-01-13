//
//  ContentView.swift
//  ByeDPI-iOS
//
//  Created by Developer on 1/13/26.
//

import SwiftUI
import NetworkExtension
import Combine

struct ContentView: View {
    @State private var vpnStatus: NEVPNStatus = .invalid
    @State private var isConnecting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Status Indicator
                StatusIndicatorView(status: vpnStatus)
                
                // Connection Button
                ConnectionButton(
                    status: vpnStatus,
                    isConnecting: isConnecting,
                    onTap: toggleConnection
                )
                
                // Status Details
                StatusDetailsView(status: vpnStatus)
                
                Spacer()
                
                // Settings Button
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Настройки")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(vpnStatus == .connecting || vpnStatus == .reasserting)
            }
            .padding()
            .navigationTitle("ByeDPI iOS")
            .onAppear {
                updateVPNStatus()
                setupStatusObserver()
            }
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func toggleConnection() {
        guard !isConnecting else { return }
        
        isConnecting = true
        
        if vpnStatus == .connected || vpnStatus == .connecting {
            // Disconnect
            appDelegate.stopVPNTunnel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isConnecting = false
                updateVPNStatus()
            }
        } else {
            // Connect
            appDelegate.startVPNTunnel { error in
                DispatchQueue.main.async {
                    isConnecting = false
                    if let error = error {
                        alertMessage = "Ошибка подключения: \(error.localizedDescription)"
                        showAlert = true
                    }
                    updateVPNStatus()
                }
            }
        }
    }
    
    private func updateVPNStatus() {
        vpnStatus = appDelegate.getVPNStatus()
    }
    
    private func setupStatusObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { _ in
            updateVPNStatus()
        }
    }
}

struct StatusIndicatorView: View {
    let status: NEVPNStatus
    
    var body: some View {
        VStack {
            Circle()
                .fill(statusColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: statusIcon)
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            Text(statusText)
                .font(.headline)
                .padding(.top, 8)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .connected:
            return .green
        case .connecting, .reasserting:
            return .orange
        case .disconnected, .disconnecting:
            return .red
        default:
            return .gray
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .connected:
            return "checkmark"
        case .connecting, .reasserting:
            return "ellipsis"
        case .disconnected, .disconnecting:
            return "xmark"
        default:
            return "questionmark"
        }
    }
    
    private var statusText: String {
        switch status {
        case .connected:
            return "Подключено"
        case .connecting:
            return "Подключение..."
        case .reasserting:
            return "Переподключение..."
        case .disconnected:
            return "Отключено"
        case .disconnecting:
            return "Отключение..."
        case .invalid:
            return "Недоступно"
        @unknown default:
            return "Неизвестно"
        }
    }
}

struct ConnectionButton: View {
    let status: NEVPNStatus
    let isConnecting: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                if isConnecting {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text(buttonText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(buttonBackgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isConnecting)
    }
    
    private var buttonText: String {
        if isConnecting {
            return "Обработка..."
        }
        
        switch status {
        case .connected, .connecting, .reasserting:
            return "Отключить VPN"
        case .disconnected, .disconnecting, .invalid:
            return "Подключить VPN"
        @unknown default:
            return "Подключить VPN"
        }
    }
    
    private var buttonBackgroundColor: Color {
        if isConnecting {
            return .gray
        }
        
        switch status {
        case .connected, .connecting, .reasserting:
            return .red
        default:
            return .blue
        }
    }
}

struct StatusDetailsView: View {
    let status: NEVPNStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Статус соединения")
                .font(.headline)
            
            Divider()
            
            HStack {
                Text("Текущий статус:")
                Spacer()
                Text(detailedStatusText)
                    .fontWeight(.medium)
            }
            
            Text(statusDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var detailedStatusText: String {
        switch status {
        case .connected:
            return "Активен"
        case .connecting:
            return "Установка соединения"
        case .reasserting:
            return "Восстановление соединения"
        case .disconnected:
            return "Нет соединения"
        case .disconnecting:
            return "Завершение соединения"
        case .invalid:
            return "Ошибка конфигурации"
        @unknown default:
            return "Неизвестный статус"
        }
    }
    
    private var statusDescription: String {
        switch status {
        case .connected:
            return "VPN туннель активен и перенаправляет весь трафик"
        case .connecting:
            return "Выполняется установка VPN соединения"
        case .reasserting:
            return "VPN соединение временно потеряно, выполняется восстановление"
        case .disconnected:
            return "VPN туннель не активен"
        case .disconnecting:
            return "Выполняется отключение VPN"
        case .invalid:
            return "Конфигурация VPN недействительна"
        @unknown default:
            return "Неизвестное состояние VPN"
        }
    }
}

#Preview {
    ContentView()
}