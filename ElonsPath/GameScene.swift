//
//  GameScene.swift
//  ElonsPath
//
//  Created by Azizbek Asadov on 24/03/23.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    // MARK: - SKNodes
    private var player: SKNode?
    private var joystick: SKNode?
    private var joystickKnob: SKNode?
    
    private var joystickAction: Bool = false
    private var knobRadius: CGFloat = 50.0
    
    // MARK: Sprite Engine
    private var previousTimeInterval: TimeInterval = 0
    private var playerIsFacingRight: Bool = true
    private let playerSpeed = 4.0
    
    // the first function to be called when we enter the game
    override func didMove(to view: SKView) {
        player = childNode(withName: "Player")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "Knob")
    }
    
    // implement
    // 1. Touch Began
    // 2. Touch Moved
    // 3. Touch Ended
}

// MARK: - Touches
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob, let joystick = joystick {
                let location = touch.location(in: joystick)
                joystickAction = joystickKnob.frame.contains(location)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let joystick = self.joystick,
            let joystickKnob = self.joystickKnob,
            joystickAction
        else { return }
        
        for touch in touches {
            let position = touch.location(in: joystick)
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystick = joystick {
                let xJSTCoordinate = touch.location(in: joystick).x
                let xLimit: CGFloat = 200.0
                
                if xJSTCoordinate > -xLimit && xJSTCoordinate < xLimit {
                    resetKnobPosition()
                }
            }
        }
    }
}

// MARK: - Actions
extension GameScene {
    private func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.2)
        moveBack.timingMode = .linear
        
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
}

// MARK: Game Loop
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        // Player Movement & Actions
        guard let joystickKnob = joystickKnob else {
            return
        }
        
        let xPosition = Double(joystickKnob.position.x)
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.moveBy(x: displacement.dx, y: displacement.dy, duration: 0)
        let faceChangeAction: SKAction!
        
        let isMovingRight = xPosition > 0
        let isMovingLeft = xPosition < 0
        
        if isMovingLeft && playerIsFacingRight {
            playerIsFacingRight = false
            
            let faceMovement = SKAction.scaleX(to: -1, duration: 0)
            faceChangeAction = SKAction.sequence([move, faceMovement])
        } else if isMovingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            
            let faceMovement = SKAction.scaleX(to: 1, duration: 0)
            faceChangeAction = SKAction.sequence([move, faceMovement])
        } else {
            faceChangeAction = move
        }
        
        player?.run(faceChangeAction)
    }
}
