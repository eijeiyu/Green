//
//  GameScene.swift
//  Green
//
//  Created by AJ Yoo on 3/17/16.
//  Copyright (c) 2016 BlueHammer. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var player: SKSpriteNode!
    
    enum Direction: String {
        case Left = "left"
        case Right = "right"
    }
    enum Action: String {
        case Idle = "idle"
        case Walk = "walk"
        case Wink = "wink"
    }
    // TODO: remove atlases array later and use enumerations
    private let atlases = ["idle_left", "idle_right", "walk_left", "walk_right", "wink_left", "wink_right"]
    private var framesTable = [String: [SKTexture]]()
    
    override func didMoveToView(view: SKView) {
        
        // set up the background
        backgroundColor = SKColor.whiteColor()
        
        // set up the animation frames
        for i in 0..<atlases.count {
            let animation = atlases[i]
            let atlas = SKTextureAtlas(named: animation)
            let textures = atlas.textureNames.sort()
            framesTable[animation] = []
            for texture in textures {
                let frame = atlas.textureNamed(texture)
                framesTable[animation]!.append(frame)
            }
        }
    
        // add the player
        player = SKSpriteNode(texture: framesTable["idle_left"]![0])
        player.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        animatePlayer(.Idle, direction: .Left, speed: 1)
        addChild(player)
    }
    
//    private func animationForKey(key: String, speed: Double) -> SKAction? {
//        guard let frames = framesTable[key] else { return nil }
//        let animation = SKAction.animateWithTextures(frames, timePerFrame: speed)
//        let repeatAnimation = SKAction.repeatActionForever(animation)
//        return repeatAnimation
//    }
    
    private func getPlayerAction(action: Action) -> SKAction? {
        return player.actionForKey(action.rawValue)
    }
    
    private func removePlayerAction(action: Action) {
        player.removeActionForKey(action.rawValue)
    }
    
    private func animatePlayer(action: Action, direction: Direction, speed: Double) {
        let key = "\(action.rawValue)_\(direction.rawValue)"
        guard let frames = framesTable[key] else { return }
        let animation = SKAction.animateWithTextures(frames, timePerFrame: speed)
        let repeatAnimation = SKAction.repeatActionForever(animation)
        player.runAction(repeatAnimation, withKey: action.rawValue)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // determine the direction of the player from the touch
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(self)
        let direction: Direction = location.x < player.position.x ? .Left : .Right
        
        // cancel all actions if the player was already walking
        if getPlayerAction(.Walk) != nil { player.removeAllActions() }
    
        // cancel the idle action and animate the player walking if he was idle
        if getPlayerAction(.Idle) != nil {
            removePlayerAction(.Idle)
            animatePlayer(.Walk, direction: direction, speed: 0.3)
        }
        
        // done action returns player to idle animation
        let doneAction = SKAction.runBlock({ () -> Void in
            self.player.removeAllActions()
            self.animatePlayer(.Idle, direction: direction, speed: 1)
        })
        
        // move action moves player at constant rate
        let velocity = player.size.width / 1.2
        let difference = CGPoint(x: location.x - player.position.x, y: location.y - player.position.y)
        let distance = sqrt(difference.x * difference.x + difference.y * difference.y)
        let duration = distance / velocity
        let moveAction = SKAction.moveTo(location, duration: Double(duration))
        
        // run the actions
        player.runAction(SKAction.sequence([moveAction, doneAction]))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
