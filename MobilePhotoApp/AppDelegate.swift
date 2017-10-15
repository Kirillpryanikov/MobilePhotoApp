//
//  AppDelegate.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 4/20/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Initialize Facebook SDK
    //
    SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    registerDefaults()
    
    return true
  }
  
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    if(url.scheme!.isEqual("fb257947898002169")) {
      return SDKApplicationDelegate.shared.application(app, open: url, options: options)
      
    } else {
      return GIDSignIn.sharedInstance().handle(url as URL!,
                                               sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
                                               annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
  }
  
  func registerDefaults() {
    
    UserDefaults.standard.register(defaults:[
      UDKeys.camSettings.numberOfPhotos: 1,
      UDKeys.camSettings.startingFocalLength: 0.5,
      UDKeys.camSettings.focalLengthDelta: 0.05,
      UDKeys.camSettings.WBR: 1.8,
      UDKeys.camSettings.WBG: 0.7,
      UDKeys.camSettings.WBB: 2.6,
      UDKeys.camSettings.delayTime: 0,
      UDKeys.camSettings.zoom: 0.0
      ])
    
  }
  
  
}

