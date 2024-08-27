//
//  AppDelegate.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import AppHarbrSDK
import IronSource

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: AppHarbr
        // Initialize AppHarbr SDK

        let configuration = AppHarbrConfigurationBuilder(apiKey: Constants.geoEdgeKey)
//            .withDebugConfig(AppHarbrSdkDebug(debug: true, blockAll: true))
            .withInterstitialAdTimeLimit(30)
            .withMuteAd(true)
            .withTargetedNetworks([.adMob, .appLovin, .chartboost, .fyber])
            .build()

        AH.initializeSdk(configuration: configuration) { error in
            if let error = error {
                print("AppHarbr failed to initialize: \(error.localizedDescription)")
                return
            }
            print("AppHarbr initialized successfully!")
        }
        
        // Initialize the IronSource SDK
        IronSource.initWithAppKey(Constants.appId)
        
        ISIntegrationHelper.validateIntegration()
        
        return true
    }

}

