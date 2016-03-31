//
//  INNStaticData.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
import Darwin

enum GameEvent: String {
    case UPDATE_TOUCHES
    case UPDATE_POINTS
    case UPDATE_LIVES
    case UPDATE_LEVEL
}

enum GameSoundType:String{
    case GAME_MENU = "Sounds/Sad Town.wav"
    case INGAME_MENU = "Sounds/Retro Comedy.wav"
    case GAME_PLAYING = "Sounds/Cheerful Annoyance.wav"
    case GAME_PLAYING1 = "Sounds/Night at the Beach.wav"
    case BLAST = "Sounds/rockHit2.wav"
    case HIT = "Sounds/zap1.wav"
    case WAVEUP = "Sounds/powerUp6.wav"
}


class StaticData:NSObject{
    var ObjectTypes:[String];
    var _touches: Int = 0;
    var _points: Int = 0;
    var _lives: Int = 0;
    var _level : Int = 1;
    
    var touches:Int{
        get {
            return _touches
        }
        set (newValue){
            if (newValue < 10){
                _touches = 10
            }else{
                _touches = newValue
            }
         
            self.events.trigger(GameEvent.UPDATE_TOUCHES.rawValue,information: _touches)
        }
    }
    var points:Int {
        get {
            return _points
        }
        set (newValue){
            _points = newValue
            self.events.trigger(GameEvent.UPDATE_POINTS.rawValue,information: newValue)
            let checkLevel:Int = self.checkLevelUpgrade(newValue)
            if self.level <= checkLevel{
                self.level = checkLevel
            }
        
        }
    }
    
    var level : Int {
        get {
            return _level
        }
        set(newValue){
            if (_level !=  newValue){
            _level = newValue
            self.events.trigger(GameEvent.UPDATE_LEVEL.rawValue,information: newValue)
            }
        }
    }
    
    var gameState = 0;
    var bornRate:[Int];
    var lives :Int {
        get {
            return _lives
        }
        set (newValue){
            _lives = newValue
            self.events.trigger(GameEvent.UPDATE_LIVES.rawValue,information: newValue)
        }
    }
    
    let events = EventManager();
    
    class var sharedInstance : StaticData {
        struct Static {
            static let instance : StaticData = StaticData()
        }
        
        return Static.instance
    }
    
    func checkLevelUpgrade(exp:Int)->Int{
        let constA :Double = 8.7
        let constB :Double = -40.0
        let constC :Double = 111.0
        let level : Double = max(floor( constA * log(Double(exp) + constC) + constB ), 1 )
        
        return Int(level)
    }
    
    override init () {
        ObjectTypes = [
            BlasterType.Circle_Blue.rawValue,
            BlasterType.Circle_Brown.rawValue,
            BlasterType.Circle_Green.rawValue,
            BlasterType.Circle_Yellow.rawValue,
            BlasterType.Circle_Sun.rawValue,
            BlasterType.Clock.rawValue,
            BlasterType.Heart.rawValue,
            BlasterType.Star.rawValue,
            BlasterType.UFO_Blue.rawValue,
            BlasterType.Circle_Pink.rawValue
        ];
        bornRate = []
        weak var node:Blaster! = nil;
        for objectName in ObjectTypes {
            node = CCBReader.load("Objects/\(objectName)") as! Blaster
            bornRate.append(node.bornRate)
        }

        _lives = 100;
        
        _touches = 1000;
        gameState = 0;    //game menu
    }
    
}