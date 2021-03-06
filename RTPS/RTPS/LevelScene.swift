// USAGE: Place create a new joystick object, and add the joystick update method to the scene update.s
//
//
//


import UIKit
import SpriteKit
import GameplayKit

class LevelScene: SKScene, SKPhysicsContactDelegate {
    
    let cameraNode:SKCameraNode
    let player: Player
    let dButton: SKSpriteNode
    let fButton: SKSpriteNode
    let aBox: SKSpriteNode
    let gun: Gun
    let rotationOffsetFactorForSpriteImage:CGFloat = -CGFloat.pi / 2
    let rotationOffset = CGFloat(Float.pi/2)
    let leftJS:EEJoyStick
    let scaledFrameSize: CGSize
    let background:SKSpriteNode
    var scoreLabel: SKLabelNode!
    var hpLabel: SKLabelNode!
    var score: Int

    var bullets = [SKSpriteNode]()
    
    var dBBox: CGSize!
    var fBBox: CGSize!
    
    var baseX: CGFloat {
        get{ return scaledFrameSize.width / 2 }
    }
    var baseY: CGFloat{
        get{  return scaledFrameSize.height / 2}
    }
    let playerMaxMovementSpeed:CGFloat = CGFloat(5)
    var leftMovementData: [CGFloat]? = nil
    var rightMovementData: [CGFloat]? = nil
    var dOffsetY: CGFloat{
        get{ return frame.size.height * 0.38 }
    }
    var dOffsetX: CGFloat{
        get{return frame.size.width * 0.32}
    }
    var fOffsetY: CGFloat{
        get{ return frame.size.height * 0.2 }
    }
    var fOffsetX: CGFloat{
        get{return frame.size.width * 0.4}
    }
    //Added buttons and joystick
    
    init(_ frameSize: CGSize){
        
        //Declaration matters - at least when using classes that contain multiple nodess
        cameraNode = SKCameraNode()
        background = SKSpriteNode(imageNamed: "RTPS_Map_Background.png")
        leftJS = EEJoyStick()
        dButton = SKSpriteNode(imageNamed: "Dodge_Button.png")
        fButton = SKSpriteNode(imageNamed: "Fire_Button.png")
        aBox = SKSpriteNode(imageNamed: "Ammo_Box.png")
        gun = Gun()
        player = Player()
        //enemy = Enemy()
        score = 0

        
        //swap size before calling super
        let swapSize = CGSize(width: frameSize.height, height: frameSize.width)
        scaledFrameSize = LevelScene.createLargeFrameSize(startSize: swapSize, increaseFactor: 1)
        
        super.init(size: scaledFrameSize)
        
        //Background
        self.backgroundColor = SKColor.black
        background.position = CGPoint(x: -frame.size.width / 3, y: -frame.size.height / 3)
        addChild(background)
        
        //Camera Placement
        cameraNode.position = CGPoint(x: baseX/2, y: baseY/2)
        addChild(cameraNode)
        
        //Joy Stick (note joystick positions are changed in update method)
        
        dBBox = dButton.size
        dButton.position = CGPoint(x: player.position.x + dOffsetX ,y: player.position.y - dOffsetY)
        addChild(dButton)
        
        fBBox = fButton.size
        fButton.position = CGPoint(x: player.position.x + fOffsetX ,y: player.position.y - fOffsetY)
        addChild(fButton)
        
        
        aBox.position = CGPoint(x: 500, y: 500)
        aBox.scale(to: CGSize(width: 25, height: 25))
        aBox.physicsBody = SKPhysicsBody(rectangleOf: aBox.size)
        aBox.physicsBody!.affectedByGravity = false
        aBox.physicsBody!.isDynamic = false
        aBox.name = "AmmoBox"
        
        addChild(aBox)
        
        leftJS.position = CGPoint(x: frame.size.width * 0.25 + baseX, y: frame.size.height * 0.1 + baseY)
        addChild(leftJS)
        
        //Actors
        player.position = CGPoint(x: baseX/2, y: baseY/2)
        player.zPosition = 0.1
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.isDynamic = true
        player.physicsBody?.collisionBitMask = 0x00000011
        player.name = "Player"
        addChild(player)
        
        gun.position = player.WeaponAttachPoint()
        gun.scale(to: CGSize(width: 20, height: 20))
        addChild(gun)
        player.physicsBody!.contactTestBitMask = aBox.physicsBody!.collisionBitMask
        
        //Creates a score label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 75 , y: 40)
        addChild(scoreLabel)
        
        //Creates a health label
        hpLabel = SKLabelNode(fontNamed: "Chalkduster")
        hpLabel.text = "Health: \(player.health)"
        hpLabel.horizontalAlignmentMode = .right
        hpLabel.position = CGPoint(x: 200 , y: 40)
        addChild(hpLabel)
    }
    
    //MARK: touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let touchLoc = touch.location(in: self)
            
            //Checks to see if the use has clicked on the dodge button
            if touchLoc.x >= dButton.position.x - dBBox.width/2 && touchLoc.x <= dButton.position.x + dBBox.width/2{
                if touchLoc.y >= dButton.position.y - dBBox.height/2 && touchLoc.y <= dButton.position.y + dBBox.height/2{
                    player.position = CGPoint(x: player.position.x + cos(player.zRotation + 1.5708) * 40, y: player.position.y + sin(player.zRotation + 1.5708) * 40) // Dashes along the players forward vector
                }
            }
            else if touchLoc.x >= fButton.position.x - fBBox.width/2 && touchLoc.x <= fButton.position.x + fBBox.width/2 {
                if touchLoc.y >= fButton.position.y - fBBox.height/2 && touchLoc.y <= fButton.position.y + fBBox.height/2{
                   
                    Shoot()
                }
            }
        }
    }
    
    func Shoot()->Void {
        
        let position = gun.position
            
        let direction = Rotate(vector:CGVector(dx: 10, dy: 0), angle:player.zRotation + rotationOffset)
        
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.name = "bulletNode"
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.position = CGPoint(x: position.x + direction.dx, y: position.y + direction.dy)
        bullet.scale(to: CGSize(width: 10, height: 10))
        self.addChild(bullet)
        bullets.append(bullet)
        bullet.physicsBody?.applyImpulse(direction)
        let destroy = SKAction.run({
            bullet.removeFromParent()
        })
        let wait = SKAction.wait(forDuration: 2)
        self.run(SKAction.sequence([wait, destroy]))
    }
        
    func Rotate(vector:CGVector, angle:CGFloat) -> CGVector {
        let rotX = vector.dx * cos(angle) - vector.dy * sin(angle)
        let rotY = vector.dx * sin(angle) + vector.dy * cos(angle)
        
        return CGVector(dx: rotX, dy: rotY)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLoc = touch.location(in: self)
            //let touchID = touch
            
            //get a displacement factor (this is used to convert coordinates to actual screen coordinates in position checks)
            var displace = cameraNode.position //should be in center of screen
            displace.x = displace.x - frame.size.width / 2
            displace.y = displace.y - frame.size.height / 2
            //print("touch x: \(displace.x) LB: \(frame.size.width * 0.33) RB: \(frame.size.width*0.66)")
            
            //CHECK TOUCHES POSITION IN SCREEN
            //if the y is less than 1/4 of the screen down
            if touchLoc.y < frame.size.height * 0.50 + displace.y{
                //if it is in the left 1/3 of screen
                if touchLoc.x <= frame.size.width * 0.33 + displace.x {
                    leftMovementData = leftJS.moveStick(joyStickLocation: leftJS.position, touchLocation: touchLoc, touch: touch)
                }
                //if it is in the right 1/3 of screen
                else if touchLoc.x >= frame.size.width * 0.66 + displace.x {
                    //rightMovementData = rightJS.moveStick(joyStickLocation: rightJS.position, touchLocation: touchLoc, touch: touch)
                   
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            //rightJS.signalTouchEnded(touch: touch)
            leftJS.signalTouchEnded(touch: touch)
        }
    }
    
    func updatePlayerPosition(JoystickData movData: [CGFloat]){
        //shadow param movData with local var so that it can be mutated
        var movData = movData
        
        //return if improper parameter sent
        if movData.count < 2 {
            print("improper array sent to updatePlayerPosition, had less than 2 elements")
            return
        }
        
        //get current player's position (for displacement)
        let playerCurrentPosition = player.position
        
        //calculate the displacement based on the angle (assume speed is 1)
        var xChange = playerMaxMovementSpeed * cos(movData[0])
        var yChange = playerMaxMovementSpeed * sin(movData[0])

        //scale the movement based on the strength of pushed joystick
        xChange *= movData[1]
        yChange *= movData[1]
        
        //correct for quadrants where x < 0
        if movData[0] > (CGFloat.pi / 2) || movData[0] < -(CGFloat.pi / 2) {
           // yChange *= -1
        }
        
        //update the player's movement
        player.position = CGPoint(x: playerCurrentPosition.x + xChange, y: playerCurrentPosition.y + yChange)
    }
    
    func updatePlayerRotation(JoystickData joyData: [CGFloat]){
        player.zRotation = joyData[0] + rotationOffsetFactorForSpriteImage
    }
    
    
    //MAKR: CODERS
    
    required init?(coder aDecoder: NSCoder) {
        cameraNode = aDecoder.decodeObject(forKey: "cameraNode") as! SKCameraNode
        scaledFrameSize = aDecoder.decodeObject(forKey: "scaledFrameSize") as! CGSize
        leftJS = aDecoder.decodeObject(forKey: "leftJS") as! EEJoyStick
        background = aDecoder.decodeObject(forKey: "background") as! SKSpriteNode
        player = aDecoder.decodeObject(forKey: "player") as! Player
        gun = aDecoder.decodeObject(forKey: "gun") as! Gun
        dButton = aDecoder.decodeObject(forKey: "dButton") as! SKSpriteNode
        fButton = aDecoder.decodeObject(forKey: "fButton") as! SKSpriteNode
        aBox = aDecoder.decodeObject(forKey: "aBox") as! SKSpriteNode
        score = aDecoder.decodeObject(forKey: "score") as! Int
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(cameraNode, forKey: "cameraNode")
        aCoder.encode(scaledFrameSize, forKey: "scaledFrameSize")
        aCoder.encode(leftJS, forKey: "leftJS")
        aCoder.encode(background, forKey: "background")
        aCoder.encode(player, forKey: "player")
        aCoder.encode(gun, forKey: "gun")
        aCoder.encode(dButton, forKey: "dButton")
        aCoder.encode(fButton, forKey: "fButton")
        aCoder.encode(aBox, forKey: "aBox")
        aCoder.encode(score, forKey: "score")
    }
    
    override func didMove(to view:SKView){
        self.camera = cameraNode
      
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(randSpawn), SKAction.wait(forDuration: 1.0)])))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
    
        guard let name = contact.bodyB.node?.name else {return}
        
        if contact.bodyA.node?.name == "bulletNode" || contact.bodyB.node?.name == "bulletNode"{
            if contact.bodyA.node?.name == "bulletNode"{
                if contact.bodyB.node?.name == "Enemy"{
                    contact.bodyA.node?.removeFromParent()
                    contact.bodyB.node?.removeFromParent()
                    score += 146
                }
            }
            else {
                if contact.bodyA.node?.name == "Enemy"{
                    contact.bodyA.node?.removeFromParent()
                    contact.bodyB.node?.removeFromParent()
                    score += 146
                }
            }
        }
      
        switch name {
        case "Enemy":
            player.takeDamage(health_: 1)
            if player.health <= 0{
                player.removeFromParent()
                gun.removeFromParent()
            }
        case "Player":
            aBox.removeFromParent()
            gun.ammo += 5
        default:
            print("no hit")
        }
    }
    
    //returns the size, multiplied by a factor.
    static func createLargeFrameSize(startSize size:CGSize, increaseFactor factor:Int) -> CGSize {
        var factorMut = CGFloat(factor)
        
        //while size overflows, return the size
        while (size.height * factorMut) > CGFloat.greatestFiniteMagnitude
            || (size.width * factorMut) > CGFloat.greatestFiniteMagnitude {
                factorMut /= 2
        }
        
        let newSize = CGSize(width: size.width * factorMut, height: size.height * factorMut)
        
        return newSize
    }
    
    func clearJoyStickData(){
        if !leftJS.joyStickActive(){
            leftMovementData = nil
        }
    }
    
    //Helps with random enemy spawning
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func randSpawn() {
        
        let enemy: Enemy
        enemy = Enemy()
        enemy.name = "Enemy"
       
        enemy.scale(to: CGSize(width: 55, height: 55))
        
        enemy.position = CGPoint(x: frame.size.width + enemy.size.width/2, y: frame.size.height * random(min: 0, max: 1))
        
        

        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.isDynamic = true
        addChild(enemy)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //Handle Player Updating Based On Joystick Data
        
        self.physicsWorld.contactDelegate = self
        
        if leftMovementData != nil && leftJS.joyStickActive(){
            updatePlayerPosition(JoystickData: leftMovementData!)
            updatePlayerRotation(JoystickData: leftMovementData!)
        }
        
        leftJS.joystickUpdateMethod()
        clearJoyStickData()
        
        
        //Camera Updated To Player Position
        cameraNode.position = player.position
        let offsetX = frame.size.width * 0.35
        let offsetY = frame.size.height * 0.30
        
        dButton.position = CGPoint(x: player.position.x + dOffsetX ,y: player.position.y - dOffsetY)
        fButton.position = CGPoint(x: player.position.x + fOffsetX ,y: player.position.y - fOffsetY)
        aBox.position = CGPoint(x: 500 ,y: 500)
        leftJS.position = CGPoint(x: player.position.x - offsetX ,y: player.position.y - offsetY)
        scoreLabel.position = CGPoint(x: player.position.x - offsetX - 75, y: player.position.y + offsetY + 10)
        hpLabel.position = CGPoint(x: player.position.x - offsetX + 625, y: player.position.y + offsetY + 10)

        
        gun.position = player.WeaponAttachPoint()
        gun.zRotation = player.zRotation - 1.5708

        let enemies: [SKNode] = children.filter { (node) -> Bool in
            if let _ = node as? Enemy {
                return true
            }
            return false
        }
       
        enemies.forEach { (node) in
            let enemy = node as! Enemy
            
            enemy.update(currentTime)
            
            if let _ = enemy.action(forKey: "Chase") {
                return
            }
            
            let deltaX = player.position.x - enemy.position.x
            let deltaY = player.position.y - enemy.position.y
            let angle = atan2(deltaY, deltaX)
            
            enemy.zRotation = angle - 1.5708
            
            player.physicsBody!.contactTestBitMask = enemy.physicsBody!.collisionBitMask
            
             if self.bullets.count > 0 {
                enemy.physicsBody!.contactTestBitMask = bullets[0].physicsBody!.collisionBitMask
            }
           
            enemy.run(SKAction.move(to: player.position, duration: 6), withKey: "Chase")
        }
      
        scoreLabel.text = "Score: \(score)"
        if player.health <= 0 {
            player.health = 0
        }
        hpLabel.text = "Health: \(player.health)"
      
        }

    }

