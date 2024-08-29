//
//  InterstitialViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import GoogleMobileAds
import AppHarbrSDK

class InterstitialViewController: UIViewController, GADFullScreenContentDelegate {
    
    enum GameState: NSInteger {
        case notStarted
        case playing
        case paused
        case ended
    }
    
    static let gameLength = 5
    var interstitial: GADInterstitialAd?
    var timer: Timer?
    var timeLeft = gameLength
    var gameState = GameState.notStarted
    var pauseDate: Date?
    var previousFireDate: Date?
    
    @IBOutlet weak var gameText: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: AppHarbr
        // In order to let AppHarbr SDK monitor the interstitial
        AH.addInterstitial(with: .adMob,
                           unitId: Constants.adMobInterstitialAdUnitID,
                           delegate: self)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(InterstitialViewController.pauseGame),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(InterstitialViewController.resumeGame),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        
        startNewGame()
    }
    
    fileprivate func startNewGame() {
        loadInterstitial()
        
        gameState = .playing
        timeLeft = InterstitialViewController.gameLength
        playAgainButton.isHidden = true
        updateTimeLeft()
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(InterstitialViewController.decrementTimeLeft(_:)),
            userInfo: nil,
            repeats: true)
    }
    
    fileprivate func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: Constants.adMobInterstitialAdUnitID, request: request
        ) { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    fileprivate func updateTimeLeft() {
        gameText.text = "\(timeLeft) seconds left!"
    }
    
    @objc func decrementTimeLeft(_ timer: Timer) {
        timeLeft -= 1
        updateTimeLeft()
        if timeLeft == 0 {
            endGame()
        }
    }
    
    @objc func pauseGame() {
        if gameState != .playing {
            return
        }
        gameState = .paused
        
        pauseDate = Date()
        previousFireDate = timer?.fireDate
        
        timer?.fireDate = Date.distantFuture
    }
    
    @objc func resumeGame() {
        if gameState != .paused {
            return
        }
        gameState = .playing
        
        let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1
        
        timer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
    }
    
    fileprivate func endGame() {
        gameState = .ended
        timer?.invalidate()
        timer = nil
        
        let alert = UIAlertController(
            title: "Game Over",
            message: "You lasted \(InterstitialViewController.gameLength) seconds",
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: { [weak self] action in
                if let ad = self?.interstitial {
                    // MARK: AppHarbr
                    if AH.interstitialResult(forAd: ad).adStateResult != .blocked {
                        print("AppHarbr Permit display")
                        ad.present(fromRootViewController: self!)
                    } else {
                        print("Do Not Display - AppHarbr Blocked Interstitial Ad")
                    }
                } else {
                    print("Ad wasn't ready")
                }
                self?.playAgainButton.isHidden = false
            })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func playAgain(_ sender: AnyObject) {
        startNewGame()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)
    {
        print("Ad failed to present full screen content with error \(error.localizedDescription).")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
    
    deinit {        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

extension InterstitialViewController: AppHarbrDelegate {

    // MARK: AppHarbr AppHarbrDelegate
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AdFormat, reasons: [String]) {
        print("AppHarbr : Ad Blocked")
    }
}

extension InterstitialViewController: AppHarbrAdAnalyzeDelegate {
    
    func didAdAnalyzed(ad: NSObject?, adNetwork: AdSdk, unitId: String?, adFormat: AdFormat, result: AdAnalyzedResult) {
        print("Output from ad network \(adNetwork.rawValue), ad unit id: \(unitId ?? ""), with ad result: \(result.description)")
    }
}
