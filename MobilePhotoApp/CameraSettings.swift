//
//  CameraSettings.swift
//  MobilePhotoApp
//
//  Created by Konstantin Shendenkov on 4/26/17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation

enum UDKeys {
  
  enum camSettings {
    static let numberOfPhotos: String = "camera.settings.numberOfPhotos"
    static let startingFocalLength: String = "camera.settings.startingFocalLength"
    static let focalLengthDelta: String = "camera.settings.focalLengthDelta"
    static let WBR: String = "camera.settings.whiteBalance.red"
    static let WBG: String = "camera.settings.whiteBalance.green"
    static let WBB: String = "camera.settings.whiteBalance.blue"
    static let delayTime: String = "camera.settings.delayTime"
    static let zoom: String = "camera.settings.zoom"
  }
}

//
// MARK: - Settings
//

public struct CameraSettings {
  let numberOfPhotos: () -> Int
  let startingFocalLength: () -> Float
  let focalLengthDelta: () -> Float
  let wbr: () -> Float
  let wbg: () -> Float
  let wbb: () -> Float
  let delayTime: () -> Int
  let zoom: () -> Float
  
  public init(
    numberOfPhotos: @autoclosure @escaping () -> Int,
    startingFocalLength: @autoclosure @escaping () -> Float,
    focalLengthDelta: @autoclosure @escaping () -> Float,
    wbr: @autoclosure @escaping () -> Float,
    wbg: @autoclosure @escaping () -> Float,
    wbb: @autoclosure @escaping () -> Float,
    delayTime: @autoclosure @escaping () -> Int,
    zoom: @autoclosure @escaping () -> Float) {
    
    self.numberOfPhotos = numberOfPhotos
    self.startingFocalLength = startingFocalLength
    self.focalLengthDelta = focalLengthDelta
    self.wbr = wbr
    self.wbg = wbg
    self.wbb = wbb
    self.delayTime = delayTime
    self.zoom = zoom
  }
}










