//
//  MainViewController.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 4/21/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

import FBSDKLoginKit
import FBSDKCoreKit

import Alamofire

class MainViewController: UIViewController {
  
  var isReadyForTakingPhotos = true
  
  let photoHelper = PhotoHelper()
  var photosArray = [UIImage]()
  
  //
  // MARK: - IBOutlets
  //
  
  @IBOutlet weak var photoPreviewView: UIImageView!
  @IBOutlet weak var btnUploadPhoto: UIButton!
  
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var loadingLabel: UILabel!
  
  //
  // MARK: - UIViewController overrides
  //
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Hide system volume view
    //
    let volumeView: MPVolumeView = MPVolumeView(frame: CGRect.zero)
    view.addSubview(volumeView)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startListenVolumeButton()
    
    btnUploadPhoto.isEnabled = (photoPreviewView.image != nil)
    
    //Camera access
    //
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
      if response {
        print("Access success")
      } else {
        print("Access FAIL")
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopListenVolumeButton()
  }
  
  //
  // MARK: - Volume button
  //
  
  fileprivate func startListenVolumeButton() {
    print("Start  listen")
    let audioSession = AVAudioSession.sharedInstance()
    do { try AVAudioSession.sharedInstance().setActive(true) }
    catch { debugPrint("\(error)") }
    audioSession.addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
  }
  
  fileprivate func stopListenVolumeButton() {
    print("Stop listen")
    AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
    do { try AVAudioSession.sharedInstance().setActive(false) }
    catch { debugPrint("\(error)") }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    if keyPath == "outputVolume" {
      takePhotoAction()
    }
  }
  
  //
  // MARK: - Loading View
  //
  
  fileprivate func showLoadingViewWith(_ message: String) {
    
    loadingView.isHidden = false
    loadingLabel.text = message
  }
  
  fileprivate func hideLoadingView() {
    
    loadingView.isHidden = true
    loadingLabel.text = ""
  }
  
  //
  // MARK: - Buttons actions
  //
  
  @IBAction func btnTakePhotoPressed(_ sender: UIButton) {
    takePhotoAction()
  }
  
  @IBAction func settingsAction(_ sender: UIButton) {
    performSegue(withIdentifier: "settingsSegue", sender: self)
  }
  
  @IBAction func btnUploadAction(_ sender: UIButton) {
    
    if photosArray.count > 0 {
      if let token = UserManager.sharedInstance.accessToken {
        
        lockControls()
        showLoadingViewWith("Uploading...")
        
        NetworkManager.sharedInstance.uploadImageRequest(withSuccess: {
          
          self.hideLoadingView()
          self.unlockControls()
          
          self.showAlert(title: "Success!", message: "Images successfully uploaded!")
          
        }, failure: { (errorMessage) in
          
          print("Error message: \(errorMessage)")
          
          self.hideLoadingView()
          self.unlockControls()
          
          self.showAlert(title: "Error", message: "Uploading image error")
          
        }, images: photosArray, token: token)
      } else {
        self.showAlert(title: "Error", message: "Uploading image error")
      }
    }
  }
  
  @IBAction func logoutAction(_ sender: UIButton) {
    
    if FBSDKAccessToken.current() != nil {
      let manager = FBSDKLoginManager()
      manager.logOut()
    }
    
    if GIDSignIn.sharedInstance().hasAuthInKeychain() {
      GIDSignIn.sharedInstance().signOut()
    }
    
    logout()
  }
  
  //
  // MARK: -
  //
  
  private func getCurrentCameraSettings() -> CameraSettings {
    let defaults = UserDefaults.standard
    
    let numberOfPhotos = defaults.integer(forKey: UDKeys.camSettings.numberOfPhotos)
    let startingFocalLength = defaults.float(forKey: UDKeys.camSettings.startingFocalLength)
    let focalLengthDelta = defaults.float(forKey: UDKeys.camSettings.focalLengthDelta)
    let WBR = defaults.float(forKey: UDKeys.camSettings.WBR)
    let WBG = defaults.float(forKey: UDKeys.camSettings.WBG)
    let WBB = defaults.float(forKey: UDKeys.camSettings.WBB)
    let delayTime = defaults.integer(forKey: UDKeys.camSettings.delayTime)
    let zoom = defaults.float(forKey: UDKeys.camSettings.zoom)
    
    let settings = CameraSettings(numberOfPhotos: numberOfPhotos,
                                  startingFocalLength: startingFocalLength,
                                  focalLengthDelta: focalLengthDelta,
                                  wbr: WBR,
                                  wbg: WBG,
                                  wbb: WBB,
                                  delayTime: delayTime,
                                  zoom: zoom)
    return settings
  }
  
  private func takePhotoAction() {
    
    if isReadyForTakingPhotos {
      isReadyForTakingPhotos = false
      
      //Camera access
      //
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
        if response {
          
          self.lockControls()
          self.photosArray.removeAll()
          
          let camSettings = self.getCurrentCameraSettings()
          
          if camSettings.delayTime() > 0 {
            self.showLoadingViewWith("Wait \(camSettings.delayTime()) seconds please")
          }
          
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(camSettings.delayTime())) {
            self.hideLoadingView()
            
            self.photoHelper.onTakingPhotosComplete = { [weak self] (photos) in
              
              self?.unlockControls()
              if photos.count > 0 {
                self?.photosArray = photos
              }
              self?.photoPreviewView.image = photos.count > 0 ? photos[0] : nil
              self?.btnUploadPhoto.isEnabled = photos.count > 0
              
              self?.isReadyForTakingPhotos = true
            }
            self.photoHelper.takePhotos(settings: camSettings)
          }
        } else {
          
          let alertController = UIAlertController(title: "Access error",
                                                  message: "App doesn't have permission to use Camera, please change privacy settings",
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            self.isReadyForTakingPhotos = true
          }))
          self.present(alertController, animated: true, completion: nil)
        }
      }
    }
  }
  
  func logout() {
    navigationController?.popViewController(animated: true)
  }
  
  func lockControls() {
    view.isUserInteractionEnabled = false
  }
  
  func unlockControls() {
    view.isUserInteractionEnabled = true
  }
  
  fileprivate func showAlert(title: String, message: String) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
}




// R 1.8
// G 0.7
// B 2.6
