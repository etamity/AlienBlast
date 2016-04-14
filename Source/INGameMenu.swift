//
//  INNINGameMenu.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation
class INGameMenu: CCNode{
    weak var scoreLCD: CCLabelTTF! = nil;
    weak var waveLCD:CCLabelTTF! = nil;
    weak var closeButton:CCButton! = nil;
    weak var menuButton:CCButton! = nil;
    weak var restartButton:CCButton! = nil;
    weak var resumeButton:CCButton! = nil;
    weak var gameOverBtns:CCLayoutBox! = nil;
    var title:CCLabelTTF! = nil;
    func didLoadFromCCB(){
        
      OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.INGAME_MENU.rawValue), loop:true)
    
    }
    
    func updateScoreLCD(value:Int){
        scoreLCD.string = "\(value)"
    }
    func updateLevelLCD(value:Int){
        waveLCD.string = "\(value)"
        
    }
    
    func gameOverView(){
        self.title.string = "GAME OVER"
        if let button = resumeButton{
            button.removeFromParent()
        }
    }
    func gamePauseView(){
        StaticData.sharedInstance.saveData()
        
        self.title.string = "GAME PAUSE"
        if let button = restartButton{
            button.removeFromParent()
        }
    

    }
    
    func gameButtonPresssed(sender:CCButton!) {
        if sender.name == "restartButton"{
            StaticData.sharedInstance.reset()
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_START.rawValue)
        }
        if sender.name == "menuButton"{
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_MAINMENU.rawValue)
        }
        
        if sender.name == "resumeButton"{
            self.removeFromParent()
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_RESUME.rawValue)
        }
    }
    
}

