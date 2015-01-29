//
//  ViewController.swift
//  Break
//
//  Created by Michael McChesney on 1/28/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
    let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var livesView: LivesView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var score: Int = 0 {
        didSet {
            GameData.mainData().topScore = score

            if score > GameData.mainData().topScore { GameData.mainData().topScore = score }

            GameData.mainData().currentGame?["totalScore"] = score

//            println(GameData.mainData().currentGame)
            
            scoreLabel.text = "\(score)"
        }
    }
    
    var animator: UIDynamicAnimator?
    
    var gravityBehavior = UIGravityBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var brickBehavior = UIDynamicItemBehavior()
    var paddleBehavior = UIDynamicItemBehavior()
    
    var paddle = UIView(frame: CGRectMake(0, 0, 100, 10))
    
    var index = 0       // FOR FACE ARRAY
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        SET UP ANIMATOR
        animator = UIDynamicAnimator(referenceView: gameView)
        
        animator?.addBehavior(gravityBehavior)
        animator?.addBehavior(collisionBehavior)
        animator?.addBehavior(ballBehavior)
        animator?.addBehavior(brickBehavior)
        animator?.addBehavior(paddleBehavior)
        
//        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self

//        SET UP COLLISION BOUNDARIES
        collisionBehavior.addBoundaryWithIdentifier("ceiling", fromPoint: CGPointZero, toPoint: CGPointMake(SCREEN_WIDTH, 0))
        collisionBehavior.addBoundaryWithIdentifier("leftWall", fromPoint: CGPointZero, toPoint: CGPointMake(0, SCREEN_HEIGHT))
        collisionBehavior.addBoundaryWithIdentifier("rightWall", fromPoint: CGPointMake(SCREEN_WIDTH, 0), toPoint: CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT))
        collisionBehavior.addBoundaryWithIdentifier("lava", fromPoint: CGPointMake( 0, SCREEN_HEIGHT - 30), toPoint: CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT - 30))
        
//        CONFIGURE BALL BEHAVIOR
        ballBehavior.friction = 0
        ballBehavior.elasticity = 1
        ballBehavior.resistance = 0
        ballBehavior.allowsRotation = false

//        CONFIGURE BRICK AND BALL DENSITIES
        brickBehavior.density = 1000000
        paddleBehavior.density = 1000000
        


    }
    
    @IBAction func playGame() {
        
        GameData.mainData().startGame()

        titleLabel.hidden = true
        playButton.hidden = true
        
        score = 0
        livesView.livesLeft = 5
        index = 0
        
        createPaddle()
        createBricks()
        createBall()
        
    }
    
    func endGame(gameOver: Bool) {
        
        if gameOver {
            GameData.mainData().currentLevel = 0
        } else {
            GameData.mainData().currentLevel + 1
        }
        
        println(GameData.mainData().gamesPlayed.count)
        println(GameData.mainData().topScore)
        
        titleLabel.hidden = false
        playButton.hidden = false
        
//        REMOVE PADDLE
        paddle.removeFromSuperview()
        collisionBehavior.removeItem(paddle)
        paddleBehavior.removeItem(paddle)
        
//        REMOVE BRICKS
        for brick in brickBehavior.items as [UIView] {
            brick.removeFromSuperview()
            collisionBehavior.removeItem(brick)
            brickBehavior.removeItem(brick)
        }
        
//        REMOVE BALL
        
        for ball in ballBehavior.items as [UIView] {
            ball.removeFromSuperview()
            collisionBehavior.removeItem(ball)
            ballBehavior.removeItem(ball)
        }
        
    }
    
    
    
//    LISTEN FOR COLLISSIONS WITH THE BRICKS
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        ballBehavior.items
        brickBehavior.items
        
        for brick in brickBehavior.items as [UIView] {
            if brick.isEqual(item1) || brick.isEqual(item2) {
                
                brickBehavior.removeItem(brick)
                collisionBehavior.removeItem(brick)
                brick.removeFromSuperview()
                
                
//                INCREASE SCORE AND MAKE ANIMATED SCORE APPEAR WHEN BRICKS ARE DESTROYED
                score += 100
                
                GameData.mainData().adjustValue(1, forKey: "bricksBusted")
                
                var pointsLabel = UILabel(frame: brick.frame)
                pointsLabel.text = "+100"
                pointsLabel.textAlignment = .Center
                gameView.addSubview(pointsLabel)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    pointsLabel.alpha = 0
                    
                }, completion: { (succeeded) -> Void in
                    
                    pointsLabel.removeFromSuperview()
                })
                
            }
        }
        
        if brickBehavior.items.count == 0 {
            endGame(false)
        }
    }
    

//    CREATE THE BALL / HEAD IMAGE
    func createBall() {

        let faces = ["Jos_face_small.png", "Ellie_face_small.png", "Meg_face_small.png", "Sam_face_small.png", "Ally_face_small.png", "Maddie_face_small.png"]
 
//        var face = faces[Int(arc4random_uniform(UInt32(faces.count)))]        // MAKE FACES RANDOM RATHER THAN SEQUENTIAL
        var face = faces[index]

        if index > faces.count {
            index = 0
        } else {
            index++
        }
        println(index)
        var image = UIImage(named: face)
        var ball = UIImageView(image: image!)
        ball.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        gameView.addSubview(ball)
        
        ball.center.x = paddle.center.x
        ball.center.y = paddle.center.y - 40
        
//        ball.center = gameView.center
//        ball.backgroundColor = UIColor.orangeColor()
        ball.layer.cornerRadius = 20
        gameView.addSubview(ball)
        
//        gravityBehavior.addItem(ball)
        collisionBehavior.addItem(ball)
        ballBehavior.addItem(ball)
        
        var pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.25, -0.25)
        animator?.addBehavior(pushBehavior)
    }
    
//    SET COLLISION BEHAVIOR IF THE BALL HITS THE "LAVA" BOUNDARY
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        if let id = identifier as? String {
        
            if id == "lava" {
            
                var ball = item as UIView
                
                collisionBehavior.removeItem(ball)
                ballBehavior.removeItem(ball)
                
                ball.removeFromSuperview()
                
                if livesView.livesLeft == 0 { endGame(true); return }
                
                GameData.mainData().adjustValue(1 , forKey: "livesLost")
                
                livesView.livesLeft--
                
                createBall()
                
            }
        }
    }
    
//    CREATE THE BRICKS
    func createBricks() {
        
        var grid = GameData.mainData().allLevels[GameData.mainData().currentLevel]        // Tuple  grid.0, grid.1, etc.
        var gap: CGFloat = 10
        var width = (SCREEN_WIDTH - (gap * CGFloat(grid.0 + 1))) / CGFloat(grid.0)
        var height: CGFloat = 20
        
        for c in 0..<grid.0 {
            
            for r in 0..<grid.1 {
            
                var x = CGFloat(c) * (width + gap) + gap
                var y = CGFloat(r) * (height + gap) + 70
                
                var brick = UIView(frame: CGRectMake(x, y, width, height))
                brick.backgroundColor = UIColor.blackColor()
                brick.layer.cornerRadius = 3
                
                gameView.addSubview(brick)
                
                collisionBehavior.addItem(brick)
                brickBehavior.addItem(brick)
//                gravityBehavior.addItem(brick)
                
            }
            
        }
        
    }
    
    var attachmentBehavior: UIAttachmentBehavior?
    
//   CREATE THE PADDLE
    func createPaddle() {
        
        paddle.center.x = view.center.x
        paddle.center.y = SCREEN_HEIGHT - 40
        paddle.backgroundColor = UIColor.blackColor()
        paddle.layer.cornerRadius = 3
        gameView.addSubview(paddle)
        
        collisionBehavior.addItem(paddle)
        paddleBehavior.addItem(paddle)
        
        if attachmentBehavior == nil {

            attachmentBehavior = UIAttachmentBehavior(item: paddle, attachedToAnchor: paddle.center)
            animator?.addBehavior(attachmentBehavior)
            
        }
        
    }
    
//    LISTEN FOR TOUCHES TO MOVE THE PADDLE
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.allObjects.first as? UITouch {
            
            let location = touch.locationInView(gameView)
//            paddle.center.x = location.x
            attachmentBehavior?.anchorPoint.x = location.x
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

