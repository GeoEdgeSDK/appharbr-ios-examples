//
//  RewardedViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import GoogleMobileAds
import UIKit
import AppHarbrSDK

class RewardedViewController: UIViewController, GADFullScreenContentDelegate {
    
    enum GameState: NSInteger {
        case notStarted
        case playing
        case paused
        case ended
    }
    
    let gameOverReward = 1
    let gameLength = 10
    var coinCount = 0
    var rewardedAd: GADRewardedAd?
    var timer: Timer?
    var counter = 10
    var gameState = GameState.notStarted
    var pauseDate: Date?
    var previousFireDate: Date?
    
    @IBOutlet weak var gameText: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var coinCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: AppHarbr
        // In order to let AppHarbr SDK monitor the Rewarded
        AH.addRewarded(with: .adMob, delegate: self)
        
        coinCountLabel.text = "Coins: \(self.coinCount)"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RewardedViewController.applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RewardedViewController.applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        
        startNewGame()
    }
    
    
    fileprivate func startNewGame() {
        
        // MARK: AppHarbr
        // In order to avoid memory leak, the publisher should remove the Rewarded monitoring instance once the ad is closed using removeRewarded method.
        AH.removeRewarded(ad: self.rewardedAd)
        
        gameState = .playing
        counter = gameLength
        playAgainButton.isHidden = true
        
        GADRewardedAd.load(
            withAdUnitID: Constants.adMobRewardedAdUnitID, request: GADRequest()
        ) { (ad, error) in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            print("Loading Succeeded")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
        
        gameText.text = String(counter)
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(RewardedViewController.timerFireMethod(_:)),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        if gameState != .playing {
            return
        }
        gameState = .paused
        
        pauseDate = Date()
        previousFireDate = timer?.fireDate
        
        timer?.fireDate = Date.distantFuture
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        if gameState != .paused {
            return
        }
        gameState = .playing
        
        let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1
        
        timer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
    }
    
    @objc func timerFireMethod(_ timer: Timer) {
        counter -= 1
        if counter > 0 {
            gameText.text = String(counter)
        } else {
            endGame()
        }
    }
    
    fileprivate func earnCoins(_ coins: NSInteger) {
        coinCount += coins
        coinCountLabel.text = "Coins: \(self.coinCount)"
    }
    
    fileprivate func endGame() {
        gameState = .ended
        gameText.text = "Game over!"
        playAgainButton.isHidden = false
        timer?.invalidate()
        timer = nil
        earnCoins(gameOverReward)
    }
    
    @IBAction func playAgain(_ sender: AnyObject) {
        if let ad = rewardedAd {
            // MARK: AppHarbr
            if AH.getRewardedState(ad: ad) != .blocked {
                ad.present(fromRootViewController: self) {
                    let reward = ad.adReward
                    print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                    self.earnCoins(NSInteger(truncating: reward.amount))
                    // Reward the user.
                }
            } else {
                print("Do Not Display - AppHarbr Blocked Interstitial Ad")
            }
        } else {
            let alert = UIAlertController(
                title: "Rewarded ad isn't available yet.",
                message: "The rewarded ad cannot be shown at this time",
                preferredStyle: .alert)
            let alertAction = UIAlertAction(
                title: "OK",
                style: .cancel,
                handler: { [weak self] action in
                    self?.startNewGame()
                })
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad presented.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad dismissed.")
    }
    
    func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        // MARK: AppHarbr
        // In order to avoid memory leak, the publisher should remove the Rewarded monitoring instance once the ad is closed using removeRewarded method.
        AH.removeRewarded(ad: self.rewardedAd)
        print("Rewarded ad failed to present with error: \(error.localizedDescription).")
        let alert = UIAlertController(
            title: "Rewarded ad failed to present",
            message: "The reward ad could not be presented.",
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title: "Drat",
            style: .cancel,
            handler: { [weak self] action in
                self?.startNewGame()
            })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        
        // MARK: AppHarbr
        // In order to avoid memory leak, the publisher should remove the Rewarded monitoring instance once the ad is closed using removeRewarded method.
        AH.removeRewarded(ad: self.rewardedAd)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension RewardedViewController: AppHarbrDelegate {

    // MARK: AppHarbr AppHarbrDelegate
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AdFormat, reasons: [String]) {
        print("AppHarbr : Ad Blocked")
    }
}
