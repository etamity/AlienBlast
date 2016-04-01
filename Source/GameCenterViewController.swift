//
//  GameCenterViewController.swift
//  AlienBlastSwift
//
//  Created by etamity on 01/04/2016.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation


class GameCenterViewController: UIViewController, EGCDelegate {
    /**
     This method is called after the view controller has loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init EGC and set delegate UIViewController
        EGC.sharedInstance(self)
        
        // Will not show automatic Game Center login page
        // EGC.showLoginPage = false
        
        // If you want see message debug
        // EGC.debugMode = true
    }
    /**
     Notifies the view controller that its view was added to a view hierarchy.
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set new view controller delegate, that's when you change UIViewController
        // If you have several UIViewController just add this in your UIViewControllers for set new Delegate
        EGC.delegate = self
    }
    
    /// ############################################################ ///
    ///        Mark: - Delegate function of EasyGameCenter           ///
    /// ############################################################ ///
    /**
     Listener Player is authentified
     Optional function
     */
    func EGCAuthentified(authentified:Bool) {
        print("Player Authentified = \(authentified)")
    }
    /**
     Listener when Achievements is in cache
     Optional function
     */
    func EGCInCache() {
        // Call when GkAchievement & GKAchievementDescription in cache
    }
    
    /// ############################################################ ///
    ///  Mark: - Delegate function of EasyGameCenter for MultiPlaye  ///
    /// ############################################################ ///
    /**
     Listener When Match Started
     Optional function
     */
    func EGCMatchStarted() {
        print("MatchStarted")
    }
    /**
     Listener When Match Recept Data
     When player send data to all player
     Optional function
     */
    func EGCMatchRecept(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String) {
        // See Packet Example in project
        let strucData =  Packet.unarchive(data)
        print("Recept From player = \(playerID)")
        print("Recept Packet.name = \(strucData.name)")
        print("Recept Packet.index = \(strucData.index)")
    }
    /**
     Listener When Match End
     Optional function
     */
    func EGCMatchEnded() {
        print("MatchEnded")
    }
    /**
     Listener When Match Cancel
     Optional function
     */
    func EGCMatchCancel() {
        print("Match cancel")
    }
}