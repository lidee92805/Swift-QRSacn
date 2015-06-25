//
//  ViewController.swift
//  QRScan
//
//  Created by lidehua on 15/6/24.
//  Copyright (c) 2015年 李德华. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var shadowLayer : CALayer!
    
    var scannerLayer : CAGradientLayer!
    
    var boxRect : CGRect!
    
    var captureSession : AVCaptureSession!
    
    let screenBounds = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        
        let input : AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        if error != nil {
            return;
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopScanning"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("startScanning"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        boxRect = self.getClearRect()
        
        captureSession = AVCaptureSession()
        
        captureSession.addInput(input as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        captureMetadataOutput.rectOfInterest = CGRect(x: boxRect.origin.y/screenBounds.size.height, y: boxRect.origin.x/screenBounds.size.width, width: 196/screenBounds.size.height, height: 196/screenBounds.size.width)
        
        var videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.backgroundColor = UIColor.brownColor().CGColor
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        videoPreviewLayer.frame = screenBounds
        
        backView.layer.addSublayer(videoPreviewLayer)
        
        shadowLayer = CALayer()
        
        shadowLayer.frame = screenBounds
        
        shadowLayer.delegate = self
        
        shadowLayer.setNeedsDisplay()
        
        backView.layer.addSublayer(shadowLayer)
        
        scannerLayer = CAGradientLayer()
        
        scannerLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        scannerLayer.frame = CGRect(x: boxRect.origin.x, y: boxRect.origin.y, width: boxRect.size.width, height: 49)
        
        scannerLayer.colors = [UIColor.blueColor().CGColor,UIColor.clearColor().CGColor]
        
        scannerLayer.startPoint = CGPoint(x: 0.5, y: 1)
        
        scannerLayer.endPoint = CGPoint(x: 0.5, y: 0)
        
        shadowLayer.addSublayer(scannerLayer)
        
        self.startScanning()
        
        captureSession.startRunning()
    }
    override func viewDidLayoutSubviews() {
        
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var soundId : SystemSoundID = 0
        
        let url = NSURL(string: "/System/Library/Audio/UISounds/photoShutter.caf")
        
        var cf = url as! CFURLRef
        
        AudioServicesCreateSystemSoundID(url as! CFURLRef, &soundId);
        
        AudioServicesPlaySystemSound(soundId);
        
        captureSession.stopRunning()
        
        self.pause()
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            return;
        }
        let metadaObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadaObj.type == AVMetadataObjectTypeQRCode {
            if metadaObj.stringValue != nil {
//                infoLabel.text = metadaObj.stringValue
                
                var label = UILabel(frame: CGRectZero)
                
                label.textAlignment = NSTextAlignment.Center
                
                label.text = metadaObj.stringValue
                
                var labelRect = label.frame
                
                labelRect.size.height = label.sizeThatFits(CGSize(width: screenBounds.size.width - 30, height: 1000)).height + 20
                
                labelRect.size.width = screenBounds.size.width - 30
                
                label.frame = labelRect
                
                var alertView = LDHAlertView.alertControllerWithTitle("内容", message: nil, customView: label)
                
                let action1 = LDHAlertAction(title: "打开", style: LDHAlertActionStyle.Destructive, handler: { (action) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: metadaObj.stringValue)!)
                    self.captureSession.startRunning()
                    self.resume()
                })
                let action2 = LDHAlertAction(title: "取消", style: LDHAlertActionStyle.Default, handler: { (action) -> Void in
                    self.captureSession.startRunning()
                    self.resume()
                })
                alertView.addAction(action1)
                alertView.addAction(action2)
                alertView.show()
            }
        }
    }
    func startScanning() {
        if scannerLayer.speed == 0 {
            return;
        }
        let firstAnimation = self.createAnimation("bounds.size.height", fromValue: 0, toValue: 49, beginTime: 0.0, duration: 0.5)
        let secondAnimation = self.createAnimation("position.y", fromValue: boxRect.origin.y, toValue: boxRect.origin.y + boxRect.size.height, beginTime: 0.5, duration: 1)
        let thirdAnimation = self.createAnimation("anchorPoint.y", fromValue: 0, toValue: 1, beginTime: 0.5, duration: 1)
        let fourthAnimation = self.createAnimation("bounds.size.height", fromValue: 49, toValue: 0, beginTime: 1.5, duration: 0.5)
        
        var group = CAAnimationGroup()
        group.duration = 2
        group.repeatCount = MAXFLOAT
        group.animations = [firstAnimation,secondAnimation,thirdAnimation,fourthAnimation]
        scannerLayer.addAnimation(group, forKey: "startAnimation")
    }
    func stopScanning() {
        scannerLayer.removeAllAnimations()
    }
    func pause() {
        let pauseTime = scannerLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        scannerLayer.speed = 0.0
        scannerLayer.timeOffset = pauseTime
    }
    func resume() {
        let pausedTime = scannerLayer.timeOffset
        scannerLayer.speed = 1.0
        scannerLayer.timeOffset = 0.0
        scannerLayer.beginTime = scannerLayer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
    }
    func createAnimation<T>(keyPath:String , fromValue: T , toValue: T, beginTime: CFTimeInterval , duration: CFTimeInterval) -> CABasicAnimation {
        var animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue as! AnyObject
        animation.toValue = toValue as! AnyObject
        animation.beginTime = beginTime
        animation.duration = duration
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        CGContextAddRect(ctx, boxRect)
        CGContextClosePath(ctx)
        CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx))
        CGContextEOClip(ctx)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().colorWithAlphaComponent(0.7).CGColor)
        CGContextFillRect(ctx, backView.frame)
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(ctx, 2)
        CGContextMoveToPoint(ctx, boxRect.origin.x + 20, boxRect.origin.y - 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x - 2, boxRect.origin.y - 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x - 2, boxRect.origin.y + 20)
        CGContextMoveToPoint(ctx, boxRect.origin.x + boxRect.size.width - 20, boxRect.origin.y - 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x + boxRect.size.width + 2, boxRect.origin.y - 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x + boxRect.size.width + 2, boxRect.origin.y + 20)
        CGContextMoveToPoint(ctx, boxRect.origin.x - 2, boxRect.origin.y + boxRect.size.height - 20)
        CGContextAddLineToPoint(ctx, boxRect.origin.x - 2, boxRect.origin.y + boxRect.size.height + 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x + 20, boxRect.origin.y + boxRect.size.height + 2)
        CGContextMoveToPoint(ctx, boxRect.origin.x + boxRect.size.width - 20, boxRect.origin.y + boxRect.size.height + 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x + boxRect.size.width + 2, boxRect.origin.y + boxRect.size.height + 2)
        CGContextAddLineToPoint(ctx, boxRect.origin.x + boxRect.size.width + 2, boxRect.origin.y + boxRect.size.height - 20)
        CGContextStrokePath(ctx)
    }
    func getClearRect() -> CGRect {
        var rect = CGRect(x: 0, y: 0, width: 196, height: 196)
        
        rect.origin.x = (screenBounds.size.width - rect.size.width) / 2
        
        rect.origin.y = (screenBounds.size.height - rect.size.height) / 2
        
        return rect
    }
}