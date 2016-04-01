//
//  INNGameMenu.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class GameMenu : CCNode{
    weak var startGameBtn:CCButton! = nil
    weak var continueBtn:CCButton! = nil
    weak var topScoreBtn:CCButton! = nil
    func gameButtonPresssed(sender:CCButton!){
        if (sender == startGameBtn)
        {
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_START.rawValue)
            
        }else if (sender == continueBtn){
           StaticData.sharedInstance.events.trigger(GameEvent.GAME_CONTINUE.rawValue)
        }else if (sender == topScoreBtn){
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_TOPSCORE.rawValue)
        }
    }

    func didLoadFromCCB(){
         OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_MENU.rawValue), loop:true)
        
    }
}