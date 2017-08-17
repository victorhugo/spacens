//
//  GameSceneController.swift
//  SpaceNS
//
//  Created by Victor Hugo Pérez Alvarado on 7/4/17.
//  Copyright © 2017 Chilaquil. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameSceneController: UIViewController, AVAudioPlayerDelegate {
    var scene: CustomGameScene!
    
    var musicPlayer:AVAudioPlayer?

    
    override var prefersStatusBarHidden: Bool{
        get{ return true}
    }
    
//    var clickActionCallBack:((Void)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let skView = self.view as! SKView? {
            // Create and configure the scene.
            scene = CustomGameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            // Present the scene.
            skView.presentScene(scene)
            
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickAction(_ sender: Any) {
        scene.actionButton()
    }

    
    
     
     override func viewWillDisappear(_ animated: Bool) {
     if let player = self.musicPlayer {
     player.stop()
     }
     }
     
     //MARK: -- Music player
     func playSoundtrack() {
     
     let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "GalaxyTravelerwav", ofType: "wav")!)
     do {
     self.musicPlayer = try AVAudioPlayer(contentsOf: ringtonePath)
     self.musicPlayer?.delegate = self
     self.musicPlayer?.numberOfLoops = -1
     
     playSound()
     } catch {
     NSLog("Failed to initialize audio player")
     }
     }
     
     func playSound() {
     do {
     try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
     } catch {
     NSLog(error.localizedDescription)
     }
     
     self.musicPlayer?.volume = 1.0
     self.musicPlayer?.play()
     }
     
     func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
     do {
     try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
     } catch {
     NSLog(error.localizedDescription)
     }
     }
 
    
}
