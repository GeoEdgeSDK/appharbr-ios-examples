//
//  InterstitialViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import AppLovinSDK
import AppHarbrSDK

class InterstitialViewController: UIViewController {
    
    private let interstitialAd = MAInterstitialAd(adUnitIdentifier: Constants.interstitialAdUnitID)
    private var retryAttempt = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        interstitialAd.delegate = self

        // MARK: AppHarbr
        // In order to let AppHarbr SDK monitor the interstitial
        AH.addInterstitial(with: .max,
                           interstitialAd: interstitialAd,
                           delegate: self)

        // Load the first ad
        interstitialAd.load()
    }
    
    @IBAction func showAd(_ sender: AnyObject) {
        // MARK: AppHarbr
        // Before displaying, check the ad state
        if AH.getInterstitialState(ad: interstitialAd) != .blocked {
            interstitialAd.show()
        } else {
            print("Do Not Display - AppHarbr Blocked Interstitial Ad")
        }
    }
    
}

extension InterstitialViewController: AppHarbrDelegate {

    // MARK: AppHarbr AppHarbrDelegate
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AdFormat, reasons: [String]) {
        print("AppHarbr : Ad Blocked")
    }
}

extension InterstitialViewController: MAAdViewAdDelegate {
    func didLoad(_ ad: MAAd) {
        // Reset retry attempt
        retryAttempt = 0
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))

        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.interstitialAd.load()
        }
    }

    func didDisplay(_ ad: MAAd) { }

    func didClick(_ ad: MAAd) { }

    func didExpand(_ ad: MAAd) { }

    func didCollapse(_ ad: MAAd) { }

    func didHide(_ ad: MAAd) {
        // Interstitial ad is hidden. Pre-load the next ad
        interstitialAd.load()
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        // Interstitial ad failed to display. We recommend loading the next ad
        interstitialAd.load()
    }

}
