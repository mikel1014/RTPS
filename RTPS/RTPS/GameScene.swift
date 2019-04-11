//
//  GameScene.swift
//  RTPS
//
//  Created by Srom Michael J. on 1/31/19.
//  Copyright © 2019 SSG corps. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
       /* let background = SKSpriteNode(imageNamed: "RTPS_Map_Background")
        background.position = CGPoint(x: size.width / 2, y : size.height / 2)
        background.zRotation = 1.5708
        
        let mainCharacter = SKSpriteNode(imageNamed: "Main_Character")
        mainCharacter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        mainCharacter.setScale(0.18)

        let zombie = SKSpriteNode(imageNamed: "Zombie")
        zombie.position = CGPoint(x: size.width / 2, y: size.height / 2)
        zombie.setScale(0.18)
        
        
        addChild(background)
        addChild(mainCharacter)
        addChild(zombie)*/
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
