//
//  CanvasViewController.swift
//  CanvasLabel
//
//  Created by Raul Agrait on 5/7/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit


class CanvasViewController: UIViewController {
    var trayOriginalCenter: CGPoint!
    
    // Tray Y when "Up"
    var trayMaxY: CGFloat!
    
    // Tray Y when "down"
    var trayMinY: CGFloat!
    
    var activeFace: UIImageView!
    var activeFaceOriginalCenter: CGPoint!
    
    var originalFaceSize: CGFloat!

    @IBOutlet weak var trayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let halfTrayHeight = trayView.bounds.height / 2
        trayMinY = view.bounds.height - halfTrayHeight
        trayMaxY = view.bounds.height
        
        trayOriginalCenter = trayView.center
        setTrayCenterY(trayMaxY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTrayPanGesture(sender: UIPanGestureRecognizer) {
        var point = sender.locationInView(view)
        let translation = sender.translationInView(view)
        
        if (sender.state == UIGestureRecognizerState.Began) {
            trayOriginalCenter = trayView.center
        } else if (sender.state == UIGestureRecognizerState.Changed) {
            println("translation: x = \(translation.x), y = \(translation.y)")
            var centerY = max(trayOriginalCenter.y + translation.y, trayMinY)
            centerY = min(trayMaxY, centerY)
            setTrayCenterY(centerY)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            let velocity = sender.velocityInView(view)
            
            var finalY = velocity.y > 0 ? trayMaxY : trayMinY
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.setTrayCenterY(finalY)
            })
        }
    }
    
    func setTrayCenterY(yValue: CGFloat) {
        trayView.center = CGPoint(x: trayOriginalCenter.x, y: yValue)
    }
    
    
    @IBAction func onFacePanned(sender: UIPanGestureRecognizer) {
        println("a face was panned: \(sender.view)")
        if sender.state == UIGestureRecognizerState.Began {
            if let imageView = sender.view as? UIImageView {
                createNewFace(imageView)
            }
        } else if sender.state == UIGestureRecognizerState.Changed {
            updateActiveFace(sender)
        }
    }
    
    func createNewFace(originalImageView: UIImageView) {
        activeFace = UIImageView(image: originalImageView.image)
        activeFace.userInteractionEnabled = true
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onNewFacePanned:")
        activeFace.addGestureRecognizer(panGestureRecognizer)
        
        view.addSubview(activeFace)
        
        activeFace.center = originalImageView.center
        activeFace.center.y += trayView.frame.origin.y
        activeFaceOriginalCenter = activeFace.center
        
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onFacePinched:")
        activeFace.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func onNewFacePanned(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            if let imageView = sender.view as? UIImageView {
                activeFace = imageView
                activeFaceOriginalCenter = imageView.center
                originalFaceSize = activeFace.frame.width
                scaleFaceFrame(activeFace, factor: 1.5)
            }
        } else if sender.state == UIGestureRecognizerState.Changed {
            updateActiveFace(sender)
        } else if sender.state == UIGestureRecognizerState.Ended {
            scaleFaceFrame(activeFace, factor: 1)
        }
    }
    
    func scaleFaceFrame(face: UIImageView, factor: CGFloat) {
        face.frame = CGRect(x: face.frame.minX, y: activeFace.frame.minY, width: originalFaceSize * factor, height: originalFaceSize * factor)
    }
    
    func updateActiveFace(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        activeFace.center.y = translation.y + activeFaceOriginalCenter.y
        activeFace.center.x = translation.x + activeFaceOriginalCenter.x
    }
    
    func onFacePinched(sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            if let imageView = sender.view as? UIImageView {
                activeFace = imageView
                originalFaceSize = activeFace.frame.width
            }
        } else if sender.state == UIGestureRecognizerState.Changed {
            scaleFaceFrame(activeFace, factor: sender.scale)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
