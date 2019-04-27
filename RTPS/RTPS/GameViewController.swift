//
//  GameViewController.swift
//  RTPS
//
//  Created by Srom Michael J. on 1/31/19.
//  Copyright © 2019 SSG corps. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'LevelScene.sks'
            let scene = LevelScene(view.frame.size)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
            
                // Present the scene
                view.presentScene(scene)
            
            //Creates score label
            //let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            //label.center = CGPoint(x: 75, y: 40)
            //label.textAlignment = .center
            //label.text = "Score: "
            //label.textColor = UIColor.white
            //self.view.addSubview(label)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.landscape
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
