// USAGE: Place create a new joystick object, and add the joystick update method to the scene update.s
//
//
//


import UIKit
import SpriteKit
import GameplayKit

class LevelScene: SKScene, SKPhysicsContactDelegate {
    
    let cameraNode:SKCameraNode
    let player: SKSpriteNode
    let dButton: SKSpriteNode
    let fButton: SKSpriteNode
    let aBox: SKSpriteNode
    let gun: Gun
    let rotationOffsetFactorForSpriteImage:CGFloat = -CGFloat.pi / 2
    //let rightJS:EEJoyStick
    let leftJS:EEJoyStick
    let scaledFrameSize: CGSize
    let background:SKSpriteNode
    
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
        //rightJS = EEJoyStick()
        leftJS = EEJoyStick()
        player = SKSpriteNode(imageNamed: "Main_Character.png")
        dButton = SKSpriteNode(imageNamed: "Dodge_Button.png")
        fButton = SKSpriteNode(imageNamed: "Fire_Button.png")
        aBox = SKSpriteNode(imageNamed: "Ammo_Box.png")
        gun = Gun()
        
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
        
        //Joy Sticks (note joystick positions are changed in update method)
        //rightJS.position = CGPoint(x: frame.size.width * 0.75 + baseX, y: frame.size.height * 0.1 + baseY)
        //addChild(rightJS)
        
        dBBox = dButton.size
        dButton.position = CGPoint(x: player.position.x + dOffsetX ,y: player.position.y - dOffsetY)
        addChild(dButton)
        
        fBBox = fButton.size
        fButton.position = CGPoint(x: player.position.x + fOffsetX ,y: player.position.y - fOffsetY)
        addChild(fButton)
        
        
        aBox.position = CGPoint(x: 500, y: 500)
        aBox.scale(to: CGSize(width: 25, height: 25))
        aBox.physicsBody = SKPhysicsBody(rectangleOf: aBox.size)
        aBox.physicsBody!.isDynamic = false
        addChild(aBox)
        
        leftJS.position = CGPoint(x: frame.size.width * 0.25 + baseX, y: frame.size.height * 0.1 + baseY)
        addChild(leftJS)
        
        //Actors
        player.position = CGPoint(x: baseX/2, y: baseY/2)
        player.zPosition = 0.1
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.isDynamic = true
        addChild(player)
        

        
        
        
        
    }
    
    enum ColliderType: UInt32 {
        case Player = 1
        case AmmoBox = 2
    }
    
    //MARK: touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //test by moving player to click, which should move camera
        //let ftouch = touches.first!
        //let ftloc = ftouch.location(in: self)
        
        //convert view coordinates to scene coordinates
        // ???
        
        //use converted points
        //let touchPt:CGPoint = CGPoint(x: ftloc.x, y: ftloc.y)
        //player.run(SKAction.move(to: touchPt, duration: 2), withKey: "moving player")
        
        for touch in touches{
            let touchLoc = touch.location(in: self)
            
            //Checks to see if the use has clicked on the dodge button
            if touchLoc.x >= dButton.position.x - dBBox.width/2 && touchLoc.x <= dButton.position.x + dBBox.width/2{
                if touchLoc.y >= dButton.position.y - dBBox.height/2 && touchLoc.y <= dButton.position.y + dBBox.height/2{
                    player.position = CGPoint(x: player.position.x + cos(player.zRotation + 1.5708) * 40, y: player.position.y + sin(player.zRotation + 1.5708) * 40)
                }
            }
        }
    }
    

    //this does not save a refernce to the touch (though one could) because I envisioned the user
    //tapping the joy stick (which I belive would invalid any reference to a touch) in order to do an
    //action (such as shoot). So, instead touches are evaluated in terms of proximity to a given joy stick,
    //this way the user could tap the joy stick to do an action (such as shoot, crouch, etc.). There could be a delay
    //instated before a joy stick is reset
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
    
    /*
     movement data should be a [CGFloat] of size 2.
     @param movData.0 = the angle of movement (obtained from arc tan - which means certain caveats)
     @param movData.1 = the strength of the movement.
    */
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
        

        //debug trance
        //print("x: \(xChange) y: \(yChange)")
        //print("updatePlayerPosition reporting angle \(movData[0])")

        
        //correct for quadrants where x < 0
        if movData[0] > (CGFloat.pi / 2) || movData[0] < -(CGFloat.pi / 2) {
           // yChange *= -1
        }
        
        //update the player's movement
        player.position = CGPoint(x: playerCurrentPosition.x + xChange, y: playerCurrentPosition.y + yChange)
    }
    
    /*
     joystick data should be a [CGFloat] of size 2.
     @param movData.0 = the angle of movement (obtained from arc tan - which means certain caveats)
     @param movData.1 = the strength of the movement.
     */
    func updatePlayerRotation(JoystickData joyData: [CGFloat]){
        player.zRotation = joyData[0] + rotationOffsetFactorForSpriteImage
    }
    
    
    //MAKR: CODERS
    
    required init?(coder aDecoder: NSCoder) {
        cameraNode = aDecoder.decodeObject(forKey: "cameraNode") as! SKCameraNode
        scaledFrameSize = aDecoder.decodeObject(forKey: "scaledFrameSize") as! CGSize
        //rightJS = aDecoder.decodeObject(forKey: "rightJS") as! EEJoyStick
        leftJS = aDecoder.decodeObject(forKey: "leftJS") as! EEJoyStick
        background = aDecoder.decodeObject(forKey: "background") as! SKSpriteNode
        player = aDecoder.decodeObject(forKey: "player") as! SKSpriteNode
        dButton = aDecoder.decodeObject(forKey: "dButton") as! SKSpriteNode
        fButton = aDecoder.decodeObject(forKey: "fButton") as! SKSpriteNode
        aBox = aDecoder.decodeObject(forKey: "aBox") as! SKSpriteNode
        gun = aDecoder.decodeObject(forKey: "gun") as! Gun
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(cameraNode, forKey: "cameraNode")
        aCoder.encode(scaledFrameSize, forKey: "scaledFrameSize")
        //aCoder.encode(rightJS, forKey: "rightJS")
        aCoder.encode(leftJS, forKey: "leftJS")
        aCoder.encode(background, forKey: "background")
        aCoder.encode(player, forKey: "player")
        aCoder.encode(dButton, forKey: "dButton")
        aCoder.encode(fButton, forKey: "fButton")
        aCoder.encode(aBox, forKey: "aBox")
        aCoder.encode(gun, forKey: "gun")
    }
    
    override func didMove(to view:SKView){
        self.camera = cameraNode
        
        //Collision checking
        player.physicsBody!.contactTestBitMask = ColliderType.AmmoBox.rawValue
        player.physicsBody!.categoryBitMask = ColliderType.Player.rawValue
        player.physicsBody!.collisionBitMask = ColliderType.AmmoBox.rawValue
        
        
        
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
        //if !rightJS.joyStickActive(){
            //rightMovementData = nil
        //}
        if !leftJS.joyStickActive(){
            leftMovementData = nil
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact")
        //Remove ammo box when player collides with it.
        aBox.removeFromParent()
        
        //Adds ammo to gun
        gun.ammo += 5
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //Handle Player Updating Based On Joystick Data
        //if rightMovementData != nil && rightJS.joyStickActive(){
            //updatePlayerRotation(JoystickData: rightMovementData!)
        //}
        
        self.physicsWorld.contactDelegate = self
        
        if leftMovementData != nil && leftJS.joyStickActive(){
            updatePlayerPosition(JoystickData: leftMovementData!)
            updatePlayerRotation(JoystickData: leftMovementData!)
        }
        //rightJS.joystickUpdateMethod()
        leftJS.joystickUpdateMethod()
        clearJoyStickData()
        
        
        //Camera Updated To Player Position
        cameraNode.position = player.position
        let offsetX = frame.size.width * 0.35
        let offsetY = frame.size.height * 0.30
        
        //rightJS.position = CGPoint(x: player.position.x + offsetX ,y: player.position.y - offsetY)
        dButton.position = CGPoint(x: player.position.x + dOffsetX ,y: player.position.y - dOffsetY)
        fButton.position = CGPoint(x: player.position.x + fOffsetX ,y: player.position.y - fOffsetY)
        aBox.position = CGPoint(x: 500 ,y: 500)
        leftJS.position = CGPoint(x: player.position.x - offsetX ,y: player.position.y - offsetY)
        
    }
    
}
