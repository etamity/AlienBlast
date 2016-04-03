//
//  SentryFinger.swift
//  AlienBlastSwift
//
//  Created by etamity on 01/04/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class SentryFinger: Finger {
    
    weak var leftCanon: CCParticleSystem! = nil
    weak var rightCanon: CCParticleSystem! = nil
    override func didLoadFromCCB() {
        super.didLoadFromCCB()
        self.type = FingerType.Sentry

    }
    
    func onShootBullet(){
        OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.LASER.rawValue))

        self.shootBullet(self.convertToWorldSpace(leftCanon.position))
        self.shootBullet(self.convertToWorldSpace(rightCanon.position))
        self.shootBullet(self.position)
    }
    
    
    func shootBullet(startPos:CGPoint){
     
        var rotationRadians: Float = 0.0;
        rotationRadians = CC_DEGREES_TO_RADIANS(Float(0));
        let directionVector :CGPoint  = ccp(CGFloat(sinf(rotationRadians)),CGFloat(cosf(rotationRadians)));
        let bulletOffset :CGPoint = ccpMult(directionVector, 1);
        
        
        weak var bullet: CCNode! = nil;
        bullet = CCBReader.load("Objects/Laser");
        bullet.physicsBody.collisionGroup = "blaster";
        bullet.position = ccpAdd(startPos, bulletOffset);
        bullet.position.y += 20
        let force: CGPoint = ccpMult(directionVector, 8000);
        bullet.physicsBody.applyForce(force);
        self.parent.addChild(bullet);
      
    }
    
    override func onEnter() {
        super.onEnter()
        self.schedule(#selector(self.onShootBullet), interval: 0.2)
    }
    override func onExit() {
        super.onExit()
        self.unscheduleAllSelectors()
    }
    
}