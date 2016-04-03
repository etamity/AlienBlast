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
    weak var backgroundNode : CCNode! = nil;
    
    var previousTouchPos: CGPoint = CGPointMake(0, 0);
    
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
                
                if (staticData.achievements.contains(data)){
                    staticData.saveData()
                    self.changeBackground(data)
                }
            }
            
        }
        
        staticData.events.listenTo(GameEvent.UPDATE_FINGER.rawValue) { (info:Any?) in
            if let data = info as? String {
                let type : FingerType = FingerType(rawValue: data)!
                    self.showMessage("\(type) Power")
                    self.transformFinger(type)
                    self.schedule(#selector(self.onFinishedFinger), interval: self.finger.duringTime)
                
            }
        }
        
        
        staticData.events.listenTo(GameEvent.GAME_OVER.rawValue) {
            self.stop()
            staticData.saveData()
            let gameover : INGameMenu = CCBReader.load("InGameMenu") as! INGameMenu
            gameover.updateLevelLCD(self.level)
            gameover.updateScoreLCD(staticData.points)
            gameover.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
            gameover.position.y = (CCDirector.sharedDirector().viewSize().height - 480) / 2
            gameover.gameOverView()
            self.addChild(gameover)
         
        }
        
        staticData.events.listenTo(GameEvent.GAME_PAUSE.rawValue) {
            
            self.stop()
            
            let gamepause : INGameMenu = CCBReader.load("InGameMenu") as! INGameMenu
            gamepause.updateLevelLCD(self.level)
            gamepause.updateScoreLCD(staticData.points)
            gamepause.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
            gamepause.position.y = (CCDirector.sharedDirector().viewSize().height - 480) / 2
            gamepause.gamePauseView()
            self.addChild(gamepause)
         
        }
        
        staticData.events.listenTo(GameEvent.GAME_RESUME.rawValue) {
            self.resume();
            let rd = self.randomNumberBetween(0, max: StaticData.sharedInstance.achievements.count)
            self.changeBgMusic(StaticData.sharedInstance.achievements[rd])
            
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

    }
    
    
    func showMessage(text:String){
        let _animation:Animations = CCBReader.load("Animations") as! Animations;
        _animation.setMessage(text);
        
        self.addChild(_animation);
        
        _animation.runAnimation();
        
        OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.POWER.rawValue))
        _animation.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
        _animation.position.y += CCDirector.sharedDirector().viewSize().height - 580

        _animation.animationManager.setCompletedAnimationCallbackBlock { (sender:AnyObject!) in
            _animation.removeFromParentAndCleanup(true)
        }
        
    }
    
    func changeBgMusic(index:Int){
        switch index {
        case 20:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING1.rawValue), loop:true)
            break
        case 40:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING2.rawValue), loop:true)
            break;
        case 50:
            
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING3.rawValue), loop:true)
            break
        case 80:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING4.rawValue), loop:true)
            break
        case 100:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING.rawValue), loop:true)
            break
        default:
            OALSimpleAudio.sharedInstance().playBg(StaticData.getSoundFile(GameSoundType.GAME_PLAYING.rawValue), loop:true)
            break
        }
        
    }
    
    func changeBackground(index:Int){
        
        
        let bg = CCBReader.load("Backgrounds/Background\(index)")
        let oldbg = self.backgroundNode.children[0] as! CCNode
        if let abg = bg {
            self.backgroundNode.addChild(abg,z: -1)
        }
        let action = CCActionFadeTo.actionWithDuration(5, opacity: 0.0)
        let callback = CCActionCallBlock { 
            oldbg.removeFromParentAndCleanup(true)
            bg.zOrder = 0
        }
        
        oldbg.cascadeOpacityEnabled = true;
        
        let array = [action,callback]
        let sq = CCActionSequence.init(array: array)
        oldbg.runAction(sq as CCActionSequence)
        changeBgMusic(index);
        
        
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
            StaticData.sharedInstance.touches += 2 ;
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
        let newCountOfTime = 3 + Int(newlevel * (newlevel % 5))
        if (newCountOfTime < 8){
            self.countOfTime = newCountOfTime;
        }else{
            
            self.countOfTime = 8 ;
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
        finger.removeFromParentAndCleanup(true);
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
        StaticData.sharedInstance.events.trigger(GameEvent.RESET_DEFULAT_FINGER.rawValue)
        
        
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (self.paused == true)
        {
            return
        }
        let touchPos = touch.locationInNode(self)
        self.previousTouchPos = touchPos
        finger.position = touchPos
        self.touched = true;
  
    }
    
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (self.paused == true)
        {
            return
        }
        
        let touchPos = touch.locationInNode(self)
        if ( StaticData.sharedInstance.touches > 100 )
        {
             finger.position = touchPos
            
        }else{
            
            let moveTo = CCActionMoveToNode.actionWithSpeed(100, positionUpdateBlock: { () -> CGPoint in
                return touchPos;
            })
            self.finger.runAction(moveTo as! CCActionMoveToNode);
            

        }
        
       
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
        self.finger.stopAllActions()
        
    }
    
    func goNextLevel(){

        self.unschedule(#selector(shootElements))
        StaticData.sharedInstance.points += 1 ;
        let _animation:Animations = CCBReader.load("Animations") as! Animations;
        _animation.setMessage("Wave \(level)");
        
        self.addChild(_animation);
        
        _animation.runAnimation();
        
       OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.WAVEUP.rawValue))
        _animation.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
        _animation.position.y += CCDirector.sharedDirector().viewSize().height - 530
        _animation.animationManager.setCompletedAnimationCallbackBlock { (sender:AnyObject!) in
            _animation.removeFromParentAndCleanup(true)

            self.start()
        }
        
    }
    
    
    func shootElements(){
        let ElementsTypes = StaticData.sharedInstance.ObjectTypes;
        var rotationRadians:Float = 0;
    
        for _ in 0 ..< self.countOfTime {
            var index:Int = self.randomNumberBetween(0,max:ElementsTypes.count);
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
            
            blaster.position = CGPointMake(CGFloat(self.randomNumberBetween(60, max:Int(CCDirector.sharedDirector().viewSize().width - 60))), CCDirector.sharedDirector().viewSize().height );
            
            let directionVector : CGPoint  = ccp(CGFloat(sinf(rotationRadians)),CGFloat(cosf(rotationRadians)));
            let force:CGPoint = ccpMult(directionVector, CGFloat(self.speed + Float(self.randomNumberBetween(0, max: 500))));
            blaster.physicsBody.applyForce(force);
            self.addChild(blaster);
            
        }

    }
    
    
//    override func update(delta: CCTime) {
//        super.update(delta)
//        let rotationRadians = CC_DEGREES_TO_RADIANS(180);
//        for node in self.children{
//            if let blaster = node as? Blaster{
//                let directionVector : CGPoint  = ccp(CGFloat(sinf(rotationRadians)),CGFloat(cosf(rotationRadians)));
//                let force:CGPoint = ccpMult(directionVector, CGFloat(self.speed));
//                blaster.physicsBody.applyForce(force);
//            }
//        }
//        
//    }
    func randomNumberBetween(min:Int,max:Int) ->Int{
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
}