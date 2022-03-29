//
//  AppDelegate.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import UIKit
import OtterScaleiOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        NumberLaunches().launch()
        
        let vc = SplashViewController.make()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        FacebookManager.shared.initialize(app: application, launchOptions: launchOptions)
        BranchManager.shared.initialize(launchOptions: launchOptions)
        AmplitudeManager.shared.initialize()
        FirebaseManager.shared.initialize()
        OtterScale.shared.initialize(host: GlobalDefinitions.otterScaleHost, apiKey: GlobalDefinitions.otterScaleApiKey)
        
        PurchaseValidationObserver.shared.startObserve()
        
        IAPManager.initialize()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        FacebookManager.shared.application(app, open: url, options: options)
        BranchManager.shared.application(app, open: url, options: options)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        BranchManager.shared.application(continue: userActivity)
        
        return true
    }
}
