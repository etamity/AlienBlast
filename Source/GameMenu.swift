//
//  INNGameMenu.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class GameMenu : CCNode{
    var gameRoot:CCNode! = nil;
    func gameButtonPresssed(sender:AnyObject!){
        gameRoot.removeAllChildren()
        self.loadLevel("LevelKing")

    }

    func loadLevel(levelName:String){
        
        let newLevelName:String = "Levels/\(levelName)";
        
        let currnetLevel = CCBReader.load(newLevelName);
        
        
        gameRoot.addChild(currnetLevel);
        
        let frame:CCDrawNode = CCDrawNode();
        if var verts : [CGPoint] = [] {
            verts.append(ccp(currnetLevel.position.x, currnetLevel.position.y))
            verts.append(ccp(currnetLevel.contentSize.width, currnetLevel.position.y))
            verts.append(ccp(currnetLevel.contentSize.width, currnetLevel.contentSize.height))
            verts.append(ccp(currnetLevel.position.x, currnetLevel.contentSize.height))
            frame.drawPolyWithVerts(verts, count: 4, fillColor: nil, borderWidth: 2.0, borderColor: CCColor.grayColor())
        }

        
        gameRoot.addChild(frame);

        
        
        let userInterface :UserInterFace = CCBReader.load("UserInterface") as! UserInterFace
        userInterface.position = CGPointMake(0, 0);
        gameRoot.addChild(userInterface)
        
    }
    func didLoadFromCCB(){
         gameRoot = self.parent
         OALSimpleAudio.sharedInstance().playBg(GameSoundType.GAME_MENU.rawValue, loop:true)
        
    }
}