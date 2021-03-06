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
    var ammo: Int
    
    init(){
        damage = 0
        capacity = 0
        ammo = 0
        super.init(texture : tex, color:UIColor.clear, size: tex.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}
