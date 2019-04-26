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
    let tex: SKTexture = SKTexture.init(imageNamed: "Main_Character.png")
    
    init() {
        health = 1000
        money = 0
        moveSpd = 10.0
        super.init(texture: tex, color: UIColor.clear, size: tex.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func GetHealth() -> Int {
        return health
    }
    
    func takeDamage(health_: Int){
        health -= health_
    }
}
