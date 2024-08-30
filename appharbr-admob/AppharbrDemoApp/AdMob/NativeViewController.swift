//
//  NativeViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import GoogleMobileAds
import UIKit
import AppHarbrSDK

class NativeViewController: UIViewController {
    
    @IBOutlet weak var nativeAdPlaceholder: UIView!
    @IBOutlet weak var startMutedSwitch: UISwitch!
    @IBOutlet weak var refreshAdButton: UIButton!
    @IBOutlet weak var videoStatusLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var heightConstraint: NSLayoutConstraint?
    var adLoader: GADAdLoader!
    var nativeAdView: GADNativeAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = GADMobileAds.sharedInstance().versionNumber
        versionLabel.text = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        
        guard
            let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            assert(false, "Could not load nib file for adView")
        }
        setAdView(adView)
        refreshAd(nil)
    }
    
    func setAdView(_ view: GADNativeAdView) {
        
        nativeAdView = view
        nativeAdPlaceholder.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    @IBAction func refreshAd(_ sender: AnyObject!) {
        refreshAdButton.isEnabled = false
        videoStatusLabel.text = ""
        adLoader = GADAdLoader(
            adUnitID: Constants.adMobNativeAdUnitID, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
}

extension NativeViewController: GADVideoControllerDelegate {
    
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        videoStatusLabel.text = "Video playback has ended."
    }
}

extension NativeViewController: GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        refreshAdButton.isEnabled = true
    }
}

extension NativeViewController: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
        // MARK: AppHarbr
        let adResult = AH.shouldBlock(nativeAd: nativeAd, using: .adMob, unitId: Constants.adMobNativeAdUnitID)
        if adResult.adStateResult == .blocked {
            print("AppHarbr : Ad Blocked")
            return // Might call to reload
        }
        
        refreshAdButton.isEnabled = true
        
        nativeAd.delegate = self
        
        heightConstraint?.isActive = false
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            mediaContent.videoController.delegate = self
            videoStatusLabel.text = "Ad contains a video asset."
        } else {
            videoStatusLabel.text = "Ad does not contain a video."
        }
        
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint?.isActive = true
        }
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
        
    }
}

extension NativeViewController: GADNativeAdDelegate {
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
}
