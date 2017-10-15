//
//  UserManager.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 5/13/17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation

class UserManager {
    
    static let sharedInstance = UserManager()
    
    var email: String?
    
    // Store accessToken in UserDefaults
    //
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "com.tweezar.photoApp.accessToken")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "com.tweezar.photoApp.accessToken")
        }
    }
    
}
