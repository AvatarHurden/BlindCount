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
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var waitingConfirmation = false
    var waitingTimer: Timer!
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == .motionShake) {
            if !waitingConfirmation {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                waitingConfirmation = true
                waitingTimer = Timer(fire: Date().addingTimeInterval(3), interval: 0, repeats: false) {_ in
                    print("reset Value")
                    self.waitingConfirmation = false
                    AudioServicesPlaySystemSound(1521)
                }
                RunLoop.current.add(waitingTimer, forMode: .defaultRunLoopMode)
            } else {
                waitingTimer.invalidate()
                waitingConfirmation = false
                resetCount()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count = 0
        
        
        
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
            waitingTimer.invalidate()
            waitingConfirmation = false
        }
    }
    
    func decrementCount() {
        count = count - 1
        AudioServicesPlaySystemSound(1521)
        if waitingConfirmation {
            waitingTimer.invalidate()
            waitingConfirmation = false
        }
    }
    
    var vibrateTimer: Timer!
    var vibrateCount: Int!
    func resetCount() {
        count = 0
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        sleep(1)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        vibrateTimer = Timer(fire: Date().addingTimeInterval(0.5), interval: 0, repeats: false) {_ in
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        }
//        RunLoop.current.add(vibrateTimer, forMode: .defaultRunLoopMode)

    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        incrementCount()
    }

    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        
        if speechSynthesizer.isSpeaking {
            return
        }
        
        let speechUtterance = AVSpeechUtterance(string: countLabel.text!)
        print(countLabel.text!)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func swiped(_ sender: UISwipeGestureRecognizer) {
        print(sender.direction)
        if sender.direction == .left {
            incrementCount()
        } else if sender.direction == .right {
            decrementCount()
        }
    }
}

