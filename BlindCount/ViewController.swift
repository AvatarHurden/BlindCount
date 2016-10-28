//
//  ViewController.swift
//  BlindCount
//
//  Created by Arthur on 10/19/16.
//  Copyright © 2016 Arthur. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox.AudioServices

class ViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    var count: Int = 0 {
        didSet {
            countLabel.text = String(describing: count)
        }
    }
    
    var spoke: Bool = false
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var waitingConfirmation = false
    var waitingTimer: Timer!
    
    let gradient: CAGradientLayer = CAGradientLayer()
    let neutralColor = UIColor.groupTableViewBackground.cgColor
    let incrementColor = UIColor(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
    let decrementColor =  UIColor.white.cgColor
    let alertColor = UIColor(colorLiteralRed: 0.85, green: 0.8, blue: 0.8, alpha: 1).cgColor
    let alertColor2 = UIColor(colorLiteralRed: 1, green: 0.8, blue: 0.8, alpha: 1).cgColor

    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == .motionShake) {
            if !waitingConfirmation {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                waitingConfirmation = true
                waitingTimer = Timer(fire: Date().addingTimeInterval(3.375), interval: 0, repeats: false) {_ in
                    
                    self.cancelResetTimer()
                    AudioServicesPlaySystemSound(1521)
                }
                RunLoop.current.add(waitingTimer, forMode: .defaultRunLoopMode)
                
                UIView.animate(withDuration: 0.75, delay: 0.0, options:[.repeat, .allowUserInteraction], animations: {
                    self.gradient.isHidden = true
                    self.view.backgroundColor = UIColor(cgColor: self.alertColor)
                    self.view.backgroundColor = UIColor(cgColor: self.neutralColor)
                }, completion: { _ in
                    self.gradient.isHidden = false
                })

            } else {
                cancelResetTimer()
                resetCount()
            }
        }
    }
    
    func cancelResetTimer() {
        waitingTimer.invalidate()
        waitingConfirmation = false
        self.view.layer.removeAllAnimations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count = 0
        
        gradient.frame = view.bounds
        gradient.colors = [neutralColor, neutralColor, incrementColor, neutralColor, neutralColor]
       
        gradient.locations = [0, 1, 1.2, 1.4, 1.6]
        view.layer.insertSublayer(gradient, at: 0)
        
        //AudioServicesPlaySystemSound(1519) // Peek feedback
        //AudioServicesPlaySystemSound(1520) // Pop feedback
        //AudioServicesPlaySystemSound(1521) // Three pulses feedback
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func incrementCount() {
        count = count + 1
        
        AudioServicesPlaySystemSound(1519)
        if waitingConfirmation {
            self.cancelResetTimer()
        }
    }
    
    func decrementCount() -> Bool {
        
        if waitingConfirmation {
            self.cancelResetTimer()
        }
        
        if count > 0 {
            count = count - 1
            AudioServicesPlaySystemSound(1520)
            return true
        } else {
            AudioServicesPlaySystemSound(1521)
            return false
        }
    }
    
    enum Direction { case Up, Down, Left, Right }
    
    func animateGradient(direction: Direction) {
     
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        switch direction {
        case .Up, .Down:
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .Left, .Right:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        }
        CATransaction.commit()
        
        let fromValue, toValue: Any
        switch direction {
        case .Down, .Right:
            fromValue = [-0.6, -0.4, -0.2, 0, 1]
            toValue = [0, 1, 1.2, 1.4, 1.6]
        case .Up, .Left:
            fromValue = [0, 1, 1.2, 1.4, 1.6]
            toValue = [-0.6, -0.4, -0.2, 0, 1]
        }
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.1
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        gradient.add(animation, forKey: "increment")
    }
    
    func resetCount() {
        
        let vibrateTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        RunLoop.current.add(vibrateTimer, forMode: .defaultRunLoopMode)
        
        self.count = 0
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        UIView.animate(withDuration: 1, delay: 0, options:[.allowUserInteraction], animations: {
            self.gradient.isHidden = true
            self.view.backgroundColor = UIColor(cgColor: self.alertColor2)
            self.view.backgroundColor = UIColor(cgColor: self.neutralColor)
            }, completion: { _ in
                self.gradient.isHidden = false
        })
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction], animations: { _ in
            self.gradient.isHidden = true
            self.view.backgroundColor = UIColor(cgColor: self.incrementColor)
            self.view.backgroundColor = UIColor(cgColor: self.neutralColor)
        }, completion: { _ in
            self.gradient.isHidden = false
        })
        
        incrementCount()
    }

    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            spoke = false
        } else if !spoke {
            let speechUtterance = AVSpeechUtterance(string: countLabel.text!)
            spoke = true
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    @IBAction func swiped(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left || sender.direction == .up {
            animateGradient(direction: sender.direction == .left ? .Left : .Up	)
            incrementCount()
        } else if sender.direction == .right || sender.direction == .down {
            if decrementCount() {
                animateGradient(direction: sender.direction == .right ? .Right : .Down)
            }
        }
    }
}

