//
//  INNUserInterFace.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class  UserInterFace: CCNode {
    weak var livesLCD:CCLabelTTF! = nil;
    weak var pointsLCD:CCLabelTTF! = nil;
    weak var touchesLCD:CCLabelTTF! = nil;
    weak var liveBar:CCNodeColor! = nil;
    weak var levelLCD:CCLabelTTF! = nil;

    
    func didLoadFromCCB(){
        let staticData = StaticData.sharedInstance
        staticData.events.listenTo(GameEvent.UPDATE_LIVES.rawValue) { (info:Any?) in
            if let data = info as? Int {
            self.updateLives(data);
            }
        }
        
        staticData.events.listenTo(GameEvent.UPDATE_POINTS.rawValue) { (info:Any?) in
            if let data = info as? Int {
                self.updatePoints(data);
            }
        }
        
        staticData.events.listenTo(GameEvent.UPDATE_TOUCHES.rawValue) { (info:Any?) in
            if let data = info as? Int {
                self.updateTouchesLCD(data);
            }
        }
    }
    
    func updateLives(value:Int){
        self.livesLCD.string = "\(value)"
    }
    func updateTouchesLCD(value:Int){
        self.touchesLCD.string = "\(value)"
    }
    func updateLevel(value:Int){
        self.levelLCD.string = "\(value)"
    }

    func updatePoints(value:Int){
        self.pointsLCD.string = "\(value)"
    }
    

    
}