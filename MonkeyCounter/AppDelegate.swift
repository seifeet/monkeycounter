//
//  AppDelegate.swift
//  MonkeyCounter
//
//  Created by AT on 9/13/16.
//  Copyright © 2016 AT. All rights reserved.
//

import UIKit
import CoreData
import Swinject
import SwinjectStoryboard
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let appDependencies = AppDependencies()

    let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        log.verbose("🇮🇱 App Launched (didFinihLaunchingWithOptions). 🇮🇱")
        
        // start location monitoring
        let eventStore = appDependencies.container.resolve(EventStoreModeling.self)!
        
        eventStore.fetchAll(force: true) {
            eventStore.subscribe()
            eventStore.startMonitoring()
        }

        // load the root view
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        
        let bundle = Bundle(for: EventFeedVC.self)
        let storyboard = SwinjectStoryboard.create(name: Constants.MainBundleName,
                                                   bundle: bundle,
                                                   container: appDependencies.container)
        window.rootViewController = storyboard.instantiateInitialViewController()
        
        self.window = window
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        log.verbose("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        log.verbose("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        log.verbose("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        log.verbose("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        let manager = appDependencies.container.resolve(ATCoreDataManager.self)
//        manager?.save()
        log.verbose("applicationWillTerminate")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        guard let text = notification.alertBody else { return }
        switch UIApplication.shared.applicationState {
        case .active:
            log.debug("active \(text)")
//            AlertWrapper.statusBarMessage(withTitle: "notification", andBody: text)
        case .background:
            log.debug("background \(text)")
        case .inactive:
            log.debug("inactive \(text)")
        }
        
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log.debug("Current time is: \(Date())")
        completionHandler(.newData)
    }
    
    // MARK:- Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        log.debug("Did register for remote notifications \(deviceToken)")
    }
    
    /// Register for local notifications (alerts, sounds, badges)
    func registerForLocalNotifications() {
        
        // local notifications
        if #available(iOS 10.0, *) {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: options) {
                (granted, error) in
                if !granted {
                    log.error("Failed to register for local notifications.")
                }
            }
            
        } else {
            // Fallback on earlier versions
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.cancelAllLocalNotifications()
        }
    
    }
    
    // MARK: - Private stuff
    fileprivate struct Constants {
        static let MainBundleName: String = "Main"
    }
}

