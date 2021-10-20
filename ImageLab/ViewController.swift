//
//  ViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController   {

    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    let bridge = OpenCVBridge()
    
    //MARK: Outlets in view
    @IBOutlet weak var flashSlider: UISlider!
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    
    var buttonEnable:Bool = true{
        willSet(newValue){
            DispatchQueue.main.async {
                self.toggleCameraButton.isEnabled = newValue
                self.toggleFlashButton.isEnabled = newValue
            }
            guard buttonEnable != newValue else {
                return
            }
            if !newValue {
                print("will set finger detected in!")
                
//                _ = self.videoManager.toggleFlash(flashSwitch: !newValue)
            } else {
                print("will set finger detected out!")
//                _ = self.videoManager.toggleFlash(flashSwitch: !newValue)
            }
            
//            _ = self.videoManager.toggleFlash(flashSwitch: true)
        }
    }
    
    var isFingerDetected = false{
        willSet(newValue){
            guard isFingerDetected != newValue else {
                return
            }
            _ = self.videoManager.toggleFlash(flashSwitch: newValue)
        }
    }
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        // setup the OpenCV bridge nose detector, from file
//        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager = VideoAnalgesic(mainView: self.view)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these properties for better face detection efficiency
//        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
//        self.detector = CIDetector(ofType: CIDetectorTypeFace,
//                                  context: self.videoManager.getCIContext(), // perform on the GPU is possible
//            options: (optsDetector as [String : AnyObject]))
        
//        _ = self.videoManager.toggleFlash(flashSwitch: true)
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImageSwift)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
    }
    
    //MARK: Process image output
    func processImageSwift(inputImage:CIImage) -> CIImage{
        
        // detect faces
//        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
//        if f.count == 0 { return inputImage }
        
        var retImage = inputImage
        
        // if you just want to process on separate queue use this code
        // this is a NON BLOCKING CALL, but any changes to the image in OpenCV cannot be displayed real time
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
//            self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//            self.bridge.processImage()
//        }
        
        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCV
        // this is a BLOCKING CALL
//        self.bridge.setTransforms(self.videoManager.transform)
//        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//        self.bridge.processImage()
//        retImage = self.bridge.getImage()
        
        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
        // or any bounds to only process a certain bounding region in OpenCV
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: retImage.extent, // the first face bounds
                             andContext: self.videoManager.getCIContext())
        
//        self.bridge.processImage()
        
        let start = CFAbsoluteTimeGetCurrent()
        // run your work
        let isFinger = self.bridge.processFinger()
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Took \(diff) seconds")
        
//        let isFinger = self.bridge.processFinger()
        self.buttonEnable = !isFinger
        
        self.isFingerDetected = self.bridge.fingerNowFlag
        
        retImage = self.bridge.getImage() // get back opencv processed part of the image (overlayed on original)
        
        return retImage
    }
    
    //MARK: Setup Face Detection
    
//    func getFaces(img:CIImage) -> [CIFaceFeature]{
//        // this ungodly mess makes sure the image is the correct orientation
//        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
//        // get Face Features
//        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
//
//    }
    
    // change the type of processing done in OpenCV
    @IBAction func swipeRecognized(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            self.bridge.processType += 1
        case .right:
            self.bridge.processType -= 1
        default:
            break
            
        }
        
        stageLabel.text = "Stage: \(self.bridge.processType)"

    }
    
    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(_ sender: AnyObject) {
        if(self.videoManager.toggleFlash()){
            self.flashSlider.value = 1.0
        }
        else{
            self.flashSlider.value = 0.0
        }
    }
    
    @IBAction func switchCamera(_ sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }
    
    @IBAction func setFlashLevel(_ sender: UISlider) {
        if(sender.value>0.0){
            let val = self.videoManager.turnOnFlashwithLevel(sender.value)
            if val {
                print("Flash return, no errors.")
            }
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }

   
}

