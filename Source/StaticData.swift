//
//  INNStaticData.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

enum GameEvent: String {
    case UPDATE_TOUCHES
    case UPDATE_POINTS
    case UPDATE_LIVES
}


class StaticData:NSObject{
    var ObjectTypes:[String];
    
    var _touches: Int = 0;
    var _points: Int = 0;
    var _lives: Int = 0;
    var touches:Int{
        get {
            return _touches
        }
        set (newValue){
            _touches = newValue
            self.events.trigger(GameEvent.UPDATE_TOUCHES.rawValue,information: newValue)
        }
    }
    var points:Int {
        get {
            return _points
        }
        set (newValue){
            _points = newValue
            self.events.trigger(GameEvent.UPDATE_POINTS.rawValue,information: newValue)
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
            self.events.trigger(GameEvent.UPDATE_POINTS.rawValue,information: newValue)
        }
    }
    
    let events = EventManager();
    
    class var sharedInstance : StaticData {
        struct Static {
            static let instance : StaticData = StaticData()
        }
        
        return Static.instance
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
        _touches = 10;
        gameState = 0;    //game menu
    }
    
}