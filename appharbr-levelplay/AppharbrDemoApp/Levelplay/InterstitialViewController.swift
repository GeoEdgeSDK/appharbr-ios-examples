//
//  InterstitialViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import AppHarbrSDK
import IronSource

class InterstitialViewController: UIViewController {
    
    enum GameState: NSInteger {
        case notStarted
        case playing
        case paused
        case ended
    }
    
    static let gameLength = 5
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
        AH.addInterstitial(with: .ironSource,
                           delegate: self)
        
        IronSource.setLevelPlayInterstitialDelegate(self)
        
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
        IronSource.loadInterstitial()
        
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
                guard let self else { return }
                // MARK: AppHarbr
                if AH.interstitialResult(forAdUnitId: Constants.interstitialAdUnitID).adStateResult != .blocked {
                    print("AppHarbr Permit display")
                    IronSource.showInterstitial(with: self)
                } else {
                    print("Do Not Display - AppHarbr Blocked Interstitial Ad")
                }
                
                self.playAgainButton.isHidden = false
            })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func playAgain(_ sender: AnyObject) {
        startNewGame()
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
    func didAdAnalyzed(ad: NSObject?,
                       adNetwork: AppHarbrSDK.AdSdk,
                       unitId: String?,
                       adFormat: AppHarbrSDK.AdFormat,
                       result: AppHarbrSDK.AdAnalyzedResult) {
        print("Output from ad network \(adNetwork.rawValue), ad unit id: \(unitId ?? ""), with ad result \(result.description)")
    }
}

extension InterstitialViewController: LevelPlayInterstitialDelegate {
    func didLoad(with adInfo: ISAdInfo!) { }
    
    func didFailToLoadWithError(_ error: (any Error)!) { }
    
    func didOpen(with adInfo: ISAdInfo!) {
        print("Ad did open.")
    }
    
    func didShow(with adInfo: ISAdInfo!) {
        print("Ad did show.")
    }
    
    func didFailToShowWithError(_ error: (any Error)!, andAdInfo adInfo: ISAdInfo!) { }
    
    func didClick(with adInfo: ISAdInfo!) { }
    
    func didClose(with adInfo: ISAdInfo!) {
        print("Ad did close.")
    }
}
