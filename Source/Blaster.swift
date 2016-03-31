//
//  INNBlaster.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

enum BlasterType: String {
    case Circle_Blue
    case Circle_Brown
    case Circle_Green
    case Circle_Yellow
    case Circle_Sun
    case Clock
    case Heart
    case Star
    case UFO_Blue
    case Circle_Pink
}

class Blaster: CCSprite {
    
    var bornRate :Int = 100;
    var hurtRate :Int = 0;
    var healthRate :Int = 1;
    var type: BlasterType! = nil;
    
    func didLoadFromCCB(){
    
        self.userInteractionEnabled = false;
        self.physicsBody.collisionType = "shape";
        self.physicsBody.sensor = false
        self.physicsBody.collisionGroup = "blaster";
        self.physicsBody.affectedByGravity = true;
        self.type = BlasterType(rawValue: self.name)
        
    }
    

    func blast(){
        

        var points: Int = StaticData.sharedInstance.points;
        points += 1 ;
        StaticData.sharedInstance.points = points
            
        if (self.type == BlasterType.Heart){
            var lives : Int = StaticData.sharedInstance.lives;
            lives -= self.hurtRate;
            StaticData.sharedInstance.lives = lives
        }
        var touches : Int = StaticData.sharedInstance.touches;
        touches += self.hurtRate;
        StaticData.sharedInstance.touches = touches
        
        let pnode:CCParticleSystem = CCBReader.load("Effects/BlastParticles") as! CCParticleSystem;
            pnode.position = self.position;
            pnode.autoRemoveOnFinish = true;
            pnode.duration=0.5;
            self.parent.addChild(pnode);
            OALSimpleAudio.sharedInstance().playEffect(GameSoundType.BLAST.rawValue)
            self.removeFromParentAndCleanup(true);
            

    }
    
    override func update(delta: CCTime) {
        
        let rect : CGRect = CGRectMake(self.parent.position.x, self.parent.position.y,self.parent.contentSize.width, self.parent.contentSize.height + 200);
        
        let inRect : Bool = CGRectContainsPoint(rect,self.position);
        
        if (!inRect)
        {
            if (self.position.y < 0)
            {
                if (self.type != BlasterType.Heart){
                    var lives : Int = StaticData.sharedInstance.lives;
                    lives += self.hurtRate;
                    StaticData.sharedInstance.lives = lives
                    OALSimpleAudio.sharedInstance().playEffect(GameSoundType.HIT.rawValue)
                }
                
                let pnode: CCParticleSystem = CCBReader.load("Effects/HurtParticles") as! CCParticleSystem;
                pnode.position = self.position;
                pnode.autoRemoveOnFinish = true;
                pnode.duration = 0.5;
                self.parent.addChild(pnode);
            }
            self.removeFromParentAndCleanup(true);
            
        }
    }
}