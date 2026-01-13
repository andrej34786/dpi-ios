//
//  AppDelegate.swift
//  ByeDPI-iOS
//
//  Created by Developer on 1/13/26.
//

import UIKit
import NetworkExtension
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create root view controller with SwiftUI content
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        window?.rootViewController = hostingController
        
        // Make window visible
        window?.makeKeyAndVisible()
        
        return true
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
            providerProtocol.providerBundleIdentifier = "com.andrej34786.ByeDPIiOS.ByeDPI-Packet-Tunnel"
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
        var status: NEVPNStatus = .invalid
        let semaphore = DispatchSemaphore(value: 0)
        
        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            if let managers = managers, let manager = managers.first {
                status = manager.connection.status
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return status
    }
}