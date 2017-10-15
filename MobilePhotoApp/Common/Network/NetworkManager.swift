//
//  NetworkManager.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 5/13/17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import Alamofire


class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    // SignIn Request
    //
    open func signInRequest(withSuccess successBlock: ((String) -> Void)? = nil,
                            failure failureBlock: ((String?) -> Void)? = nil,
                            parameters: [String: Any]) {
        
        let url = URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.userLogin)
        
        Alamofire.request(url!,
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { (response) in
                            
                            print("RESPONSE: ", response)
                            
                            var isSuccess = false
                            var resultError: String?
                            
                            
                            
                            if response.error == nil {
                                if let json = response.result.value as? [String: Any] {
                                    if let success = json[NetworkConstants.Parameters.success] as? Bool, success {
                                        
                                        isSuccess = true
                                        if successBlock != nil {
                                            
                                            let token = response.response?.allHeaderFields[NetworkConstants.Headers.authorization] as! String
                                            successBlock!(token)
                                        }
                                    } else {
                                        if let message = json["message"] as? String {
                                            resultError = message
                                        }
                                    }
                                }
                            } else {
                                resultError = response.error?.localizedDescription
                            }
                            
                            if !isSuccess {
                                if failureBlock != nil {
                                    failureBlock!(resultError)
                                }
                            }
        }
    }
    
    // SignUp Request
    //
    open func signUpRequest(withSuccess successBlock: (() -> Void)? = nil,
                            failure failureBlock: ((String?) -> Void)? = nil,
                            parameters: [String: Any]) {
        
        let url = URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.userRegister)
        
        Alamofire.request(url!,
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { (response) in
                            
                            print("RESPONSE: ", response)
                            
                            var isSuccess = false
                            var resultError: String?
                            
                            if response.error == nil {
                                if let json = response.result.value as? [String: Any] {
                                    if let success = json[NetworkConstants.Parameters.success] as? Bool, success {
                                        
                                        isSuccess = true
                                        if successBlock != nil {
                                            successBlock!()
                                        }
                                    } else {
                                        if let message = json["message"] as? String {
                                            resultError = message
                                        }
                                    }
                                }
                            } else {
                                resultError = response.error?.localizedDescription
                            }
                            
                            if !isSuccess {
                                if failureBlock != nil {
                                    failureBlock!(resultError)
                                }
                            }
        }
    }
    
    // Image Uploading Request. Binary
    //
    open func uploadImageRequest(withSuccess successBlock: (() -> Void)? = nil,
                                 failure failureBlock: ((String?) -> Void)? = nil,
                                 images: [UIImage], token: String) {
        
        if images.count > 0 {

            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                for (index, image) in images.enumerated() {
                    if let imageData: Data = UIImageJPEGRepresentation(image, 0.5) {
                        
                        print("Append form data filename\(index).jpg")
                        multipartFormData.append(imageData, withName: "files", fileName: "filename\(index).jpg", mimeType: "image/jpeg")
                    }
                }
                
            }, usingThreshold: UInt64.init(),
               to: URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.imageUpload)!,
               method: .post,
               headers: [NetworkConstants.Headers.authorization: token],
               encodingCompletion: { (encodingResult) in
                
                debugPrint(encodingResult)
                
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print(progress.localizedDescription)
                    })
                    
                    upload.response(completionHandler: { (dataResponse) in
                        print("Data Response: ")
                        debugPrint(dataResponse)
                    })
                    
                    upload.responseJSON { response in
                        print(response.result)
                        
                        var isSuccess = false
                        var resultError: String?
                        
                        if response.error == nil {
                            if let json = response.result.value as? [String: Any] {
                                if let success = json[NetworkConstants.Parameters.success] as? Bool, success {
                                    
                                    isSuccess = true
                                    if successBlock != nil {
                                        successBlock!()
                                    }
                                } else {
                                    if let message = json["message"] as? String {
                                        resultError = message
                                    }
                                }
                            }
                        } else {
                            resultError = response.error?.localizedDescription
                        }
                        
                        if !isSuccess {
                            if failureBlock != nil {
                                failureBlock!(resultError)
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    
                    print("ERROR RESPONSE: \(encodingError.localizedDescription)")
                    if failureBlock != nil {
                        failureBlock!(encodingError.localizedDescription)
                    }
                }
            })
        }
    }
    
    // Login with Facebook Request
    //
    open func loginFacebookRequest(withSuccess successBlock: ((String) -> Void)? = nil,
                                   failure failureBlock: ((Error) -> Void)? = nil,
                                   facebookToken: String) {
        
        let url = URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.loginFacebook)
        
        Alamofire.request(url!,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: ["access_token": facebookToken]).responseJSON { (response) in
                            
                            debugPrint(response)
                            
                            if let error = response.error {
                                
                                failureBlock?(error)
                                
                            } else if let status = response.response?.statusCode, let result = response.result.value {
                                
                                let JSON = result as! NSDictionary
                                print("JSON: ", JSON)
                                
                                switch(status){
                                case 200:
                                    successBlock?(response.response?.allHeaderFields[NetworkConstants.Headers.authorization] as! String)
                                    
                                default:
                                    print("error with response status: \(status)")
                                    let error = NSError(domain: "Tweezar", code: status, userInfo: JSON as? [AnyHashable : Any])
                                    failureBlock?(error)
                                }
                            }
        }
        
    }
    
    // Login with Google Request
    //
    open func loginGoogleRequest(withSuccess successBlock: ((String) -> Void)? = nil,
                                 failure failureBlock: ((Error) -> Void)? = nil,
                                 googleToken: String) {
        
        let url = URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.loginGoogle)
        
        Alamofire.request(url!,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: ["access_token": googleToken]).responseJSON { (response) in
                            
                            debugPrint("RERPONSE FROM SERVER: ", response)
                            
                            if let error = response.error {
                                
                                failureBlock?(error)
                                
                            } else if let status = response.response?.statusCode, let result = response.result.value {
                                
                                let JSON = result as! NSDictionary
                                print("JSON: ", JSON)
                                print("\n\n\n\n============")
                                
                                switch(status){
                                case 200:
                                    successBlock?(response.response?.allHeaderFields[NetworkConstants.Headers.authorization] as! String)
                                    
                                default:
                                    print("error with response status: \(status)")
                                    let error = NSError(domain: "Tweezar", code: status, userInfo: JSON as? [AnyHashable : Any])
                                    failureBlock?(error)
                                }
                            }
        }
    }
    
    // Facebook connect Request
    //
    open func connectFacebookRequest(withSuccess successBlock: (() -> Void)? = nil,
                                     failure failureBlock: ((Error) -> Void)? = nil,
                                     facebookToken: String,
                                     accessToken: String) {
        
        let url = URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.connectFacebook)
        
        Alamofire.request(url!,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: [NetworkConstants.Headers.accessToken: facebookToken,
                                    NetworkConstants.Headers.authorization: accessToken]).responseJSON { (response) in
                                        
                                        debugPrint("RERPONSE FROM SERVER: ", response)
                                        
                                        if let error = response.error {
                                            
                                            failureBlock?(error)
                                            
                                        } else if let status = response.response?.statusCode, let result = response.result.value {
                                            
                                            let JSON = result as! NSDictionary
                                            print("JSON: ", JSON)
                                            print("\n\n\n\n============")
                                            
                                            switch(status){
                                            case 200:
                                                successBlock?()
                                                
                                            default:
                                                print("error with response status: \(status)")
                                                let error = NSError(domain: "Tweezar", code: status, userInfo: JSON as? [AnyHashable : Any])
                                                failureBlock?(error)
                                            }
                                        }
        }
    }
    
    // Google connect request
    //
    open func connectGoogleRequest(withSuccess successBlock: (() -> Void)? = nil,
                                   failure failureBlock: ((Error) -> Void)? = nil,
                                   googleToken: String,
                                   accessToken: String) {
        
        let url = URL(string: NetworkConstants.baseUrl + NetworkConstants.Routes.connectGoogle)
        
        Alamofire.request(url!,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: [NetworkConstants.Headers.accessToken: googleToken,
                                    NetworkConstants.Headers.authorization: accessToken]).responseJSON { (response) in
                                        
                                        debugPrint("RERPONSE FROM SERVER: ", response)
                                        
                                        if let error = response.error {
                                            
                                            failureBlock?(error)
                                            
                                        } else if let status = response.response?.statusCode, let result = response.result.value {
                                            
                                            let JSON = result as! NSDictionary
                                            print("JSON: ", JSON)
                                            print("\n\n\n\n============")
                                            
                                            switch(status){
                                            case 200:
                                                successBlock?()
                                                
                                            default:
                                                print("error with response status: \(status)")
                                                let error = NSError(domain: "Tweezar", code: status, userInfo: JSON as? [AnyHashable : Any])
                                                failureBlock?(error)
                                            }
                                        }
        }
        
    }
}

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}







