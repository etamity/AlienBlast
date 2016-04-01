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
    case UPDATE_FINGER
    case GAME_OVER
    case GAME_PAUSE
    case GAME_START
    case GAME_CONTINUE
    case GAME_MAINMENU
    case GAME_TOPSCORE
    case GAME_RESUME
}

enum GameSoundType:String{
    case GAME_MENU = "Sad Town.wav"
    case INGAME_MENU = "Retro Comedy.wav"
    case GAME_PLAYING = "Cheerful Annoyance.wav"
    case GAME_PLAYING1 = "Night at the Beach.wav"
    case BLAST = "switch23.wav"
    case HIT = "zap1.wav"
    case WAVEUP = "phaserUp6.wav"
}

enum FingerType: String {
    case Default = "DefaultFinger"
    case Sentry = "SentryFinger"
    case Shield = "ShieldFinger"
    case Blackhole = "BlackholeFinger"
}


enum BlasterType: String {
    case Circle_Blue
    case Circle_Brown
    case Circle_Green
    case Circle_Yellow
    case Circle_Sun
    case Clock
    case Heart
    case Star
    case UFO_Blue
    case Circle_Pink
    case Finger_Sentry
    case Finger_Shield
    case Finger_Blackhole
}

enum EffectType: String {
    case BLAST = "BlastParticles"
    case HURT = "HurtParticles"
    case TRANSFORM = "TransformParticles"
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
            if (newValue < 50){
                _touches = 50
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
    
    var bornRate:[Int];
    var lives :Int {
        get {
            return _lives
        }
        set (newValue){
            _lives = newValue
            if (_lives <= 0){
                _lives = 0
                self.events.trigger(GameEvent.GAME_OVER.rawValue)
                
            }
            
            self.events.trigger(GameEvent.UPDATE_LIVES.rawValue,information: _lives)
            
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
            BlasterType.Circle_Pink.rawValue,
            BlasterType.Finger_Shield.rawValue,
            BlasterType.Finger_Sentry.rawValue,
            BlasterType.Finger_Blackhole.rawValue
        ];
        bornRate = []
        weak var node:Blaster! = nil;
        for objectName in ObjectTypes {
            node = CCBReader.load(StaticData.getObjectFile(objectName)) as! Blaster
            bornRate.append(node.bornRate)
        }

        _lives = 100;
        
        _touches = 1000;
    }
    
    func reset(){
        self.level = 1
        self.lives = 100
        self.points = 0
        self.touches = 1000
    }
    
    
    
    class func getSoundFile(name:String)->String{
        return "Sounds/\(name)"
    }
    
    class func getEffectFile(name:String)->String{
        return "Effects/\(name)"
    }
    
    class func getFingerFile(name:String)->String{
        return "Fingers/\(name)"
    }
    class func getObjectFile(name:String)->String{
        return "Objects/\(name)"
    }
}