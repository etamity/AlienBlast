//
//  INNINGameMenu.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class INGameMenu: CCNode{
    weak var _scoreLCD: CCLabelTTF! = nil;
    weak var _levelLCD:CCLabelTTF! = nil;
    weak var _closeButton:CCButton! = nil;
    weak var _menuButton:CCButton! = nil;
    weak var _restartButton:CCButton! = nil;
    
    weak var closeButton:CCButton!;

    func didLoadFromCCB(){
        OALSimpleAudio.sharedInstance().playBg(GameSoundType.INGAME_MENU.rawValue, loop:true)
    }
    
    func updateScoreLCD(value:Int){
     _scoreLCD.string = "\(value)"
    }
    func updateLevelLCD(value:Int){
    _levelLCD.string = "\(value)"
        
    }
    
}

