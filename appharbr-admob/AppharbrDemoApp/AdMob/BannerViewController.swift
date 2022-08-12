//
//  BannerViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import GoogleMobileAds
import AppHarbrSDK

class BannerViewController: UIViewController {
    
    /// The banner view.
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.adUnitID = Constants.adMobBannerAdUnitID
        bannerView.rootViewController = self
        
        // MARK: AppHarbr
        // Add the adView instance to AppHarbr for Monitoring
        AH.addBanner(with: .adMob,
                     adObject: bannerView,
                     delegate: self)
        
        bannerView.load(GADRequest())
    }
    
}


extension BannerViewController: AppHarbrDelegate {

    // MARK: AppHarbr AppHarbrDelegate
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AdFormat, reasons: [String]) {
        print("AppHarbr : Ad Blocked")
    }
}
