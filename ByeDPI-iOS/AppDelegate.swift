//
//  AppDelegate.swift
//  ByeDPI-iOS
//
//  Created by Developer on 1/13/26.
//

import UIKit
import NetworkExtension

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - VPN Management
    
    func startVPNTunnel(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            guard let managers = managers else {
                completion(error)
                return
            }
            
            let manager = managers.first ?? NETunnelProviderManager()
            
            // Configure the tunnel
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = "com.example.ByeDPIiOS.ByeDPI-Packet-Tunnel"
            providerProtocol.serverAddress = "ByeDPI Tunnel"
            
            manager.protocolConfiguration = providerProtocol
            manager.localizedDescription = "ByeDPI VPN"
            manager.isEnabled = true
            
            manager.saveToPreferences { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                manager.loadFromPreferences { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    do {
                        try manager.connection.startVPNTunnel()
                        completion(nil)
                    } catch {
                        completion(error)
                    }
                }
            }
        }
    }
    
    func stopVPNTunnel() {
        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            guard let managers = managers, let manager = managers.first else { return }
            manager.connection.stopVPNTunnel()
        }
    }
    
    func getVPNStatus() -> NEVPNStatus {
        guard let managers = try? NETunnelProviderManager.loadAllFromPreferences(),
              let manager = managers.first else {
            return .invalid
        }
        return manager.connection.status
    }
}