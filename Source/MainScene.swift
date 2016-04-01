import Foundation
import GoogleMobileAds;
class MainScene: CCNode,CCPhysicsCollisionDelegate {

    var _physicsNode:CCPhysicsNode! = nil;
    var _levelNode:CCScrollView! = nil;
    var  gameMenu:GameMenu! = nil;
    var inGameMenu:INGameMenu! = nil;
    var currnetLevel:CCNode! = nil;
    var _animation:Animations! = nil;
    var levelReady:Bool = false;
    var userInterface:UserInterFace! = nil;
    var levelGenerator:LevelGenerator! = nil;
    
    func didLoadFromCCB(){
        self.userInteractionEnabled = true;
        _physicsNode.collisionDelegate = self;
        
        levelReady = false;

    
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
    
}
