//
//  SettingsViewController.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 4/23/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var txtNumberOfPhotos: UITextField!
  @IBOutlet weak var txtStartingFocalLenght: UITextField!
  @IBOutlet weak var txtFocalLenghtDelta: UITextField!
  @IBOutlet weak var txtWBR: UITextField!
  @IBOutlet weak var txtWBG: UITextField!
  @IBOutlet weak var txtWBB: UITextField!
  @IBOutlet weak var txtDelayTime: UITextField!
  @IBOutlet weak var txtZoom: UITextField!
  
  @IBOutlet weak var sliderNumberOfPhotos: UISlider!
  @IBOutlet weak var sliderStartingFocalLength: UISlider!
  @IBOutlet weak var sliderFocalLengthDelta: UISlider!
  @IBOutlet weak var sliderWBR: UISlider!
  @IBOutlet weak var sliderWBG: UISlider!
  @IBOutlet weak var sliderWBB: UISlider!
  @IBOutlet weak var sliderDelayTime: UISlider!
  @IBOutlet weak var sliderZoom: UISlider!
  
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var loadingLabel: UILabel!
  
  @IBOutlet weak var googleButton: GIDSignInButton!
  @IBOutlet weak var facebookButton: FBSDKLoginButton!
  
  //
  // MARK: - UIViewController overrides
  //
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSettings()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
    
    googleButton.isHidden = GIDSignIn.sharedInstance().hasAuthInKeychain()
    facebookButton.isHidden = (FBSDKAccessToken.current() != nil)
  }
  
  //MARK: -
  
  private func initSettings() {
    
    let defaults = UserDefaults.standard
    
    let numberOfPhotos = defaults.integer(forKey: UDKeys.camSettings.numberOfPhotos)
    let startingFocalLength = defaults.float(forKey: UDKeys.camSettings.startingFocalLength)
    let focalLengthDelta = defaults.float(forKey: UDKeys.camSettings.focalLengthDelta)
    let WBR = defaults.float(forKey: UDKeys.camSettings.WBR)
    let WBG = defaults.float(forKey: UDKeys.camSettings.WBG)
    let WBB = defaults.float(forKey: UDKeys.camSettings.WBB)
    let delayTime = defaults.integer(forKey: UDKeys.camSettings.delayTime)
    let zoom = defaults.float(forKey: UDKeys.camSettings.zoom)
    
    sliderNumberOfPhotos.value = Float(numberOfPhotos)
    txtNumberOfPhotos.text = String(numberOfPhotos)
    
    sliderStartingFocalLength.value = startingFocalLength
    txtStartingFocalLenght.text = String(startingFocalLength.roundTo(places: 2))
    
    sliderFocalLengthDelta.value = focalLengthDelta
    txtFocalLenghtDelta.text = String(focalLengthDelta.roundTo(places: 2))
    
    sliderWBR.value = WBR
    txtWBR.text = String(WBR.roundTo(places: 2))
    
    sliderWBG.value = WBG
    txtWBG.text = String(WBG.roundTo(places: 2))
    
    sliderWBB.value = WBB
    txtWBB.text = String(WBB.roundTo(places: 2))
    
    sliderDelayTime.value = Float(delayTime)
    txtDelayTime.text = String(delayTime)
    
    sliderZoom.value = Float(zoom)
    txtZoom.text = String(zoom)
  }
  
  func handleTap(_ sender: UITapGestureRecognizer)
  {
    view.endEditing(true)
  }
  
  //
  // MARK: - Helper
  //
  
  fileprivate func showAlert(title: String, message: String) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
  
  private func handleFloatTextEndEditing(minValue: Float, maxValue: Float, slider: UISlider, textField: UITextField) {
    
    if let text = textField.text {
      if text.characters.count > 0 {
        
        guard var resultFloat = Float(text) else {
          textField.text = String(slider.value.roundTo(places: 2))
          return
        }
        
        if resultFloat > maxValue {
          resultFloat = maxValue
        } else if resultFloat < minValue {
          resultFloat = minValue
        }
        
        textField.text = String(resultFloat)
        
        slider.value = resultFloat
      } else {
        textField.text = String(slider.value.roundTo(places: 2))
      }
    }
  }
  
  private func handleIntTextEndEditing(minValue: Int, maxValue: Int, slider: UISlider, textField: UITextField) {
    
    if let text = textField.text {
      if text.characters.count > 0 {
        
        guard var resultInt = Int(text) else {
          textField.text = String(Int(slider.value))
          return
        }
        
        if resultInt > maxValue {
          resultInt = maxValue
        } else if resultInt < minValue {
          resultInt = minValue
        }
        
        textField.text = String(resultInt)
        
        slider.value = Float(resultInt)
      } else {
        textField.text = String(Int(slider.value))
      }
    }
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
  // MARK: - Actions
  //
  
  @IBAction func okButtonPressed(_ sender: UIButton) {
    
    let defaults = UserDefaults.standard
    
    defaults.set(Int(sliderNumberOfPhotos.value), forKey: UDKeys.camSettings.numberOfPhotos)
    defaults.set(sliderStartingFocalLength.value.roundTo(places: 2), forKey: UDKeys.camSettings.startingFocalLength)
    defaults.set(sliderFocalLengthDelta.value.roundTo(places: 2), forKey: UDKeys.camSettings.focalLengthDelta)
    defaults.set(sliderWBR.value.roundTo(places: 2), forKey: UDKeys.camSettings.WBR)
    defaults.set(sliderWBG.value.roundTo(places: 2), forKey: UDKeys.camSettings.WBG)
    defaults.set(sliderWBB.value.roundTo(places: 2), forKey: UDKeys.camSettings.WBB)
    defaults.set(Int(sliderDelayTime.value), forKey: UDKeys.camSettings.delayTime)
    defaults.set(sliderZoom.value.roundTo(places: 2), forKey: UDKeys.camSettings.zoom)
    
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancelButtonPressed(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  //MARK: Number of photos
  //
  @IBAction func txtNumberOfPhotosEndEditing(_ sender: UITextField) {
    handleIntTextEndEditing(minValue: 0, maxValue: 20, slider: sliderNumberOfPhotos, textField: sender)
  }
  
  @IBAction func sliderNumberOfPhotosChanged(_ sender: UISlider) {
    txtNumberOfPhotos.text = String(Int(sender.value))
  }
  
  // MARK: Starting focal length
  //
  @IBAction func txtStartingFocalLengthEndEditing(_ sender: UITextField) {
    handleFloatTextEndEditing(minValue: 0.0, maxValue: 1.0, slider: sliderStartingFocalLength, textField: sender)
  }
  
  @IBAction func sliderStartingFocalLengthChanged(_ sender: UISlider) {
    txtStartingFocalLenght.text = String(sender.value.roundTo(places: 2))
  }
  
  // MARK: Focal length delta
  //
  @IBAction func txtFocalLengthDeltaEndEditing(_ sender: UITextField) {
    handleFloatTextEndEditing(minValue: 0.0, maxValue: 0.1, slider: sliderFocalLengthDelta, textField: sender)
  }
  
  @IBAction func sliderFocalLengthDeltaChanged(_ sender: UISlider) {
    txtFocalLenghtDelta.text = String(sender.value.roundTo(places: 2))
  }
  
  // MARK: White balance
  //
  @IBAction func txtWBREndEditing(_ sender: UITextField) {
    handleFloatTextEndEditing(minValue: 0.0, maxValue: 5.0, slider: sliderWBR, textField: sender)
  }
  
  @IBAction func sliderWhiteBalanceRChanged(_ sender: UISlider) {
    txtWBR.text = String(sender.value.roundTo(places: 2))
  }
  
  @IBAction func txtWBGEndEditing(_ sender: UITextField) {
    handleFloatTextEndEditing(minValue: 0.0, maxValue: 5.0, slider: sliderWBG, textField: sender)
  }
  
  @IBAction func sliderWBGChanged(_ sender: UISlider) {
    txtWBG.text = String(sender.value.roundTo(places: 2))
  }
  
  @IBAction func txtWBBEndEditing(_ sender: UITextField) {
    handleFloatTextEndEditing(minValue: 0.0, maxValue: 5.0, slider: sliderWBB, textField: sender)
  }
  
  @IBAction func sliderWBBChanged(_ sender: UISlider) {
    txtWBB.text = String(sender.value.roundTo(places: 2))
  }
  
  // MARK: Delay time
  //
  @IBAction func txtDelayTimeEndEditing(_ sender: UITextField) {
    handleIntTextEndEditing(minValue: 0, maxValue: 10, slider: sliderDelayTime, textField: sender)
  }
  
  @IBAction func sliderDelayTimeChanged(_ sender: UISlider) {
    txtDelayTime.text = String(Int(sender.value))
  }
  
  // MARK: Zoom
  //
  @IBAction func txtZoomEndEditing(_ sender: UITextField) {
    handleFloatTextEndEditing(minValue: 0.0, maxValue: 1.0, slider: sliderZoom, textField: sender)
  }
  
  @IBAction func sliderZoomChanged(_ sender: UISlider) {
    txtZoom.text = String(sender.value.roundTo(places: 2))
  }
}

//
// MARK: - Facebool connect
//

extension SettingsViewController: FBSDKLoginButtonDelegate {
  
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    
    if result.isCancelled {
      
      showAlert(title: errorDefaultTitle, message: "Facebook login cancelled")
    } else {
      
      self.showLoadingViewWith("Connecting facebook...")
      
      if let token = UserManager.sharedInstance.accessToken {
        
        NetworkManager.sharedInstance.connectFacebookRequest(withSuccess: {
          
          self.hideLoadingView()
          print("Facebook connected successfully!")
        }, failure: { (error) in
          
          print("Facebook connected error: \(error)")
          self.hideLoadingView()
          
          // Logout from facebook
          //
          if (FBSDKAccessToken.current()) != nil {
            let manager = FBSDKLoginManager()
            manager.logOut()
          }
        }, facebookToken: result.token.tokenString,
           accessToken: token)
      } else {
        
        self.hideLoadingView()
        print("Token not exist!")
        // Logout from facebook
        //
        if (FBSDKAccessToken.current()) != nil {
          let manager = FBSDKLoginManager()
          manager.logOut()
        }
      }
    }
  }
  
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    print("User logged out")
  }
}

//
// MARK: - Google connect
//

extension SettingsViewController: GIDSignInUIDelegate, GIDSignInDelegate {
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    
    if (error == nil) {
      
      let googleToken = user.authentication.accessToken
      self.showLoadingViewWith("Connecting google...")
      
      if let accessToken = UserManager.sharedInstance.accessToken {
        
        NetworkManager.sharedInstance.connectGoogleRequest(withSuccess: {
          
          self.hideLoadingView()
          print("Google connected successfully!")
        }, failure: { (error) in
          
          print("Facebook connected error: \(error)")
          self.hideLoadingView()
          
          // Logout from google
          //
          if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signOut()
          }
          
        }, googleToken: googleToken!, accessToken: accessToken)
      }
      
    } else {
      showAlert(title: errorDefaultTitle, message: "Google login error: \(error.localizedDescription)")
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
}

//
// MARK: -
//

extension Float {
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Float {
    let divisor = pow(10.0, Float(places))
    return (self * divisor).rounded() / divisor
  }
}
