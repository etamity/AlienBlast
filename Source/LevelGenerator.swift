//
//  LevelGenerator.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
class LevelGenerator: CCNode {
    var speed:Float = 0.0;
    var level:Int = 1;
    var timeSpeed :Double = 1;
    var countOfTime:Int = 0;
    var hud:UserInterFace! = nil;
    class var sharedInstance : LevelGenerator {
        struct Static {
            static let instance : LevelGenerator = LevelGenerator()
        }
        
        return Static.instance
    }
    override init(){
        super.init()
        self.userInteractionEnabled = true;
        self.name = "LevelGenerator";
        self.initData();
        self.start();
    }
    func initData(){
        self.level = 0;
        self.speed = 3000;
        self.countOfTime = 3;
        
    }
    
    func start(){
        self.schedule(#selector(shootElements), interval: self.timeSpeed)
    }
    
    func startLevelData(level:Int){
        
    }
    
    func nextLevel(){
        self.speed += 1000;
        self.level += 1;

    }
    
    
    func shootElements(){
        let ElementsTypes = StaticData.sharedInstance.ObjectTypes;
        var rotationRadians:Float = 0;
        
        for _ in 0 ..< self.countOfTime {
            var index:Int = self.randomNumberBetween(0,max:ElementsTypes.count-1);
            let rate: Int = self.randomNumberBetween(0,max:100);
            let bornRate:Int = StaticData.sharedInstance.bornRate[index];
            if (rate<bornRate) {
                
            }else{
                index=0;
            }
            
            
            
            let type:String = ElementsTypes[index];
            let blaster : Blaster = CCBReader.load("Objects/\(type)") as! Blaster;
            
            blaster.name = type;
            
            rotationRadians = CC_DEGREES_TO_RADIANS(180);
            
            blaster.position = CGPointMake(CGFloat(self.randomNumberBetween(60, max:260)), 500);
            
            let directionVector : CGPoint  = ccp(CGFloat(sinf(rotationRadians)),CGFloat(cosf(rotationRadians)));
            let force:CGPoint = ccpMult(directionVector, CGFloat(self.speed));
            blaster.physicsBody.applyForce(force);
            self.addChild(blaster);
            
        }

    }
    func randomNumberBetween(min:Int,max:Int) ->Int{
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
}