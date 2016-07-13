//
//  UserInterFace.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation
class  UserInterFace: CCNode {
    weak var livesLCD:CCLabelTTF! = nil;
    weak var pointsLCD:CCLabelTTF! = nil;
    weak var touchesBar:CCNodeColor! = nil;
    weak var levelLCD:CCLabelTTF! = nil;
    weak var pauseBtn: CCButton! = nil;
    weak var touchBarBg:CCNodeColor! = nil;
    weak var statusPanel :CCNode! = nil;
    weak var waveLabel :CCNode! = nil;
    weak var powerBox:CCLayoutBox! = nil;
    weak var heartIcon:CCSprite! = nil;
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
        staticData.events.listenTo(GameEvent.UPDATE_LEVEL.rawValue) { (info:Any?) in
            if let data = info as? Int {
                self.updateLevel(data);
            }
        }
        staticData.events.listenTo(GameEvent.GAME_RESUME.rawValue) {
          self.pauseBtn.visible = true;
        }
        
        
        staticData.events.listenTo(GameEvent.UPDATE_FINGER.rawValue) { (info:Any?) in
            if let data = info as? String {
                self.powerBox.removeAllChildrenWithCleanup(true)
                let type : FingerType = FingerType(rawValue: data)!
                let fingerFile : String = StaticData.getIconFile(type.rawValue)
                let fingerNode  = CCBReader.load(fingerFile)
                self.powerBox.addChild(fingerNode)
            }
        }
        
        staticData.events.listenTo(GameEvent.RESET_DEFULAT_FINGER.rawValue) {
       
                self.powerBox.removeAllChildrenWithCleanup(true)
                let fingerFile : String = StaticData.getIconFile(FingerType.Default.rawValue)
                let fingerNode  = CCBReader.load(fingerFile)
                self.powerBox.addChild(fingerNode)
            
        }
        
        self.updateLevel(staticData.level)
        self.updateLives(staticData.lives)
        self.updatePoints(staticData.points)
        self.updateTouchesLCD(staticData.touches)
        

        self.updateLayout()
    }
    
    func topUpAnimation(target:CCNode,block:()->Void){

        let scaleToHeart1 = CCActionScaleTo.actionWithDuration(0.5, scale: 0.35)
        let scaleToHeart2 = CCActionScaleTo.actionWithDuration(0.5, scale: 0.5)
        let scaleToHeart3 = CCActionScaleTo.actionWithDuration(0.5, scale: 0.4)
        let callback = CCActionCallBlock.actionWithBlock({
            block()
        })
        let sequene = CCActionSequence.actionWithArray([scaleToHeart1,scaleToHeart2,scaleToHeart3,callback])
        target.runAction(sequene as! CCActionSequence)
    }
    
    override func viewDidResizeTo(newViewSize: CGSize) {
        super.viewDidResizeTo(newViewSize)
          self.updateLayout()
    }
    // Re-layout the game ui and graphics
    func updateLayout(){
        touchesBar.contentSize.width = CCDirector.sharedDirector().viewSize().width - 2
        touchBarBg.contentSize.width = CCDirector.sharedDirector().viewSize().width

        statusPanel.position.y = CCDirector.sharedDirector().viewSize().height - 530
      
        waveLabel.position.x = CCDirector.sharedDirector().viewSize().width - 70
        pauseBtn.position.x = CCDirector.sharedDirector().viewSize().width - 25
        pointsLCD.position.x = CCDirector.sharedDirector().viewSize().width / 2
    }
    
    func pauseGame(sender:CCButton!){
        StaticData.sharedInstance.events.trigger(GameEvent.GAME_PAUSE.rawValue)
        pauseBtn.visible = false;
    }
    
    func updateLives(value:Int){
        
        self.topUpAnimation(self.heartIcon) { 
    
        }
        self.livesLCD.string = "\(value)"
    }
    func updateTouchesLCD(value:Int){
        self.touchesBar.contentSize.width = (CCDirector.sharedDirector().viewSize().width - 2) / 1000 * CGFloat(value)
        if (value < 200){
            if (self.touchBarBg.animationManager.runningSequenceName != "WarningBarAnimation")
            {
                self.touchBarBg.animationManager.runAnimationsForSequenceNamed("WarningBarAnimation")
            }
        } else{
            self.touchBarBg.animationManager.runAnimationsForSequenceNamed("Default Timeline")
        }
    }
    func updateLevel(value:Int){
        self.levelLCD.string = "\(value)"
    }

    func updatePoints(value:Int){
        self.pointsLCD.string = "\(value)"
    }
    

    
}