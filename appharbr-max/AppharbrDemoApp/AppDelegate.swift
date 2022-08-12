//
//  AppDelegate.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import AppHarbrSDK
import AppLovinSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: AppHarbr
        // Initialize AppHarbr SDK

        let configuration = AppHarbrConfigurationBuilder(apiKey: Constants.geoEdgeKey)
//                                .withDebugConfig(AppHarbrSdkDebug(debug: true, blockAll: true))
//                                .withAllowedNetworksToMonitor([.adMob])
                                .build()

        AH.initializeSdk(configuration: configuration) { error in
            if let error = error {
                print("AppHarbr failed to initialize: \(error.localizedDescription)")
                return
            }
            print("AppHarbr initialized successfully!")
        }

        // Initialize the AppLovin SDK
        ALSdk.shared()!.mediationProvider = ALMediationProviderMAX
        ALSdk.shared()!.initializeSdk(completionHandler: { configuration in
            // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
        })
        return true
    }

}

