//
//  MainScene.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation
import GoogleMobileAds;
import GameKit

class MainScene: CCNode,CCPhysicsCollisionDelegate {

    weak var _physicsNode:CCPhysicsNode! = nil;
    weak var levelNode:CCNode! = nil;
    weak var inGameMenu:INGameMenu! = nil;
    weak var userInterface:UserInterFace! = nil;
    weak var levelGenerator:LevelGenerator! = nil;
    weak var gameMenu:GameMenu! = nil ;
    var currnetLevel : CCNode! = nil;
    func didLoadFromCCB(){
        self.userInteractionEnabled = true;
        
        // set physics node collision delegate
        _physicsNode.collisionDelegate = self;
        
        
        // set up google admob sdk
        CommonBanner.regitserProvider(CommonBannerProvideriAd.classForCoder(), withPriority: CommonBannerPriority.Low, requestParams: nil)
        
        CommonBanner.regitserProvider(CommonBannerProviderGAd.classForCoder(), withPriority: CommonBannerPriority.High,
                                      requestParams: [keyAdUnitID: "ca-app-pub-7660105848150286/2679623255",
                                                    keyTestDevices : []])
        CCDirector.sharedDirector().canDisplayAds = true;
        CommonBanner.bannerControllerWithRootViewController(CCDirector.sharedDirector())
        CommonBanner.startManaging()
    
        
        
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.BLAST.rawValue))
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.HIT.rawValue))
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.WAVEUP.rawValue))
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.LASER.rawValue))
        
        
        // Global event handling
        StaticData.sharedInstance.events.listenTo(GameEvent.GAME_START.rawValue) {

            StaticData.sharedInstance.reset()
            self.gameAction(GameEvent.GAME_START)
        }
        
        StaticData.sharedInstance.events.listenTo(GameEvent.GAME_MAINMENU.rawValue) {
            self.gameAction(GameEvent.GAME_MAINMENU)
        }
        
        StaticData.sharedInstance.events.listenTo(GameEvent.GAME_CONTINUE.rawValue) {
            self.gameAction(GameEvent.GAME_CONTINUE)
        }
        StaticData.sharedInstance.events.listenTo(GameEvent.GAME_TOPSCORE.rawValue) {
            self.gameAction(GameEvent.GAME_TOPSCORE)
        }
        StaticData.sharedInstance.events.listenTo(GameEvent.GAME_OVER.rawValue) {
            self.saveHighscore(StaticData.sharedInstance.points)
        }
        
        StaticData.sharedInstance.events.listenTo(GameEvent.GAME_OVER.rawValue) {
            self.saveHighscore(StaticData.sharedInstance.points)
        }
        
        StaticData.sharedInstance.events.listenTo(GameEvent.UPDATE_LEVEL.rawValue) {(info:Any?) in
            if let data = info as? Int {
                if StaticData.sharedInstance.achievements.contains(data){
                   
                    self.saveAchievement(data);
                }
            }
        }
        
        

        self.updateLayout()
        showGameMenu()
        let vc : UIViewController = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        EGC.sharedInstance(vc);
    }

    func gameAction(event:GameEvent){
        CCDirector.sharedDirector().resume()
        switch event {
        case .GAME_TOPSCORE:
            self.showLeaderBoard()
            break
        case .GAME_MAINMENU:
            showGameMenu()
            break
        case .GAME_START:
            gameStart();
            break
        case .GAME_CONTINUE:
            gameStart();
            break
        default:
            gameStart();
            break
        }
        
    }
    
    // Show game center leader board
    func showLeaderBoard(){
        EGC.showGameCenterLeaderboard(leaderboardIdentifier: "AlienBlastScore")
        
    }
    
    // Show game center score board
    func saveHighscore(score:Int){
        EGC.reportScoreLeaderboard(leaderboardIdentifier: "AlienBlastScore",score: score)
    }
    func saveAchievement(level:Int){
         print("New achievement: achievement\(level)")
        EGC.showCustomBanner(title: "Congrats!", description: "You have achieved \(level) waves!")

        EGC.reportAchievement(progress: 100.00, achievementIdentifier: "achievement\(level)", showBannnerIfCompleted: true)
    }
    // Get game center all achievements
    func getAllAchievements(){
        EGC.getGKAllAchievementDescription {
            (arrayGKAD) -> Void in
            if let arrayAchievementDescription = arrayGKAD {
                for achievement in arrayAchievementDescription  {
                    print("\n[Easy Game Center] ID : \(achievement.identifier)\n")
                    print("\n[Easy Game Center] Title : \(achievement.title)\n")
                    print("\n[Easy Game Center] Achieved Description : \(achievement.achievedDescription)\n")
                    print("\n[Easy Game Center] Unachieved Description : \(achievement.unachievedDescription)\n")
                }
            }
        }
    }
    
    // Show game menu
    func showGameMenu(){
        levelNode.removeAllChildrenWithCleanup(true)
        gameMenu = CCBReader.load("GameMenu") as! GameMenu;
        gameMenu.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
        gameMenu.position.y = (CCDirector.sharedDirector().viewSize().height - 480) / 2
        levelNode.addChild(gameMenu)
    }
     // update layout
    override func viewDidResizeTo(newViewSize: CGSize) {
        super.viewDidResizeTo(newViewSize)
        self.updateLayout()
    }
    
    // Re-layout the game ui and graphics
    func updateLayout(){
        if (self.gameMenu != nil){
            gameMenu.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
            gameMenu.position.y = (CCDirector.sharedDirector().viewSize().height - 480) / 2
        }
        
    }
    
    // Start game
    func gameStart(){
        self.levelNode.removeAllChildrenWithCleanup(true)
        self.loadLevel("LevelKing")
    }
    // Load level by level name
    func loadLevel(levelName:String){
        
        let newLevelName:String = "Levels/\(levelName)";
        
        currnetLevel = CCBReader.load(newLevelName);
        
        
        levelNode.addChild(currnetLevel);
        
        
        let userInterface :UserInterFace = CCBReader.load("UserInterface") as! UserInterFace
        userInterface.position = CGPointMake(0, 0);
        levelNode.addChild(userInterface)
        
    }

    // Collision handling
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, shape nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {
        if let nA = nodeA {
            let item : Blaster = nA as! Blaster
            item.blast()
        }
        if let nB = nodeB {
            nB.removeFromParentAndCleanup(true)
        }

   
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, wall nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {
        if let nB = nodeB {
            nB.removeFromParentAndCleanup(true)
        }
        return true
    }
        
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, bullet nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {

        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, bullet nodeA: CCNode!, finger nodeB: CCNode!) -> Bool {
        return false
    }
    
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, shape nodeA: CCNode!, finger nodeB: CCNode!) -> Bool {

        if let nA = nodeA as? Blaster{
            
            if let nB = nodeB as? Finger{
                if (nA.subType != ""){
                    print(nA.subType)
                    nB.blastTarget(nA.subType,node: self.currnetLevel)
                }
            }
            
            nA.blast();
            
        }
        return false
    }
    
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, power nodeA: CCNode!, finger nodeB: CCNode!) -> Bool {
        
        if let nA = nodeA as? Power{
            let type : FingerType = FingerType(rawValue: nA.subType)!
            
            if let nB = nodeB as? Finger{
                print(type,nB.type)
                if (nB.type == FingerType.Default)
                {
                    StaticData.sharedInstance.events.trigger(GameEvent.UPDATE_FINGER.rawValue, information: nA.subType)
                }
            }
            

            nA.blast();
            
        }
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, power nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {
        
        if let nA = nodeA as? Power{
            
            nA.blast();
            
        }
        if let nB = nodeB {
            nB.removeFromParentAndCleanup(true)
        }
        return false
    }
    


}
