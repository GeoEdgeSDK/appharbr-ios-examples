//
//  BannerViewController.swift
//  AppharbrDemoApp
//  https://www.apache.org/licenses/LICENSE-2.0.html

import UIKit
import AppLovinSDK
import AppHarbrSDK

class BannerViewController: UIViewController {
    
    /// The banner view.
    private let adView = MAAdView(adUnitIdentifier: Constants.bannerAdUnitID)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adView.delegate = self

        adView.translatesAutoresizingMaskIntoConstraints = false

        // Set background or background color for banners to be fully functional
        adView.backgroundColor = .gray

        view.addSubview(adView)
        
        // Anchor the banner to the left, right, and bottom of the screen.
        adView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true;
        adView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true;
        adView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true;

        adView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true;
        adView.heightAnchor.constraint(equalToConstant: (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50).isActive = true // Banner height on iPhone and iPad is 50 and 90, respectively

        // MARK: AppHarbr
        // Add the adView instance to AppHarbr for Monitoring
        AH.addBanner(with: .max,
                     adObject: adView,
                     delegate: self)

        // Load the first ad
        adView.loadAd()
    }
    
}


extension BannerViewController: AppHarbrDelegate {

    // MARK: AppHarbr AppHarbrDelegate
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AdFormat, reasons: [String]) {
        print("AppHarbr : Ad Blocked")
    }
}

extension BannerViewController: AppHarbrAdAnalyzeDelegate {
    func didAdAnalyzed(ad: NSObject?, adNetwork: AdSdk, unitId: String?, adFormat: AdFormat, result: AdAnalyzedResult) {
        print("Output from ad network \(adNetwork.rawValue), ad unit id: \(unitId ?? ""), with ad result: \(result.description)")
    }
}

extension BannerViewController: MAAdViewAdDelegate {
    func didLoad(_ ad: MAAd) { }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) { }

    func didDisplay(_ ad: MAAd) { }

    func didHide(_ ad: MAAd) { }

    func didClick(_ ad: MAAd) { }

    func didFail(toDisplay ad: MAAd, withError error: MAError) { }

    func didExpand(_ ad: MAAd) { }

    func didCollapse(_ ad: MAAd) { }
}
