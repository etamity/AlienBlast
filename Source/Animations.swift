//
//  Animations.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation

class Animations: CCNode {
    var messageLabel:CCLabelTTF!;
    
    override init(){
        super.init()
    }
    func didLoadFromCCB(){
        self.stopAnimation()
    }
    func setMessage(text:String){
        messageLabel.string = text;
    }
    func runAnimation(){
        self.animationManager.runAnimationsForSequenceNamed("MessageTimeLine")
    }
    
    func stopAnimation(){
        self.animationManager.paused = true;
        self.paused = true;
    }
    
}