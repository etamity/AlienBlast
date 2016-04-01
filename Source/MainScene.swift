import Foundation
import GoogleMobileAds;
class MainScene: CCNode,CCPhysicsCollisionDelegate {

    var _physicsNode:CCPhysicsNode! = nil;
    var levelNode:CCNode! = nil;
    var inGameMenu:INGameMenu! = nil;
    var userInterface:UserInterFace! = nil;
    var levelGenerator:LevelGenerator! = nil;
    
    func didLoadFromCCB(){
        self.userInteractionEnabled = true;
        _physicsNode.collisionDelegate = self;
        

    
        CommonBanner.regitserProvider(CommonBannerProvideriAd.classForCoder(), withPriority: CommonBannerPriority.Low, requestParams: nil)
        
        CommonBanner.regitserProvider(CommonBannerProviderGAd.classForCoder(), withPriority: CommonBannerPriority.High,
                                      requestParams: [keyAdUnitID: "ca-app-pub-7660105848150286/2679623255",
                                                    keyTestDevices : []])
        CCDirector.sharedDirector().canDisplayAds = true;
        //CommonBanner.setBannerPosition(CommonBannerPosition.Top)
        CommonBanner.bannerControllerWithRootViewController(CCDirector.sharedDirector())
        CommonBanner.startManaging()
        
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.BLAST.rawValue))
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.HIT.rawValue))
        OALSimpleAudio.sharedInstance().preloadEffect(StaticData.getSoundFile(GameSoundType.WAVEUP.rawValue))
        
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
        
        showGameMenu()
        
    }

    func gameAction(event:GameEvent){
        CCDirector.sharedDirector().resume()
        switch event {
        case .GAME_TOPSCORE:
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
    
    func showGameMenu(){
        levelNode.removeAllChildren()
        let gameMenu:GameMenu! = CCBReader.load("GameMenu") as! GameMenu;
        
        gameMenu.position.x = (CCDirector.sharedDirector().viewSize().width - 320) / 2
        
        levelNode.addChild(gameMenu)
    }
    
    func gameStart(){
        self.levelNode.removeAllChildren()
        self.loadLevel("LevelKing")
    }
    
    func loadLevel(levelName:String){
        
        let newLevelName:String = "Levels/\(levelName)";
        
        let currnetLevel = CCBReader.load(newLevelName);
        
        
        levelNode.addChild(currnetLevel);
        
//        let frame:CCDrawNode = CCDrawNode();
//        if var verts : [CGPoint] = [] {
//            verts.append(ccp(currnetLevel.position.x, currnetLevel.position.y))
//            verts.append(ccp(CCDirector.sharedDirector().viewSize().width, currnetLevel.position.y))
//            verts.append(ccp(CCDirector.sharedDirector().viewSize().width, currnetLevel.contentSize.height))
//            verts.append(ccp(currnetLevel.position.x, currnetLevel.contentSize.height))
//            frame.drawPolyWithVerts(verts, count: 4, fillColor: nil, borderWidth: 2.0, borderColor: CCColor.grayColor())
//        }
//        
//        
//        levelNode.addChild(frame);
        
        
        
        let userInterface :UserInterFace = CCBReader.load("UserInterface") as! UserInterFace
        userInterface.position = CGPointMake(0, 0);
        levelNode.addChild(userInterface)
        
    }

    
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
            
            let targetName = nA.name;
            if let nB = nodeB as? Finger{
                OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.BLAST.rawValue))
                nB.blastTarget(targetName)
            
            }
            
            nA.blast();
            
        }
        return false
    }
    
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, power nodeA: CCNode!, finger nodeB: CCNode!) -> Bool {
        
        if let nA = nodeA as? Power{
            StaticData.sharedInstance.events.trigger(GameEvent.UPDATE_FINGER.rawValue, information: nA.subType)
            
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
