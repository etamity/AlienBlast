//
//  Finger.swift
//  AlienBlastSwift
//
//  Created by etamity on 30/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class Finger: CCSprite {
    
    //weak var fire:CCParticleSystem! = nil
    
    func didLoadFromCCB(){
        self.physicsBody.collisionType = "finger";
        //fire.position = self.position;
        //fire.autoRemoveOnFinish = false;
        //fire.duration = 0.5;
    }
    
    override func onExit() {
        super.onExit()
        //fire.autoRemoveOnFinish = true;
    }
    
    override func update(delta:CCTime){
        

    }
}