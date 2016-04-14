//
//  INNStaticData.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation
import Darwin

enum GameEvent: String {
    case UPDATE_TOUCHES
    case UPDATE_POINTS
    case UPDATE_LIVES
    case UPDATE_LEVEL
    case UPDATE_FINGER
    case RESET_DEFULAT_FINGER
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
    case GAME_PLAYING1 = "Mishief Stroll.wav"
    case GAME_PLAYING2 = "Infinite Descent.wav"
    case GAME_PLAYING3 = "Farm Frolics.wav"
    case GAME_PLAYING4 = "Polka Train.wav"
    
    case BLAST = "phaserUp6.wav"
    case HIT = "phaserDown3.wav"
    case WAVEUP = "phaserUp4.wav"
    case LASER = "laser8.wav"
    case POWER = "zapThreeToneDown.wav"
}

enum FingerType: String {
    case Default = "DefaultFinger"
    case Sentry = "SentryFinger"
    case Shield = "ShieldFinger"
    case Blackhole = "BlackholeFinger"
    case Sword = "SwordFinger"
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
    case Finger_Sword
    case UFO_Yellow
    case UFO_Beige
    case UFO_Pink
    case UFO_Green
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
            }else if (_touches > 1000){
                _touches = 1000
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
    
    var achievements:[Int] = [20,40,50,80,100];
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
            BlasterType.Finger_Blackhole.rawValue,
            BlasterType.UFO_Yellow.rawValue,
            BlasterType.UFO_Green.rawValue,
            BlasterType.UFO_Pink.rawValue,
            BlasterType.UFO_Beige.rawValue,
            BlasterType.Finger_Sword.rawValue
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
    
    
    
    func saveData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(self.level, forKey: "LEVEL")
        defaults.setInteger(self.points, forKey: "POINTS")
        defaults.setInteger(self.lives, forKey: "LIVES")
        defaults.setInteger(self.touches, forKey: "TOUCHES")
        
        let points = defaults.integerForKey("BEST_POINTS")
        
        if (self.points > points){
            defaults.setInteger(self.level, forKey: "BEST_LEVEL")
            defaults.setInteger(self.points, forKey: "BEST_POINTS")
        }
        
        
        defaults.synchronize()
    }
    
    
    
    func loadData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        self.level = defaults.integerForKey("LEVEL")
        self.points = defaults.integerForKey("POINTS")
        self.lives = defaults.integerForKey("LIVES")
        self.touches = defaults.integerForKey("TOUCHES")
        if (self.lives <= 0 )
        {
            self.reset()
        }
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
    class func getIconFile(name:String)->String{
        return "Icons/\(name)"
    }
    
    class func getObjectFile(name:String)->String{
        return "Objects/\(name)"
    }
}