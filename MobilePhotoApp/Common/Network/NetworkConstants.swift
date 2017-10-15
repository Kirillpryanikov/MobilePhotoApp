//
//  NetworkConstants.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 20.05.17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation

enum NetworkConstants {
    
    static let baseUrl = "http://ec2-52-23-162-156.compute-1.amazonaws.com:8080"
    
    enum Routes {
        
        static let userLogin = "/users/Login"
        static let userRegister = "/users/register"
        
        static let imageUpload = "/api/upload"
        
        static let loginFacebook = "/users/mobile/login/facebook"
        static let loginGoogle = "/users/mobile/login/google"
        
        static let connectFacebook = "/users/mobile/connect/facebook"
        static let connectGoogle = "/users/mobile/connect/google"
    }
    
    enum Parameters {
        
        static let image = "image"
        static let email = "email"
        static let password = "password"
        
        static let success = "success"
    }
    
    enum Headers {
        
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let accessToken = "access_token"
    }
    
}
