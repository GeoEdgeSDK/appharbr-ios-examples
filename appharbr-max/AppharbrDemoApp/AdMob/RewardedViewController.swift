//
//  RewardedViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import AppLovinSDK
import UIKit
import AppHarbrSDK

class RewardedViewController: UIViewController {
    
    private let rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: Constants.rewardedAdUnitID)
    private var retryAttempt = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        rewardedAd.delegate = self

        // MARK: AppHarbr
        // In order to let AppHarbr SDK monitor the interstitial
        AH.addRewarded(with: .max,
                       rewardedAd: rewardedAd,
                       delegate: self)
        // Load the first ad
        rewardedAd.load()
    }

    
    @IBAction func showAd(_ sender: AnyObject) {
        if AH.getRewardedState(ad: rewardedAd) != .blocked {
            rewardedAd.show()
        } else {
            print("Do Not Display - AppHarbr Blocked Interstitial Ad")
        }
    }
}

extension RewardedViewController: AppHarbrDelegate {

    // MARK: AppHarbr AppHarbrDelegate
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AdFormat, reasons: [String]) {
        print("AppHarbr : Ad Blocked")
    }
}

extension RewardedViewController: MARewardedAdDelegate {
    func didLoad(_ ad: MAAd) {
        // Reset retry attempt
        retryAttempt = 0
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))

        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.rewardedAd.load()
        }
    }

    func didDisplay(_ ad: MAAd) { }

    func didClick(_ ad: MAAd) { }

    func didExpand(_ ad: MAAd) { }

    func didCollapse(_ ad: MAAd) { }

    func didHide(_ ad: MAAd) {
        // Interstitial ad is hidden. Pre-load the next ad
        rewardedAd.load()
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        // Interstitial ad failed to display. We recommend loading the next ad
        rewardedAd.load()
    }

    func didStartRewardedVideo(for ad: MAAd) { }

    func didCompleteRewardedVideo(for ad: MAAd) { }

    func didRewardUser(for ad: MAAd, with reward: MAReward) {}
}
