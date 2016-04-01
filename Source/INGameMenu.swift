//
//  INNINGameMenu.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class INGameMenu: CCNode{
    weak var scoreLCD: CCLabelTTF! = nil;
    weak var waveLCD:CCLabelTTF! = nil;
    weak var closeButton:CCButton! = nil;
    weak var menuButton:CCButton! = nil;
    weak var restartButton:CCButton! = nil;
    weak var continueButton:CCButton! = nil;
    weak var gameOverBtns:CCLayoutBox! = nil;
    var title:CCLabelTTF! = nil;
    func didLoadFromCCB(){
        OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.INGAME_MENU.rawValue), loop:true)
        self.gameOverView()
    }
    
    func updateScoreLCD(value:Int){
        scoreLCD.string = "\(value)"
    }
    func updateLevelLCD(value:Int){
        waveLCD.string = "\(value)"
        
    }
    
    func gameOverView(){
        self.title.string = "GAME OVER"
        continueButton.visible = false
        gameOverBtns.visible = true
    }
    func gamePauseView(){
        self.title.string = "GAME PAUSE"
        continueButton.visible = true
        gameOverBtns.visible = false
    }
    
    func gameButtonPresssed(sender:CCButton!) {
        if sender == restartButton{
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_START.rawValue)
        }
        if sender == menuButton{
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_MAINMENU.rawValue)
        }
        
        if sender == continueButton{
            self.removeFromParent()
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_RESUME.rawValue)
        }
    }
    
}

