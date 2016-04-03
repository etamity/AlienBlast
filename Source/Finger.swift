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
    var duringTime : Double = 1.0;
    var type : FingerType! = FingerType.Default
 
    func didLoadFromCCB(){
        self.physicsBody.collisionType = "finger";
        self.userInteractionEnabled = false;

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

        let oType : BlasterType = BlasterType(rawValue: typeName)!
        var count = 0;
        var offset = 0;
        switch (oType) {

        case .UFO_Beige:
            count=2;
            offset=90;
            break;
        case .UFO_Blue:
            count=4;
            offset=45;
            break;
        case .UFO_Green:
            count=6;
            offset=30;
            break;
        case .UFO_Pink:
            count=12;
            break;
        case .Circle_Yellow:
            count=8;
            break;
        default:
            break;
        }
        self.shootCount = count;
        self.offsetDegree = offset;

    }
    func blastTarget(targetName:String,node:CCNode){

        
        self.setTypeOfCountsFromName(targetName);
        if self.shootCount == 0 {
            return;
        }
        
        var rotationRadians: Float = 0.0;
        var dircount :Int = 0;
        if (self.shootCount>0){
            dircount = 360 / self.shootCount;
            weak var bullet: CCNode! = nil;
            for i in 0 ..< self.shootCount {
                rotationRadians = CC_DEGREES_TO_RADIANS(Float(i*dircount+self.offsetDegree));
                let directionVector :CGPoint  = ccp(CGFloat(sinf(rotationRadians)),CGFloat(cosf(rotationRadians)));
                let bulletOffset :CGPoint = ccpMult(directionVector, 1);
                bullet = CCBReader.load("Objects/Bullet");
                if let abullect = bullet {
                    abullect.position=ccpAdd(self.position, bulletOffset);
                    abullect.physicsBody.collisionGroup = "blaster";
                    
                    
                    let force: CGPoint = ccpMult(directionVector, 5000);
                    abullect.physicsBody.applyForce(force);
                    node.addChild(abullect);
                }
                
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