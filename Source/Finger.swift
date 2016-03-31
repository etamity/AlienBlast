//
//  Finger.swift
//  AlienBlastSwift
//
//  Created by etamity on 30/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class Finger: CCSprite {
    var followNode:CCNode! = nil;
    var shootCount:Int = 0;
    var offsetDegree : Int = 0;
    //weak var fire:CCParticleSystem! = nil
    
    func didLoadFromCCB(){
        self.physicsBody.collisionType = "finger";
        self.userInteractionEnabled = false;
//        if self.children != nil {
//            for child in self.children as! [CCNode]{
//                child.userInteractionEnabled = false
//            }
//            
//        }
        self.physicsBody.sensor = false
        self.shootCount = 0;
        self.offsetDegree = 0 ;
        followNode = CCNode()
        self.addChild(followNode);
    }
    func follow(target:CCNode){
        let position:CGPoint = ccp(target.position.x, target.position.y);
        let moveDuration:CCTime = 1;
        let playerMove:AnyObject = CCActionMoveTo.actionWithDuration(moveDuration,position:position);
        
        let follow:AnyObject = CCActionFollow.actionWithTarget(followNode,worldBoundary:self.parent.boundingBox());
        self.parent.parent.runAction(follow as! CCAction);
        followNode.runAction(playerMove as! CCAction);
        
    }
    
    
    func setTypeOfCountsFromName(typeName:String){

        let index = Int(StaticData.sharedInstance.ObjectTypes.indexOf(typeName)!)
        var count = 0;
        var offset = 0;
        switch (index) {
        case 0:
            count = 0;
            break;
        case 1:
            count=1;
            break;
        case 2:
            count=2;
            offset=90;
            break;
        case 3:
            count=3;
            offset=60;
            break;
        case 4:
            count=4;
            offset=45;
            break;
        case 5:
            count=5;
            break;
        case 6:
            count=0;
            break;
        case 7:
            count=12;
            break;
        case 8:
            count=5;
            break;
        default:
            break;
        }
        self.shootCount = count;
        self.offsetDegree = offset;
        print("typeName",typeName,shootCount,offsetDegree)
    }
    func blastTarget(targetName:String){
        var rotationRadians: Float = 0.0;
        var dircount :Int = 0;
        self.setTypeOfCountsFromName(targetName);
        if self.shootCount == 0 {
            return;
        }
        
        if (self.shootCount>0){
            dircount = 360 / self.shootCount;
            weak var bullet: CCNode! = nil;
            for i in 0 ..< self.shootCount {
                rotationRadians = CC_DEGREES_TO_RADIANS(Float(i*dircount+self.offsetDegree));
                let directionVector :CGPoint  = ccp(CGFloat(sinf(rotationRadians)),CGFloat(cosf(rotationRadians)));
                let bulletOffset :CGPoint = ccpMult(directionVector, 1);
                bullet = CCBReader.load("Objects/Bullet");
                bullet.position=ccpAdd(self.position, bulletOffset);
                bullet.physicsBody.collisionGroup = "blaster";
                
                
                let force: CGPoint = ccpMult(directionVector, 8000);
                bullet.physicsBody.applyForce(force);
                self.parent.addChild(bullet);
                
            }
        }
        //[self follow:self];
    }
    
    override func onExit() {
        super.onExit()
        //fire.autoRemoveOnFinish = true;
    }
    
    override func update(delta:CCTime){
        

    }
}