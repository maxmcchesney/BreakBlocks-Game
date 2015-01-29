//
//  GameData.swift
//  Break
//
//  Created by Michael McChesney on 1/29/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

let _mainData: GameData = { GameData() }()

class GameData: NSObject {
    
    var topScore: Int = 0
    
    var levelsPassed: Int = 0
    
    var livesLost: Int = 0
    
    var bricksBroken: Int = 0
    
    var gamesPlayed: [[String:Int]] = []
    
    var currentGame: [String:Int]? {
        
        get {
            return gamesPlayed[gamesPlayed.count - 1]
        }
        
        set {
            gamesPlayed[gamesPlayed.count - 1] = newValue! as [String:Int]
        }

    }
    
    // (col, row)
    var allLevels = [
    
//        (4,1),
//        (6,2),
//        (7,3),
//        (8,4),
//        (8,5),
//        (8,6),
//        (6,7),
//        (2,8)

//        FOR TESTING USE THESE LEVELS
        (2,1),
        (2,1),
        (2,1),
        (2,1),
        (2,1),
        (2,1),
        (2,1),
        (2,1)
        
        
    ]
    
    var currentLevel = 0
    
    class func mainData() -> GameData {
        return _mainData
    }
   
    func startGame() {
        
        levelsPassed = 0
        livesLost = 0
        bricksBroken = 0
        
        gamesPlayed.append([
            
            "livesLost":0,
            "bricksBusted":0,
            "levelBeaten":0,
            "totalScore":0
            ])
    }
    
    func adjustValue(difference: Int, forKey key: String) {
        
        if var value =  currentGame?[key] {
            currentGame?[key] = value + difference
        }
        
    }
    
}















