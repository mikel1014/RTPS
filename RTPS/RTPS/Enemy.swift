//
//  Enemy.swift
//  RTPS
//
//  Created by Song Ian on 4/11/19.
//  Copyright © 2019 SSG corps. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Enemy : SKSpriteNode {

    var health:Int
    var moveSpd:Double
    let tex: SKTexture = SKTexture.init(imageNamed: "Zombie")
    
    
    init(){
        health = 10
        moveSpd = 10.0
        super.init(texture: tex, color: UIColor.clear, size: tex.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder) has not been implemented")
    }
    
    func Chase(player_: Player)->Void{
  
        let xDist:Double = (Double(player_.position.x - position.x))
        let yDist:Double = (Double(player_.position.y - position.y))
        let distance:Double = sqrt(xDist * xDist + yDist * yDist)
        let time = distance/moveSpd
        
        SKAction.move(to: player_.position, duration: time)
    }
    
    func update(_ currentTime: TimeInterval) {
        
        
        
    }
    
}
