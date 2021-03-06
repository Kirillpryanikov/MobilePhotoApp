//
//  PhotoHelper.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 12.07.17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import AVFoundation

class PhotoHelper: NSObject {
  
  var cameraDevice: AVCaptureDevice? = nil
  
  var captureSession = AVCaptureSession()
  var sessionOutput = AVCapturePhotoOutput()
  var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG])
  var previewLayer = AVCaptureVideoPreviewLayer()
  
  var currentPhotoIndex: Int = 0
  var photosArray = [UIImage]()
  var cameraSettings: CameraSettings?
  
  public var onTakingPhotosComplete: ((_ photos: [UIImage]) -> Void)?
  
  //
  // MARK: -
  //
  
  func takePhotos(settings: CameraSettings) {
    cameraSettings = settings
    
    if settings.numberOfPhotos() > 0 {
      
      guard let cameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
        onTakingPhotosComplete?(photosArray)
        return
      }
      
      self.cameraDevice = cameraDevice
      initCamera(device: cameraDevice)
      
      photosArray.removeAll()
      do {
        try cameraDevice.lockForConfiguration()
        
        setWhiteBalance(device: cameraDevice, completion: {
          
          self.setZoom(device: cameraDevice)
          self.capturePhotos(device: cameraDevice,
                             focalLength: settings.startingFocalLength(),
                             currentPhotoNumber: 1)
        })
        
        
      } catch {
        print("Error with cameraConfiguration")
        return
      }
    } else {
      onTakingPhotosComplete?(photosArray)
    }
  }
  
  private func initCamera(device: AVCaptureDevice) {
    do {
      let input = try AVCaptureDeviceInput(device: device)
      
      captureSession.sessionPreset = AVCaptureSessionPresetPhoto
      
      if(captureSession.canAddInput(input)) {
        
        captureSession.addInput(input);
        if(captureSession.canAddOutput(sessionOutput)) {
          
          captureSession.addOutput(sessionOutput);
          previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
          
          captureSession.startRunning()
        }
      }
    }
    catch{
      print("exception!");
    }
  }
  
  private func setWhiteBalance(device: AVCaptureDevice, completion: @escaping (() -> Void)) {
    
    print("Set White balance")
    
    if let settings = cameraSettings {
      let whiteBalanceRedGain = settings.wbr()
      let whiteBalanceGreenGain = settings.wbg()
      let whiteBalanceBlueGain = settings.wbb()
      
      // Set White Balance Gains
      // red, green and blue gains must be in the [1, maxWhiteBalanceGain] range
      //
      let gainLowestValue : Float = 1.0
      let gainAppUpperValue : Float = 5.0
      
      let redGain    = (device.maxWhiteBalanceGain - gainLowestValue) * (whiteBalanceRedGain   / gainAppUpperValue) + gainLowestValue
      let greenGain  = (device.maxWhiteBalanceGain - gainLowestValue) * (whiteBalanceGreenGain / gainAppUpperValue) + gainLowestValue
      let blueGain   = (device.maxWhiteBalanceGain - gainLowestValue) * (whiteBalanceBlueGain  / gainAppUpperValue) + gainLowestValue
      
      print("[ WhiteBalance RedGain   ]: \t(\(whiteBalanceRedGain)) ", redGain)
      print("[ WhiteBalance GreenGain ]: \t(\(whiteBalanceGreenGain)) ", greenGain)
      print("[ WhiteBalance BlueGain  ]: \t(\(whiteBalanceBlueGain)) ", blueGain)
      
      let gains = AVCaptureWhiteBalanceGains(redGain: redGain,
                                             greenGain: greenGain,
                                             blueGain: blueGain)
      
      device.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(gains, completionHandler: { (time) in
        completion()
      })
    }
  }
  
  private func setZoom(device: AVCaptureDevice) {
    
    print("Set Zoom")
    
    if let settings = cameraSettings {
      let zoomValue = settings.zoom()
      
      let lowestZoom: Float = 1.0
      let fakeMaxZoom = device.activeFormat.videoMaxZoomFactor / 20.0 // Because really maximum zoom very big. Need testing
      
      let zoomGain   = (fakeMaxZoom - CGFloat(lowestZoom)) * CGFloat(zoomValue) + CGFloat(lowestZoom)
      
      print("[ ZoomGain ]: \t\t(\(zoomValue)) ", zoomGain)
      
      device.videoZoomFactor = zoomGain
    }
  }
  
  fileprivate func capturePhotos(device: AVCaptureDevice, focalLength: Float, currentPhotoNumber: Int) {
    
    print("--------------- CAPTURE PHOTO: ---------------")
    print("[ Photo Number ]: \t", currentPhotoNumber)
    currentPhotoIndex = currentPhotoNumber
    
    // Set lens position
    //
    device.setFocusModeLockedWithLensPosition(focalLength, completionHandler: { (time) -> Void in
      
      // Set Focus position
      //
      device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
      
      print("[ Lens position ]: \t", focalLength)
      
      let settings = AVCapturePhotoSettings()
      
      // Flash mode
      //      settings.flashMode = .on
      //      device.flashMode = AVCaptureFlashMode.on
      
      self.sessionOutput.capturePhoto(with: settings, delegate: self)
    })
  }
}

//
// MARK: - AVCapturePhotoCaptureDelegate
//

extension PhotoHelper: AVCapturePhotoCaptureDelegate {
  
  @available(iOS 11.0, *)
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    
    if let error = error {
      print(error.localizedDescription)
    }
    
    if let imageData = photo.fileDataRepresentation(),
      let image = UIImage(data: imageData) {
      photosArray.append(image)
    }
    
    handleNextPhotoAction()
  }
  
  func capture(_ captureOutput: AVCapturePhotoOutput,
               didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
               previewPhotoSampleBuffer: CMSampleBuffer?,
               resolvedSettings: AVCaptureResolvedPhotoSettings,
               bracketSettings: AVCaptureBracketedStillImageSettings?,
               error: Error?) {
    
    if let error = error {
      print(error.localizedDescription)
    }
    
    if let sampleBuffer = photoSampleBuffer,
      let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil),
      let dataProvider = CGDataProvider(data: dataImage as CFData),
      let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
      
      let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
      photosArray.append(image)
    }
    
    handleNextPhotoAction()
  }
  
  private func handleNextPhotoAction() {
    
    guard let camera = cameraDevice else { onTakingPhotosComplete?(photosArray); return }
    
    if let camSettings = cameraSettings, currentPhotoIndex < camSettings.numberOfPhotos() {
      
      var nextFocalLength = camSettings.startingFocalLength() + (camSettings.focalLengthDelta() * Float(currentPhotoIndex))
      // Lens position value must be in [0, 1] range
      if nextFocalLength > 1.0 {
        nextFocalLength = 1.0
      }
      self.capturePhotos(device: camera, focalLength: nextFocalLength, currentPhotoNumber: self.currentPhotoIndex + 1)
    } else {
      camera.unlockForConfiguration()
      self.onTakingPhotosComplete?(self.photosArray)
    }
  }
}

//
// MARK: - Saving photos in Photo library for testing
//
//
//extension PhotoHelper {
//
//  // Saving Image here
//  //
//  fileprivate func savePhoto(_ image: UIImage) {
//    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//  }
//
//  // Add image to Library
//  //
//  func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//    if let error = error {
//
//      print("Save error: ", error.localizedDescription)
//    } else {
//
//      print("Saved successfully!")
//    }
//  }
//}













