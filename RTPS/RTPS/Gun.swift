//
//  Gun.swift
//  RTPS
//
//  Created by Song Ian on 4/11/19.
//  Copyright © 2019 SSG corps. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Gun: SKSpriteNode {
    
    var tex:SKTexture = SKTexture.init(imageNamed: "Glock")
    var damage:Int
    var capacity:Int
    
    init(){
        damage = 0
        capacity = 0
        super.init(texture : tex, color:UIColor.clear, size: tex.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func OnFire(direction:CGPoint)->SKAction {
        let shootBullet = SKAction.run {
            
        }
        
        return shootBullet
    }
    
    func CreateBulletNode(pos:CGPoint) -> SKSpriteNode {
        
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.position = pos
        bullet.name = "bulletNode"
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.affectedByGravity = false
        self.addChild(bullet)
        
        return bullet
    }
}
