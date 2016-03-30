//
//  INNAnimations.swift
//  AlientBlast
//
//  Created by etamity on 29/03/2016.
//  Copyright © 2016 Apportable. All rights reserved.
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