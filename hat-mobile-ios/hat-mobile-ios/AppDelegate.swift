/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit
import CoreLocation
import Fabric
import Crashlytics
import Stripe

// MARK: Class

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    // MARK: - Variables
    
    var window: UIWindow?
    var deferringUpdates: Bool = false
    var lastPos: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    /// Load the LocationManager
    lazy var locationManager: CLLocationManager! = {
        
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = MapsHelper.GetUserPreferencesAccuracy()
        locationManager.distanceFilter = MapsHelper.GetUserPreferencesDistance()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.otherNavigation /* see https://developer.apple.com/reference/corelocation/clactivitytype */
        return locationManager
    }()
    
    // MARK: - App Delegate methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        STPPaymentConfiguration.shared().publishableKey = "pk_live_IkuCnCV8N48VKdcMfbfb1Mp7"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.com.hubofallthings.rumpellocationtracker"

        // if app was closed by iOS (low mem, etc), then receives a location update, and respawns your app, letting it know it respawned due to a location service
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            
            //return true
        }
        startUpdatingLocation()
        
        // change tab bar item font        
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Open Sans Condensed", size: 11)!], for: UIControlState.normal)
        
        // change bar button item font
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17)!], for: UIControlState.normal)
        
        // define the interval for background fetch interval
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // register for user notifications
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        /* we already have a hat_domain, ie. can skip the login screen? */
        if !HatAccountService.TheUserHATDomain().isEmpty {
            
            /* Go to the map screen. */
            let nav: UINavigationController = window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let tabController = storyboard.instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
            nav.setViewControllers([tabController], animated: false)
        } else {
            /* Just fall through to go to the login screen as per the storyboard. */
        }
        
        self.window?.tintColor = Constants.Colours.AppBase
        
        // the count delegate
        //self.updateCountDelegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if (lastPos.horizontalAccuracy <= locationManager.desiredAccuracy) {
            
            let taskID = beginBackgroundUpdateTask()
            let syncHelper = SyncDataHelper()
            if syncHelper.CheckNextBlockToSync() == true {
                
                // we probably need something like syncHelper.CheckNextBlockToSync(self.endBackgroundUpdateTask(taskID: taskID))
                // do things in the background fetch
                completionHandler(.newData)
            } else {
                
                completionHandler(.noData)
            }
            self.endBackgroundUpdateTask(taskID: taskID)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // cancel all notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        // date
        let timeInterval:TimeInterval = FutureTimeInterval.init(days: Double(3), timeType: TimeType.future).interval
        let futureDate = Date().addingTimeInterval(timeInterval) // e.g. 3 days from now
        // add new
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = NSLocalizedString("sync_reminder_title", comment: "title")
        localNotification.alertBody = NSLocalizedString("sync_reminder_message", comment: "message")
        localNotification.fireDate = futureDate
        localNotification.timeZone = TimeZone.current
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // purge old data
        purgeUsingPredicate()
        
        // stopUpdatingLocation
//        if let _:CLLocationManager = locationManager {
//            
//            manager.stopUpdatingLocation()
//            NSLog("Delegate stopUpdatingLocation");
//        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - oAuth handler function
    
    /*
     Callback handler oAuth
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let urlHost: String = url.host {
            
            if urlHost == Constants.Auth.LocalAuthHost {
                
                let result = KeychainHelper.GetKeychainValue(key: "logedIn")
                if result == "true" {
                    
                    NotificationCenter.default.post(name: Notification.Name("reauthorisedUser"), object: url)
                } else {
                  
                    let notification = Notification.Name(Constants.Auth.NotificationHandlerName)
                    NotificationCenter.default.post(name: notification, object: url)
                    _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "true")
                }
            } else if urlHost == "dataplugsapphost" {
                
                let notification = Notification.Name("dataPlugMessage")
                NotificationCenter.default.post(name: notification, object: url)
            }
        }
        return true
    }
    
    // MARK: - Purge data
    
    /**
     Check if we need to purge old data. 7 Days
     */
    func purgeUsingPredicate() -> Void {
        
        let lastWeek = Date().addingTimeInterval(FutureTimeInterval.init(days: Constants.PurgeData.OlderThan, timeType: TimeType.past).interval)
        let predicate = NSPredicate(format: "dateAdded <= %@", lastWeek as CVarArg)
        
        // use _ to get rid of result is unused warnings
        _ = RealmHelper.Purge(predicate)
    }
    
    // MARK: - Location Manager Delegate Functions
    
    /**
     The CLLocationManagerDelegate delegate
     Called when location update changes
     
     - parameter manager:   The CLLocation manager used
     - parameter locations: Array of locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get last location
        let latestLocation: CLLocation = locations[locations.count - 1]
        var dblocation: CLLocation? = nil
        var timeInterval: TimeInterval = TimeInterval()

        if let dbLastPoint = RealmHelper.GetLastDataPoint() {

            dblocation = CLLocation(latitude: (dbLastPoint.lat), longitude: (dbLastPoint.lng))
            let lastRecordedDate = dbLastPoint.dateAdded
            timeInterval = Date().timeIntervalSince(lastRecordedDate)
        }

        // test that the horizontal accuracy does not indicate an invalid measurement
        if (latestLocation.horizontalAccuracy < 0) {

            return
        }
        
        // check we have a measurement that meets our requirements,
        if ((latestLocation.horizontalAccuracy <= locationManager.desiredAccuracy)) || !(timeInterval.isLess(than: 3600)) {

            if (dblocation != nil) {

                //calculate distance from previous spot
                let distance = latestLocation.distance(from: dblocation!)
                if !distance.isLess(than: locationManager.distanceFilter - (latestLocation.horizontalAccuracy + dblocation!.horizontalAccuracy)) {

                    // add data
                    _ = RealmHelper.AddData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
                    let syncHelper = SyncDataHelper()
                    _ = syncHelper.CheckNextBlockToSync()
                }
            } else {

                // add data
                _ = RealmHelper.AddData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
                let syncHelper = SyncDataHelper()
                _ = syncHelper.CheckNextBlockToSync()
            }
        }
    }
    
    func startUpdatingLocation() -> Void {
        
        /*
         If not authorised, we can ignore.
         Onve user us logged in and has accepted the authorization, this will always be true
         */
        if let manager:CLLocationManager = locationManager {
            
            if let result = KeychainHelper.GetKeychainValue(key: "trackDevice") {
                
                if result == "true" {
                    
                    manager.startUpdatingLocation()
                    NSLog("Delegate startUpdatingLocation");
                }
            } else {
                
                _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
                manager.startUpdatingLocation()
                NSLog("Delegate startUpdatingLocation");
            }
        }
    }
    
    //didFinishDeferredUpdatesWithError:
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        // Stop deferring updates
        self.deferringUpdates = false
    }
    
    // MARK: - Background Task Functions
    
    // background task
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        
        UIApplication.shared.endBackgroundTask(taskID)
    }
}
