//
//  AppDelegate.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import UIKit
import OtterScaleiOS
import RushSDK
import RxCocoa

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    lazy var sdkProvider = SDKProvider()
    
    private lazy var generateStepInSplash = PublishRelay<Bool>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        NumberLaunches().launch()
        
        let vc = SplashViewController.make(generateStep: generateStepInSplash.asSignal())
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        FacebookManager.shared.initialize(app: application, launchOptions: launchOptions)
        BranchManager.shared.initialize(launchOptions: launchOptions)
        AmplitudeManager.shared.initialize()
        FirebaseManager.shared.initialize()
        OtterScale.shared.initialize(host: GlobalDefinitions.otterScaleHost, apiKey: GlobalDefinitions.otterScaleApiKey)
        
        PurchaseValidationObserver.shared.startObserve()
        TestCloseObserver.shared.startObserve()
        
        IAPManager.initialize()
        
        runProvider(on: vc.view)
        
        sdkProvider.application(application, didFinishLaunchingWithOptions: launchOptions)
        SDKStorage.shared.pushNotificationsManager.application(didFinishLaunchingWithOptions: launchOptions)
        
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

// MARK: Private
private extension AppDelegate {
    func runProvider(on view: UIView) {
        let settings = SDKSettings(backendBaseUrl: GlobalDefinitions.rushSDKHost,
                                   backendApiKey: GlobalDefinitions.rushSDKApiKey,
                                   amplitudeApiKey: GlobalDefinitions.amplitudeApiKey,
                                   appsFlyerApiKey: nil,
                                   facebookActive: false,
                                   branchActive: false,
                                   firebaseActive: false,
                                   applicationTag: GlobalDefinitions.applicationTag,
                                   userToken: SessionManager().getSession()?.userToken,
                                   userId: nil,
                                   view: view,
                                   shouldAddStorePayment: true,
                                   featureAppBackendUrl: nil,
                                   featureAppBackendApiKey: nil,
                                   appleAppID: GlobalDefinitions.appleAppID)
        
        sdkProvider.initialize(settings: settings) { [weak self] success in
            self?.generateStepInSplash.accept(true)
        }
    }
}
