//
//  GameMenu.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation

class GameMenu : CCNode{
    weak var startGameBtn:CCButton! = nil
    weak var continueBtn:CCButton! = nil
    weak var topScoreBtn:CCButton! = nil
    weak var bestScore:CCLabelTTF! = nil
    
    func gameButtonPresssed(sender:CCButton!){
        if (sender == startGameBtn)
        {
            StaticData.sharedInstance.reset()
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_START.rawValue)
            
        }else if (sender == continueBtn){
           StaticData.sharedInstance.loadData()
           StaticData.sharedInstance.events.trigger(GameEvent.GAME_CONTINUE.rawValue)
        }else if (sender == topScoreBtn){
            StaticData.sharedInstance.events.trigger(GameEvent.GAME_TOPSCORE.rawValue)
        }
    }

    func didLoadFromCCB(){
        OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_MENU.rawValue), loop:true)
        let defaults = NSUserDefaults.standardUserDefaults()
        let level = defaults.integerForKey("BEST_LEVEL")
        let points = defaults.integerForKey("BEST_POINTS")
     
        bestScore.string = "Best Wave: \(level) \n Best Score: \(points)"
            
        
        
       
        
    }
}