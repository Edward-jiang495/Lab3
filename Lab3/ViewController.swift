//
//  ViewController.swift
//  Lab3
//
//  Created by Zhengran Jiang on 10/4/21.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    var pastStepNum = 0;
    //yesterday's step
    var currStepNum = 0;
    //today's step
    var highScoreNum = 0;
    //high score
    var currScoreNum = 0;
    //current score
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pastStepNum = 0
        currStepNum = 0
        highScoreNum = 0
        currScoreNum = 0
        pastStep.text = "Yesterday's Step \n \(pastStepNum)"
        currStep.text = "Today's Step \n \(currStepNum)"
        highScore.text = "High Score \n \(highScoreNum)"
        currScore.text = "Current Score \n \(currScoreNum)"
        var scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
//
        
        
    }
    

    @IBOutlet weak var pastStep: UILabel!
    //yesterday step label
    @IBOutlet weak var currStep: UILabel!
    //today's step label
    @IBOutlet weak var highScore: UILabel!
    //high score label
    @IBOutlet weak var currScore: UILabel!
    //current score label
    
    
    @IBOutlet weak var startGame: UIButton!
    
    
    @IBAction func start(_ sender: UIButton) {
        if(startGame.titleLabel?.text == "Start"){
            startGame.setTitle("Restart", for: .normal)
        }
        else{
            startGame.setTitle("Start", for: .normal)
        }
    }
    

}

