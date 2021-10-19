import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    let debug = false

    let spawnPoints = [
        CGPoint(x: 0.25, y: 0.30),
        CGPoint(x: 0.10, y: 0.40),
        CGPoint(x: 0.18, y: 0.55),
        CGPoint(x: 0.50, y: 0.10),
        CGPoint(x: 0.20, y: 0.15),
        CGPoint(x: 0.82, y: 0.30),
        CGPoint(x: 0.89, y: 0.52),
        CGPoint(x: 0.70, y: 0.62),
        CGPoint(x: 0.92, y: 0.12),
        CGPoint(x: 0.85, y: 0.14),
    ]

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        // start motion for gravity
        self.startMotionUpdates()

        self.spawnTrack()
        self.spawnPlayer(xPos: size.width * 0.5, yPos: size.height * 0.625)

        for point in spawnPoints
        {
            spawnObstacle(xPos: size.width * point.x, yPos: size.height * point.y)
        }

        if debug {
            let skview = self.view!
            skview.showsFPS = true
            skview.showsNodeCount = true
            skview.showsPhysics = true
        }
    }

    func spawnObstacle(xPos: CGFloat, yPos: CGFloat)
    {
        let texture = SKTexture(imageNamed: "hurdle2")
        let obstacle = SKSpriteNode(texture: texture)
        
        var size = texture.size()
        
        size.width *= 0.07
        size.height *= 0.07
        
        obstacle.size = size
        obstacle.physicsBody = SKPhysicsBody(texture: texture, size: size)
        
        obstacle.position = CGPoint(x: xPos, y: yPos)
        
        obstacle.physicsBody?.allowsRotation = false
        obstacle.physicsBody?.pinned = true
        
        obstacle.physicsBody?.contactTestBitMask = 0x00000001
        obstacle.physicsBody?.collisionBitMask = 0x00000001
        obstacle.physicsBody?.categoryBitMask = 0x00000001
        
        obstacle.zRotation = Double.random(in: -0.785398...0.785398) // π/4
        
        if debug {
            obstacle.alpha = 0.05
        }

        self.addChild(obstacle)
    }

    func spawnPlayer(xPos: CGFloat, yPos: CGFloat, playerScale: CGFloat = 0.08)
    {
        let player = SKSpriteNode(imageNamed: ActivityModel.shared.activityIconName)

        // game state listener
        GameModel.shared.gameStateListeners["player"] = { (state: GameModel.State) -> () in
            switch state {
            case .IN_GAME:
                player.physicsBody?.isDynamic = true
                player.physicsBody?.affectedByGravity = true

            case .FINISHED:
                player.physicsBody?.isDynamic = false
                player.physicsBody?.affectedByGravity = false

            case .IDLE:
                player.physicsBody?.isDynamic = false
                player.physicsBody?.affectedByGravity = false

                player.position = CGPoint(x: xPos, y: yPos)
            }
        }

        // register player to icon callback to update icon on activity change
        ActivityModel.shared.activityChangeCallback = {

            // create texture
            player.texture = SKTexture(imageNamed: ActivityModel.shared.activityIconName)

            // scale player node based on texture size
            var size = player.texture?.size() ?? player.size

            // scaling
            size.height *= playerScale
            size.width *= playerScale

            player.size = size

            // maintain velocity
            var velocity: CGVector = CGVector()
            var angularVelocity: CGFloat = CGFloat()
            var hasVelocity = false

            if let physicsBody = player.physicsBody {
                velocity = physicsBody.velocity
                angularVelocity = physicsBody.angularVelocity

                hasVelocity = true

            }

            // generate physics body from textures
            player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)

            player.physicsBody?.mass *= 1.4
            player.physicsBody?.restitution = 0.3

            player.physicsBody?.contactTestBitMask = 0x00000001
            player.physicsBody?.collisionBitMask = 0x00000001
            player.physicsBody?.categoryBitMask = 0x00000001

            GameModel.shared.gameStateListeners["player"]!(GameModel.shared.getState())

            if GameModel.shared.getState() == .IN_GAME && hasVelocity
            {
                player.physicsBody?.velocity = velocity
                player.physicsBody?.angularVelocity = angularVelocity
            }
        }

        if debug {
            player.alpha = 0.05
        }

        self.addChild(player)
    }

    func spawnTrack() {

        // create textures
        let trackOutterRightTexture = SKTexture(imageNamed: "track_outter_right")
        let trackOutterLeftTexture = SKTexture(imageNamed: "track_outter_left")
        let trackInnerTexture = SKTexture(imageNamed: "track_inner")

        // assign physics bodies to textures
        for texture in [trackOutterRightTexture, trackInnerTexture, trackOutterLeftTexture]
        {
            let outline = SKSpriteNode(texture: texture)

            // place track outline
            outline.size = CGSize(width: size.width, height: size.height * 0.7)
            outline.position = CGPoint(x: size.width * 0.5, y: size.height * 0.35)

            // physics for track outline
            outline.physicsBody = SKPhysicsBody(texture: outline.texture!, size: outline.size)
            outline.physicsBody?.pinned = true
            outline.physicsBody?.allowsRotation = false
            outline.physicsBody?.contactTestBitMask = 0x00000001
            outline.physicsBody?.collisionBitMask = 0x00000001
            outline.physicsBody?.categoryBitMask = 0x00000001

            // hide if not debug
            if !debug
            {
                outline.alpha = 0
            } else {
                outline.alpha = 0.05
            }

            self.addChild(outline)
        }

        // place image for lanes
        let trackLanes = SKSpriteNode(imageNamed: "track_bg.png")
        trackLanes.size = CGSize(width: size.width, height: size.height * 0.7)
        trackLanes.position = CGPoint(x: size.width * 0.5, y: size.height * 0.35)

        // don't hide physics outlines if debugging
        if !debug {
            self.addChild(trackLanes)
        }
    }

    let motion = CMMotionManager()
    func startMotionUpdates() {
        // some internal inconsistency here: we need to ask the device manager for device

        if self.motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion)
        }
    }

    func handleMotion(_ motionData: CMDeviceMotion?, error: Error?) {
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(11 * gravity.x), dy: CGFloat(11 * gravity.y))
        }
    }
}

