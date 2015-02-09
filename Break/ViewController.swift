//
//  ViewController.swift
//  Break
//
//  Created by Michael McChesney on 1/28/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

// HOMEWORK

// - DONE - don't reset lives if going to new level
// - DONE - add at least 10 more levels
// - DONE - add labels in storyboard, that will be hidden during gameplay
//   these will show up at the end of a level
//   they will have the score, lives lost, bricks broken, and levels passed

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
    let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var livesView: LivesView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var levelsPassedLabel: UILabel!
    @IBOutlet weak var scoreTotalLabel: UILabel!
    @IBOutlet weak var bricksBrokenLabel: UILabel!
    @IBOutlet weak var livesLostLabel: UILabel!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    
    var animator: UIDynamicAnimator?
    
    var gravityBehavior = UIGravityBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var brickBehavior = UIDynamicItemBehavior()
    var paddleBehavior = UIDynamicItemBehavior()
    
    var paddle = UIView(frame: CGRectMake(0, 0, 100, 10))
    
    var index = 0       // FOR FACE ARRAY
    var facesCount = 0
    var gameInProgress = false
    
    var score: Int = 0 {
        didSet {
            if score > GameData.mainData().topScore { GameData.mainData().topScore = score }
            GameData.mainData().currentGame?["totalScore"] = score
            scoreLabel.text = "\(score)"
            scoreTotalLabel.text = "Score Total: \(score)"
        }
    }
    
    var levelsWon: Int = 0 {
        didSet {
            if levelsWon > GameData.mainData().levelsPassed { GameData.mainData().levelsPassed = levelsWon }
            GameData.mainData().currentGame?["levelBeaten"] = levelsWon
            levelsPassedLabel.text = "Levels passed: \(levelsWon)"
        }
    }
    
    var livesLost: Int = 0 {
        didSet {
            if livesLost > GameData.mainData().livesLost { GameData.mainData().livesLost = livesLost }
            GameData.mainData().currentGame?["livesLost"] = livesLost
            livesLostLabel.text = "Lives lost: \(livesLost)"
        }
    }
    
    var bricksBroken: Int = 0 {
        didSet {
            if bricksBroken > GameData.mainData().bricksBroken { GameData.mainData().bricksBroken = bricksBroken }
            GameData.mainData().currentGame?["bricksBusted"] = bricksBroken
            bricksBrokenLabel.text = "Bricks busted: \(bricksBroken)"
        }
    }
    
    
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
        ballBehavior.allowsRotation = true
        ballBehavior.angularResistance = 0

//        CONFIGURE PADDLE BEHAVIOR
        paddleBehavior.allowsRotation = false

//        CONFIGURE BRICK AND BALL DENSITIES
        brickBehavior.density = 1000000
        paddleBehavior.density = 1000000
        
//        HIDE LABELS IN BEGINNING
        livesLostLabel.hidden = true
        bricksBrokenLabel.hidden = true
        levelsPassedLabel.hidden = true
        scoreTotalLabel.hidden = true
        gameOverLabel.hidden = true
        
    }

    @IBAction func playGame() {

        titleLabel.hidden = true
        playButton.hidden = true
        
        livesLostLabel.hidden = true
        bricksBrokenLabel.hidden = true
        levelsPassedLabel.hidden = true
        scoreTotalLabel.hidden = true
        gameOverLabel.hidden = true

        GameData.mainData().startGame()
        
        if !gameInProgress {
            score = 0
            livesView.livesLeft = 5
            bricksBroken = 0
            livesLost = 0
            levelsWon = 0
            
        }
        
        createPaddle()
        createBricks()
        createBall()
        
    }
    
    func endGame(gameOver: Bool) {
        
        if gameOver {
            GameData.mainData().currentLevel = 0
            gameInProgress = false
            gameOverLabel.hidden = false
        } else {
            GameData.mainData().currentLevel++
            levelsWon++
            gameInProgress = true
        }
        println("Current level: \(GameData.mainData().currentLevel)")
        println("Games played: \(GameData.mainData().gamesPlayed.count)")
        println("Top score: \(GameData.mainData().topScore)")
        println("Levels passed: \(GameData.mainData().levelsPassed)")
        
        titleLabel.hidden = false
        playButton.hidden = false
        
        livesLostLabel.hidden = false
        bricksBrokenLabel.hidden = false
        levelsPassedLabel.hidden = false
        scoreTotalLabel.hidden = false
        
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
        for ball in ballBehavior.items as [UIImageView] {
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
                bricksBroken++
                
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

        let faces = ["Mom_face_small.png", "Ruby_face_small.png", "Mitch_face_small.png", "Meg_face_small.png", "Ellie_face_small.png", "Ally_face_small.png", "Maddie_face_small.png", "Sam_face_small.png"]
 
//        var face = faces[Int(arc4random_uniform(UInt32(faces.count)))]        // MAKE FACES RANDOM RATHER THAN SEQUENTIAL

        facesCount = faces.count
        if ++index >= facesCount {
            index = 0
        }
        var face = faces[index]
        
        var image = UIImage(named: face)
        var ball = UIImageView(image: image!)
        ball.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
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
        pushBehavior.pushDirection = CGVectorMake(0.75, -0.75)
        animator?.addBehavior(pushBehavior)
    }
    
//    SET COLLISION BEHAVIOR IF THE BALL HITS THE "LAVA" BOUNDARY
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        if let id = identifier as? String {
        
            if id == "lava" {
            
                var ball = item as UIImageView
                
                collisionBehavior.removeItem(ball)
                ballBehavior.removeItem(ball)
                
                ball.removeFromSuperview()
                
                if livesView.livesLeft == 0 { endGame(true); return }
                
                GameData.mainData().adjustValue(1 , forKey: "livesLost")
                
                livesView.livesLeft--
                livesLost++
                
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
                var y = CGFloat(r) * (height + gap) + 45    // CHANGE DISTANCE FROM BRICKS TO TOP HERE
                
                var brick = UIView(frame: CGRectMake(x, y, width, height))
                brick.backgroundColor = UIColor.blackColor()
                brick.layer.cornerRadius = 5
                
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
        paddle.center.y = SCREEN_HEIGHT - 40    // CHANGE POSITION OF SLIDER HERE (BUT BEWARE)
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

