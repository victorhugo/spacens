//
//  CustomGameScene.swift
//  SpaceNS
//
//  Created by Victor Hugo Pérez Alvarado on 7/4/17.
//  Copyright © 2017 Chilaquil. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import CoreMotion

enum PlayerType:UInt32{
    //    case Enemy = 0x1 < 2
    case Enemy = 0x4
    //    case Plasma = 0x1 < 1
    case Plasma = 0x2
}

class CustomGameScene: SKScene, SKPhysicsContactDelegate {
    
     var scoreLb:SKLabelNode!
    
     var scoreValue:Int = 0 {
        didSet{
            scoreLb.text = "Score: \(scoreValue)"
        }
     }
    
    var theShip:SpaceShip!
    
     
     let motionManager = CMMotionManager()
     var xCurAcceleration:CGFloat = 0.0
    
    
    override func didMove(to view: SKView) {
 
         self.physicsWorld.contactDelegate = self
 
         //El vecto de gravedad es 0
         self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
 
        
        self.loadBackground()
        
        
         theShip = SpaceShip()
         theShip.position = CGPoint(x: self.size.width / 2, y: theShip.frame.size.height + 20)
         addChild(theShip)
 
        
        print("Canvas size: \(size.width), \(size.height)")
        
        
         Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
             let enemy = EnemyShip()
             enemy.startPositionOn(size: self.size)
             self.addChild(enemy)
             enemy.goAttack()
         }
        
        
         //Usamos el accelerometro para mover la nave
         setupAcceleration()
        
    }
    
    
     func setupAcceleration(){
         motionManager.accelerometerUpdateInterval = 0.2
         motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let newData = data{
                let acceleration = newData.acceleration
                print("The acceleration: \(acceleration)")
                self.xCurAcceleration = CGFloat(acceleration.x) * 0.75  + self.xCurAcceleration * 0.25
            }
        }
     }
    
    
    override func didSimulatePhysics() {
         self.theShip.position.x += self.xCurAcceleration  * 50
         if theShip.position.x < -20 {
            self.theShip.position =  CGPoint(x: -20, y: theShip.position.y)
         }else if( theShip.position.x > self.size.width - 20){
            self.theShip.position =  CGPoint(x: self.size.width - 20, y: theShip.position.y)
         }
     }
    
    
    
     func loadScore(){
         scoreLb = SKLabelNode(text: "Score: 0")
         scoreLb.position = CGPoint(x: scoreLb.frame.width + 10, y: self.frame.size.height - (scoreLb.frame.height + 10))
         scoreLb.fontSize = 33
         scoreLb.zPosition = 100
         scoreLb.fontColor = UIColor.white
         self.addChild(scoreLb)
     }
    
    func loadBackground(){
        //Loading background
        let background = SKSpriteNode(imageNamed: "space_background")
        background.position = self.view!.center
        background.size = self.size
        background.zPosition = -2
        addChild(background)
        
         self.loadStars()
         self.loadScore()
    }
    
    
     var starsRain:SKEmitterNode!
    
     func loadStars(){
        starsRain = SKEmitterNode(fileNamed: "Stars")
        starsRain.position = CGPoint(x: 0, y: self.frame.size.height)
        starsRain.zPosition = -1
        addChild(starsRain)
     }
    
    
     func actionButton(){
        theShip.shot()
        print("Fire!!!")
     }
    
    //    func loadButtons(){
    //        let startButton = SKTexture(imageNamed: "game-button")
    //        let startButtonPressed = SKTexture(imageNamed: "game-button-off")
    //    }
    
    
     func didBegin(_ contact: SKPhysicsContact){
         print("Contact: \(contact)")
         var firsyBody:SKPhysicsBody?
         var secondBody:SKPhysicsBody?
         
         if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firsyBody = contact.bodyA
            secondBody = contact.bodyB
         }else{
            firsyBody = contact.bodyB
            secondBody = contact.bodyA
         }
         
         //        print("1body: \(firsyBody.categoryBitMask),  \(PlayerType.Plasma.rawValue)")
         //        print(" 2body: \(secondBody.categoryBitMask), \(PlayerType.Enemy.rawValue)")
         //        print("1body: \(firsyBody.categoryBitMask & PlayerType.Plasma.rawValue ), 2body: \(secondBody.categoryBitMask & PlayerType.Enemy.rawValue)")
         
         guard let firstBody = firsyBody, let secBody = secondBody else{return }
         
         if (firstBody.categoryBitMask & PlayerType.Plasma.rawValue ) != 0 && (secBody.categoryBitMask & PlayerType.Enemy.rawValue) != 0  {
         //            print("Colision: \(firsyBody) and \(secondBody)")
            plasmaCollision(plasma: firstBody.node as! SKSpriteNode, enemy: secBody.node as! SKSpriteNode)
         //Firstbody seria el plasma
         }
     }
     
     func plasmaCollision(plasma:SKSpriteNode, enemy:SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "Explsion")
        explosion?.position = enemy.position
        self.addChild(explosion!)
     
        self.run(SKAction.playSoundFileNamed("ShipExplosionNear_07.wav", waitForCompletion: false))
     
        plasma.removeFromParent()
        enemy.removeFromParent()
     
        self.run(SKAction.wait(forDuration: 2.0)) {
            explosion?.removeFromParent()
     }
     
     //SCORE
     self.scoreValue += 10
     
     }
     
     //Just to see its possible
     func didEnd(_ contact: SKPhysicsContact){
     }
    
    
}


 class EnemyShip: SKSpriteNode{
 
     convenience init() {
            self.init(imageNamed:EnemyShip.loadSprite() )
         //        print("inicia")
            zPosition = 2
         
             physicsBody = SKPhysicsBody(rectangleOf: self.size)
             physicsBody?.isDynamic = true
             physicsBody?.categoryBitMask = PlayerType.Enemy.rawValue
             physicsBody?.contactTestBitMask = PlayerType.Plasma.rawValue
             physicsBody?.collisionBitMask = 0
         }
         
         
         static  func loadSprite()->String{
             let enemySprites = ["enemy_A", "enemy_B", "enemy_C"]
             let suffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: enemySprites) as! [String]
             return suffled.first!
         }
         
         
         func startPositionOn(size:CGSize){
            let xPosRand = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.width))
            let xPos = CGFloat( xPosRand.nextInt() )
             //        let xPos = CGFloat( size.width/2 )
             
             position = CGPoint(x: xPos, y: size.height + self.size.height)
         }
//
         func goAttack(){
             var actionArray = [SKAction]()
             let moveTo = SKAction.move(to: CGPoint(x:self.position.x, y:0.0 - self.size.height), duration: 10.0)
             let remove = SKAction.removeFromParent()
             actionArray.append(moveTo)
             actionArray.append(remove)
             
             self.run(SKAction.sequence(actionArray))
         }
 }

class SpaceShip:SKSpriteNode {
    
    let shotAction = SKAction.playSoundFileNamed("shotsimple.wav", waitForCompletion: false)
    
    convenience init() {
        self.init(imageNamed: "player_b_m")
        //        print("inicia")
        zPosition = 1
        physicsBody?.isDynamic = false
        
        //        physicsBody?.collisionBitMask
    }
    
    
     func shot(){
         self.run(self.shotAction)
        
         let plasma = SKSpriteNode(imageNamed: "plasma_1")
         
         plasma.physicsBody =  SKPhysicsBody(circleOfRadius: plasma.size.width/2)
         plasma.position = CGPoint(x: self.position.x, y: self.size.height/2 + self.position.y)
         plasma.physicsBody?.isDynamic = true
         plasma.physicsBody?.categoryBitMask = PlayerType.Plasma.rawValue
         plasma.physicsBody?.contactTestBitMask = PlayerType.Enemy.rawValue
         plasma.physicsBody?.collisionBitMask = 0
         plasma.physicsBody?.usesPreciseCollisionDetection = true

         self.parent!.addChild(plasma)

         let animationTime = 1.5
         var actionArray = [SKAction]()
         let moveTo = SKAction.move(to: CGPoint(x:self.position.x, y: self.size.height + self.position.y + 200), duration: animationTime)
         let remove = SKAction.removeFromParent()
         actionArray.append(moveTo)
         actionArray.append(remove)
         plasma.run(SKAction.sequence(actionArray))
     }
    
    
    
}
