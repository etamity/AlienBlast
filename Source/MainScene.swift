import Foundation

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
        //self.loadLevel("LevelKing");
    }

    func loadLevelFromValue(level:Int){
        let generator:LevelGenerator = currnetLevel as! LevelGenerator;
        generator.nextLevel();
        self.paused = false;
        levelReady = true;
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
    
    func goNextLevel(){
        self.paused = true;
        
        StaticData.sharedInstance.points += 1 ;
        let _animation:Animations = CCBReader.load("Animations") as! Animations;
        let generator:LevelGenerator = currnetLevel as! LevelGenerator;
        var level: Int = generator.level;
        _animation.setMessage("Goto Level \(level+1)");
        
        self.addChild(_animation);
        
        _animation.runAnimation();
        
        let mainSence : MainScene = self;
        let blockAnimation :Animations = _animation;
        
        
//        _animation.animationManager setCompletedAnimationCallbackBlock:^(id sender) {
//        [blockAnimation removeFromParent];
//        [mainSence loadLevelFromValue:(int)levelGenerator.level];
//        [INNUserInterFace setLives:100];
//        [[INNUserInterFace sharedScene] updateLevel:(int)levelGenerator.level];
//        }];
    }
}
