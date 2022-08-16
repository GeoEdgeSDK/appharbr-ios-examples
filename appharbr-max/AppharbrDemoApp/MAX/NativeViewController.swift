//
//  NativeViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import AppLovinSDK
import UIKit
import AppHarbrSDK

class NativeViewController: UIViewController {
    
    @IBOutlet weak var nativeAdContainerView: UIView!

    private let nativeAdLoader: MANativeAdLoader = MANativeAdLoader(adUnitIdentifier: Constants.nativeAdUnitID)

    private var nativeAdView: UIView?
    private var nativeAd: MAAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nativeAdLoader.nativeAdDelegate = self
    }

    deinit {
        cleanUpAdIfNeeded()

        nativeAdLoader.nativeAdDelegate = nil
    }

    func cleanUpAdIfNeeded() {
        // Clean up any pre-existing native ad
        if let currentNativeAd = nativeAd {
            nativeAdLoader.destroy(currentNativeAd)
        }

        if let currentNativeAdView = nativeAdView {
            currentNativeAdView.removeFromSuperview()
        }
    }
    
    @IBAction func showAd(_ sender: AnyObject!) {
        cleanUpAdIfNeeded()

        nativeAdLoader.loadAd()
    }
    
}

extension NativeViewController: MANativeAdDelegate
{
    func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd) {
        // MARK: AppHarbr
        // Before displaying, check the ad state
        let adResult = AH.shouldBlock(nativeAd: ad, using: .max)
        if adResult.adStateResult == .blocked {
            print("AppHarbr : Ad Blocked")
            return // Might call to reload
        }

        // Save ad for clean up
        nativeAd = ad

        if let adView = maxNativeAdView
        {
            // Add ad view to view
            nativeAdView = adView
            nativeAdContainerView.addSubview(adView)

            // Set to false if modifying constraints after adding the ad view to your layout
            adView.translatesAutoresizingMaskIntoConstraints = false

            // Set ad view to span width and height of container and center the ad
            nativeAdContainerView.widthAnchor.constraint(equalTo: adView.widthAnchor).isActive = true
            nativeAdContainerView.heightAnchor.constraint(equalTo: adView.heightAnchor).isActive = true
            nativeAdContainerView.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
            nativeAdContainerView.centerYAnchor.constraint(equalTo: adView.centerYAnchor).isActive = true
        }
    }

    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    { }

    func didClickNativeAd(_ ad: MAAd) { }
}
