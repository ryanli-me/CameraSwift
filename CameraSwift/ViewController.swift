//
//  ViewController.swift
//  CameraSwift
//
//  Created by Yihe Li on 12/3/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
   
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    override func viewDidLoad() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        for devise in AVCaptureDevice.devices(){
            if devise.hasMediaType(AVMediaTypeVideo) {
                if devise.position == AVCaptureDevicePosition.Back{
                    captureDevice = devise as? AVCaptureDevice
                }
            }
        }
        if captureDevice != nil{
            beginSession()
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    func updateDeviceSettings(focusValue: Float, isoValue:Float) {
        if let device = captureDevice {
            if device.lockForConfiguration(nil){
                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                    //
                })
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let currentISO  = minISO + (maxISO - minISO) * isoValue
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: currentISO, completionHandler: { (time) -> Void in
                    //
                })
                device.unlockForConfiguration()
            }
        }
    }
    func touchPercent(touch: UITouch) -> CGPoint {
        let screenSize = UIScreen.mainScreen().bounds.size
        var touchPer = CGPointZero
        touchPer.x = touch.locationInView(self.view).x / screenSize.width
        touchPer.y = touch.locationInView(self.view).y / screenSize.height
        return touchPer
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touchPer = touchPercent(touches.anyObject() as UITouch)
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touchPer = touchPercent(touches.anyObject() as UITouch)
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

