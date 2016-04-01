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
    var finger:Finger! = nil
    var touched :Bool = false;
    class var sharedInstance : LevelGenerator {
        struct Static {
            static let instance : LevelGenerator = LevelGenerator()
        }
        
        return Static.instance
    }

    func didLoadFromCCB(){
        self.userInteractionEnabled = true;
        self.name = "LevelGenerator";
        self.initData();
      
        finger = CCBReader.load(StaticData.getFingerFile(FingerType.Default.rawValue)) as! Finger
        self.addChild(finger)
        let staticData = StaticData.sharedInstance
        
        staticData.events.listenTo(GameEvent.UPDATE_LEVEL.rawValue) { (info:Any?) in
            if let data = info as? Int {
                if (self.paused == false){
                    self.upgrageLevel(data)
                    self.goNextLevel()
                }
            }
            
        }
        
        staticData.events.listenTo(GameEvent.UPDATE_FINGER.rawValue) { (info:Any?) in
            if let data = info as? String {
                let type : FingerType = FingerType(rawValue: data)!
                    print(type,self.finger.type)
                if (self.finger.type != type)
                {
                    self.transformFinger(type)
                    self.schedule(#selector(self.onFinishedFinger), interval: self.finger.duringTime)
                    
                }
            }
        }
        
        
        staticData.events.listenTo(GameEvent.GAME_OVER.rawValue) {
            self.stop()
        
            let gameover : INGameMenu = CCBReader.load("InGameMenu") as! INGameMenu
            gameover.updateLevelLCD(self.level)
            gameover.updateScoreLCD(staticData.points)
            gameover.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
            self.addChild(gameover)
         
        }
        
        staticData.events.listenTo(GameEvent.GAME_PAUSE.rawValue) {
            
            self.stop()
            
            let gamepause : INGameMenu = CCBReader.load("InGameMenu") as! INGameMenu
            gamepause.updateLevelLCD(self.level)
            gamepause.updateScoreLCD(staticData.points)
            gamepause.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
            gamepause.gamePauseView()
            self.addChild(gamepause)
         
        }
        
        staticData.events.listenTo(GameEvent.GAME_RESUME.rawValue) {
            self.resume();
            self.changeBgMusic(0)
            
        }
    
        
        
        OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING.rawValue), loop:true)
        self.schedule(#selector(increaseTouches), interval: 0.01)
        
        self.upgrageLevel(staticData.level)
        self.start()
    }
    
    
    func initData(){
        self.level = 1;
        self.speed = 3000;
        self.countOfTime = 1;
        
    }
    
    func start(){
        self.paused = false
        self.schedule(#selector(shootElements), interval: self.timeSpeed)
        if (self.level % 10 == 0){
            self.changeBgMusic(self.level % 2)
        }

    }
    
    func changeBgMusic(index:Int){
        switch index {
        case 0:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING1.rawValue), loop:true)
        default:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING.rawValue), loop:true)
        }
   
 
    }
    
    
    func stop(){
        self.paused = true
        CCDirector.sharedDirector().pause()
    }

    func resume(){
        self.paused = false
        CCDirector.sharedDirector().resume()
    }
    
    func increaseTouches(){
        
        if (StaticData.sharedInstance.touches < 1000 && self.touched == false){
            StaticData.sharedInstance.touches += 1 ;
        }
    }
    
    
    func upgrageLevel(newlevel:Int){
        let nextSpeed = Float(newlevel) * 200 + self.speed;
        
        if (nextSpeed < 9000){
           self.speed = nextSpeed
        }else{
           self.speed = 9000;
        }
        
  
        self.level = newlevel;
        let newCountOfTime = 1 + Int(newlevel * (newlevel % 5))
        if (newCountOfTime < 5){
            self.countOfTime = newCountOfTime;
        }else{
            
            self.countOfTime = 5 ;
        }
      
        self.timeSpeed = self.timeSpeed - 0.1;
        if (self.timeSpeed <= 0.1 )
        {
            self.timeSpeed = 0.9;
        }
   

    }
    
    func transformFinger(type:FingerType){
        let fingerFile : String = StaticData.getFingerFile(type.rawValue)
        let effectFile : String = StaticData.getEffectFile(EffectType.TRANSFORM.rawValue)
        let fingerNode : Finger = CCBReader.load(fingerFile) as! Finger
        let effectNode : CCParticleSystem = CCBReader.load(effectFile) as! CCParticleSystem
        effectNode.autoRemoveOnFinish = true
        let pt = finger.position;
        finger.removeFromParent()
        finger = fingerNode
        finger.position = pt
        finger.type = type;
        effectNode.position = pt
        self.addChild(finger)
        self.addChild(effectNode)
        
    }
    func onFinishedFinger(){
        self.transformFinger(FingerType.Default)
        self.unschedule(#selector(self.onFinishedFinger))
        
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (self.paused == true)
        {
            return
        }
        //finger.physicsBody.sensor = false
        finger.position = touch.locationInNode(self)
        self.touched = true;
  
    }
    
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (self.paused == true)
        {
            return
        }
        
//        
//        if ( StaticData.sharedInstance.touches > 100 )
//        {
//            finger.scale = 1
//            
//        }else{
//            finger.scale =  Float(StaticData.sharedInstance.touches / 100)
//        }
        
        finger.position = touch.locationInNode(self)
        self.touched = true;
        StaticData.sharedInstance.touches -= 1 ;

        
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (self.paused == true)
        {
            return
        }
        finger.physicsBody.sensor = true
        self.touched = false;
        
    }
    
    func goNextLevel(){

        self.unschedule(#selector(shootElements))
        StaticData.sharedInstance.points += 1 ;
        let _animation:Animations = CCBReader.load("Animations") as! Animations;
        _animation.setMessage("Wave \(level)");
        
        self.parent.addChild(_animation);
        
        _animation.runAnimation();
        
        let blockAnimation :Animations = _animation;
        OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.WAVEUP.rawValue))
        _animation.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
        _animation.position.y += CCDirector.sharedDirector().viewSize().height - 530
        _animation.animationManager.setCompletedAnimationCallbackBlock { (sender:AnyObject!) in
            blockAnimation.removeFromParent();
            //StaticData.sharedInstance.lives = 100;
            self.start()
        }
        
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
                index = 0;
            }
            
            
            
            let type:String = ElementsTypes[index];
            let blaster : Blaster = CCBReader.load(StaticData.getObjectFile(type)) as! Blaster;
            
            blaster.name = type;
            
            rotationRadians = CC_DEGREES_TO_RADIANS(180);
            
            blaster.position = CGPointMake(CGFloat(self.randomNumberBetween(60, max:Int(CCDirector.sharedDirector().viewSize().width - 60))), 500);
            
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