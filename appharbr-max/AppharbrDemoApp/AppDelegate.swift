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
//            .withDebugConfig(AppHarbrSdkDebug(debug: true, blockAll: true))
//            .withTargetedNetworks([.max])
//            .withMuteAd(true)
//            .withInterstitialAdTimeLimit(30)
//            .withRewardedAdTimeLimit(30)
            .build()

        AH.initializeSdk(configuration: configuration) { error in
            if let error = error {
                print("AppHarbr failed to initialize: \(error.localizedDescription)")
                return
            }
            print("AppHarbr initialized successfully!")
        }
        
        // Initialize the AppLovin SDK
        let initConfig = ALSdkInitializationConfiguration(sdkKey: Constants.appLovinSdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            print("AppLovin initialized successfully!")
        }
        
        return true
    }

}

