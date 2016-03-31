//
//  INNBlaster.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class Blaster: CCSprite {
    
    var followNode:CCNode! = nil;
    var _shootCount:Int = 0;
    var _offsetDegree : Int = 0;

    func initType(){
        
        
    }
    func didLoadFromCCB(){
        self._shootCount = 0;
        self._offsetDegree = 0 ;
        self.userInteractionEnabled = false;
        self.physicsBody.collisionType = "shape";
        //self.physicsBody.affectedByGravity = true
        self.physicsBody.sensor = true
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
    
//    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//     
//    }
//    
//    
//    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        self.blast();
//        var touches : Int = StaticData.sharedInstance.touches;
//        touches -= 1 ;
//        StaticData.sharedInstance.touches = touches
//    }
    
    func setTypeOfCountsFromName(typeName:String){
        print("typeName",typeName)
        let index = Int(StaticData.sharedInstance.ObjectTypes.indexOf(typeName)!)
        var count = 0;
        var offset = 0;
        switch (index) {
        case 0:
            count=0;
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
        _shootCount = count;
        _offsetDegree = offset;
    }
    func blast(){
        var rotationRadians: Float = 0.0;
        var dircount :Int = 0;
        let targetName : String = self.name;
        self.setTypeOfCountsFromName(targetName);
            
        self.physicsBody.collisionGroup = "blaster";
        if (_shootCount>0){
            dircount = 360/_shootCount;
            var bullet: CCNode;
            for i in 0 ..< _shootCount {
                rotationRadians = CC_DEGREES_TO_RADIANS(Float(i*dircount+_offsetDegree));
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
        var points: Int = StaticData.sharedInstance.points;
            points += 1 ;
            StaticData.sharedInstance.points = points
            

        let pnode:CCParticleSystem = CCBReader.load("Effects/BlastParticles") as! CCParticleSystem;
            pnode.position = self.position;
            pnode.autoRemoveOnFinish = true;
            pnode.duration=0.5;
            self.parent.addChild(pnode);
        
            self.removeFromParentAndCleanup(true);
            

    }
    
    override func update(delta: CCTime) {
        
        let rect : CGRect = CGRectMake(self.parent.position.x, self.parent.position.y,self.parent.contentSize.width, self.parent.contentSize.height + 200);
        
        let inRect : Bool = CGRectContainsPoint(rect,self.position);
        
        if (!inRect)
        {
            if (self.position.y < 0)
            {
                var lives : Int = StaticData.sharedInstance.lives;
                lives -= 1;
                StaticData.sharedInstance.lives = lives
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