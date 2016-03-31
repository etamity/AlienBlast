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
        
        
    }

    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, shape nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {
        if let nA = nodeA {
            let item : Blaster = nA as! Blaster
            item.blast()
        }
        if let nB = nodeB {
            nB.removeFromParentAndCleanup(true)
        }

   
        return true
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, wall nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {
        if let nB = nodeB {
            nB.removeFromParentAndCleanup(true)
        }
        return true
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, finger nodeA: CCNode!, bullet nodeB: CCNode!) -> Bool {
        if let nB = nodeB {
            nB.removeFromParentAndCleanup(true)
        }
        return true
    }
    
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, shape nodeA: CCNode!, finger nodeB: CCNode!) -> Bool {
        if let nA = nodeA {
            let item : Blaster = nA as! Blaster
            item.blast()
        }
        return true
    }
    
    

}
