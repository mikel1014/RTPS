//
//  Player.swift
//  RTPS
//
//  Created by Song Ian on 4/11/19.
//  Copyright © 2019 SSG corps. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Player : SKSpriteNode {
    
    var health:Int
    var money:Int
    var moveSpd:CGFloat
    var weaponAttachOffset:CGPoint
    let tex: SKTexture = SKTexture.init(imageNamed: "Main_Character.png")
    
    init() {
        health = 100
        money = 0
        moveSpd = 10.0
        weaponAttachOffset = CGPoint(x: 25, y: 25)
        super.init(texture: tex, color: UIColor.clear, size: tex.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func WeaponAttachPoint()->CGPoint{
        //let x: CGFloat = position.x + weaponAttachOffset.x
        //let y: CGFloat = position.y + weaponAttachOffset.y
        //let attachPoint: CGPoint = CGPoint(x: x, y: y)
        
        let attachPoint = CGPoint(x: (position.x) + cos(zRotation + 1.5708) * 30, y: (position.y) + sin(zRotation + 1.5708) * 30)
        
        return attachPoint
        
    }
    func GetHealth() -> Int {
        return health
    }
    
    func takeDamage(health_: Int){
        health -= health_
    }
}
