//
//  ISBNViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 7/31/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import AVFoundation

class ISBNViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    
    //Creating session
    let session = AVCaptureSession()
    
        var video = AVCaptureVideoPreviewLayer()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Define capture device
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            do
            {
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                session.addInput(input)
            }
            catch
            {
                print("ERROR")
            }
            
            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //defines which codes to scan for
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
            
            video = AVCaptureVideoPreviewLayer(session: session)
            video.frame = view.layer.bounds
            view.layer.addSublayer(video)
            
            session.startRunning()
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            //checks if it found an ISBN code
            if metadataObjects.count != 0
            {
                if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
                {
                    if object.type == AVMetadataObject.ObjectType.ean13
                    {
                        myQuery = object.stringValue!
                        performSegue(withIdentifier: "lookupISBN", sender: self)
                        session.stopRunning()
                    }
                }
            }
        }
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
