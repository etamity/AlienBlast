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
            if (newValue < 0){
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
        ObjectTypes = ["INNCircle_Blue",           //0
            "INNCircle_Brown",          //1
            "INNCircle_Green",          //2
            "INNCircle_Yellow",         //4
            "INNCircle_Sun",            //5
            "INNClock",                 //6
            "INNStar",                  //7
            "INNUFO_Blue",              //8
            "INNCircle_Pink",            //9
        ];
        bornRate = [80,70,60,30,10,7,5,5,3,1];
        _lives = 100;
        
        _touches = 1000;
        gameState = 0;    //game menu
    }
    
}