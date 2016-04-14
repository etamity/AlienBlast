//
//  Power.swift
//  AlienBlastSwift
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation
class Power: Blaster {
    override func didLoadFromCCB() {
        super.didLoadFromCCB()
        self.physicsBody.collisionType = "power";
    }
    
}