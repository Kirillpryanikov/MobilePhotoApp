//
//  LoginViewController.swift
//  MobilePhotoApp
//
//  Created by User on 4/20/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit

let errorDefaultTitle = "Error"

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var btnGoogleSignIn: GIDSignInButton!
    @IBOutlet weak var btnFacebookButton: FBSDKLoginButton!
    
    //
    // MARK: - UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Tap action
        //
        addTapRecognizer()
        
        // Initialize Google sign-in
        //
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if let token = UserManager.sharedInstance.accessToken {
            if token.characters.count > 0 {
                
                successLogin(token: token)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXME: for tests
        //
//         txtLogin.text = "test1@gmail.com"
//         txtPassword.text = "test1"
      
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
  
    //
    // MARK: - Tap action
    //
    
    private func addTapRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func tapAction(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //
    // MARK: - Loading View
    //
    
    fileprivate func showLoadingViewWith(_ message: String) {
        
        loadingView.isHidden = false
        loadingLabel.text = message
        
        view.isUserInteractionEnabled = false
    }
    
    fileprivate func hideLoadingView() {
        
        loadingView.isHidden = true
        loadingLabel.text = ""
        
        view.isUserInteractionEnabled = true
    }
    
    //
    // MARK: -
    //
    
    @IBAction func signInPressed(_ sender: UIButton) {
        
        if !checkInputFieldsValues() {
            return
        }
        
        showLoadingViewWith("SignIn...")
        
        NetworkManager.sharedInstance.signInRequest(withSuccess: { (token) in
            
            self.hideLoadingView()
            
            print("Login success. Token: ", token)
            self.successLogin(token: token)
        }, failure: { (errorMessage) in
            
            self.hideLoadingView()
            
            self.showAlert(title: errorDefaultTitle, message: (errorMessage == nil) ? "Login error!" : errorMessage!)
        }, parameters: [NetworkConstants.Parameters.email: txtLogin.text!,
                        NetworkConstants.Parameters.password: txtPassword.text!])
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        if !checkInputFieldsValues() {
            return
        }
        
        showLoadingViewWith("SignUp...")
        
        NetworkManager.sharedInstance.signUpRequest(withSuccess: {
            
            self.hideLoadingView()
            self.successRegister()
        }, failure: { (errorMessage) in
            
            self.hideLoadingView()
            self.showAlert(title: errorDefaultTitle, message: (errorMessage == nil) ? "Register error!" : errorMessage!)
        }, parameters: [NetworkConstants.Parameters.email: txtLogin.text!,
                        NetworkConstants.Parameters.password: txtPassword.text!])
        
    }
    
    private func checkInputFieldsValues() -> Bool {
        
        // Check E-mail
        //
        let email = txtLogin.text
        if email == nil || (email?.characters.count)! <= 0 {
            showAlert(title: errorDefaultTitle, message: "Email empty!")
            return false
        }
        
        // Check pass
        //
        let password = txtPassword.text
        if password == nil || (password?.characters.count)! <= 0 {
            showAlert(title: errorDefaultTitle, message: "Password empty!")
            return false
        }
        
        return true
    }
    
    // Success login action
    //
    fileprivate func successLogin(token: String) {
        
        UserManager.sharedInstance.accessToken = token
        
        performSegue(withIdentifier: "LoginSegue", sender: nil)
    }
    
    // Success register action
    //
    private func successRegister() {
        
        // Clear fields
        //
        txtLogin.text = ""
        txtPassword.text = ""
        
        // Show success popup
        //
        showAlert(title: "Success!", message: "Register successfully!")
    }
    
    fileprivate func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

//
// MARK: - Facebook Login
//

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if result.isCancelled {
            
            showAlert(title: errorDefaultTitle, message: "Facebook login cancelled")
        } else {
            
            self.showLoadingViewWith("Loading...")
            
            NetworkManager.sharedInstance.loginFacebookRequest(withSuccess: { (accessToken) in
                
                self.hideLoadingView()
                self.successLogin(token: accessToken)
            }, failure: { (error) in
                
                print("FACEBOOK Login Error: ", error)
                
                self.hideLoadingView()
                // Logout from facebook
                //
                if (FBSDKAccessToken.current()) != nil {
                    let manager = FBSDKLoginManager()
                    manager.logOut()
                }
                
                self.showAlert(title: errorDefaultTitle, message: "Facebook login error!")
                
            }, facebookToken: result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
}

//
// MARK: - Google SignIn
//

extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            
            let accessToken = user.authentication.accessToken
            self.showLoadingViewWith("Loading...")
            
            NetworkManager.sharedInstance.loginGoogleRequest(withSuccess: { (accessToken) in
                
                self.hideLoadingView()
                self.successLogin(token: accessToken)
            }, failure: { (error) in
                
                self.hideLoadingView()
                print("GOOGLE Login Error: ", error)
                
                // Logout from google
                //
                if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                    GIDSignIn.sharedInstance().signOut()
                }
                self.showAlert(title: errorDefaultTitle, message: "Google login error: \(error.localizedDescription)")
                
            }, googleToken: accessToken!)
            
        } else {
            showAlert(title: errorDefaultTitle, message: "Google login error: \(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
}

//
// MARK: - UITextField delegates
//

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtLogin {
            txtPassword.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        return true
    }
}







