//
//  Bullet.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation
class Bullet: CCSprite {

    func didLoadFromCCB(){
        self.physicsBody.collisionType = "bullet";
        self.userInteractionEnabled = false;
        self.physicsBody.sensor = false;
    }
    override func update(delta:CCTime){
        
        let rect: CGRect = CGRectMake(self.parent.position.x, self.parent.position.y,CCDirector.sharedDirector().viewSize().width, CCDirector.sharedDirector().viewSize().height);
        
        let inRect:Bool = CGRectContainsPoint(rect,self.position);
        
        if (!inRect)
        {
            self.removeFromParentAndCleanup(true);
        }
    }
}