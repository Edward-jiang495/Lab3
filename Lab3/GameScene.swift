import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        // start motion for gravity
        self.startMotionUpdates()
        
        self.addSpriteBottle()
        
        self.addLap()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addSpriteBottle()
    }
    func addSpriteBottle(){
        let spriteA = SKSpriteNode(imageNamed: "matchman.png") // this is

        spriteA.size = CGSize(width:size.width*0.1,height:size.height * 0.1)

        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        spriteA.position = CGPoint(x: size.width / 2, y: size.height * 0.75)

        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
        spriteA.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        spriteA.physicsBody?.isDynamic = true
        spriteA.physicsBody?.contactTestBitMask = 0x00000001
        spriteA.physicsBody?.collisionBitMask = 0x00000001
        spriteA.physicsBody?.categoryBitMask = 0x00000001

        self.addChild(spriteA)

        
    }
    
    let motion = CMMotionManager()
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
    }
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    

    

    
    func addLap(){
        //this func add sprite kite on the image
        let uppercircle = SKShapeNode(circleOfRadius: size.width * 0.2)

        uppercircle.fillColor = UIColor.black
    
        uppercircle.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        

        
        let lowercircle = SKShapeNode(circleOfRadius: size.width * 0.2)
        lowercircle.fillColor = UIColor.black
    
        lowercircle.position = CGPoint(x: self.size.width/2, y: self.size.height/4)
        
      
        
        for obj in [uppercircle,lowercircle]{
            obj.physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.2)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
            
        }
        
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        left.size = CGSize(width:size.width*0.1,height:size.height*0.26)
        left.position = CGPoint(x:size.width*0.35, y:size.height*0.38)
        right.size = CGSize(width:size.width*0.1,height:size.height*0.26)
        right.position = CGPoint(x:size.width*0.65, y:size.height*0.38)
        
        for obj in [left,right]{
            obj.color = UIColor.black
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
        
        //we have to add the background image as an sksprite node
        //since ui image will always be in the front covering everything
        let trackimage = SKSpriteNode(imageNamed: "track.jpg")
        trackimage.size = CGSize(width:size.width,height:size.height*0.7)
        trackimage.position = CGPoint(x:size.width*0.5, y:size.height*0.35)
        self.addChild(trackimage)

    }


}

