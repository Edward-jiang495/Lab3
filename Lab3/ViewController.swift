//
//  ViewController.swift
//  Lab3
//
//  Created by Zhengran Jiang on 10/4/21.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    @IBOutlet weak var pastStep: UILabel!
    //yesterday step label
    @IBOutlet weak var currStep: UILabel!

    @IBOutlet weak var yesterdaysValLabel: UILabel!
    @IBOutlet weak var todaysValLabel: UILabel!
    //current score label
    @IBOutlet weak var goalLabel: UILabel!

    @IBOutlet weak var scoreBoard: UIStackView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalSlider: UISlider!

    @IBOutlet weak var startGame: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        yesterdaysValLabel.text = " "
        todaysValLabel.text = " "
        
        // listen to step updates
        ActivityModel.shared.todayStepListener = { steps -> () in
            DispatchQueue.main.async {
                print("UPDATE")
                self.todaysValLabel.text = "\(Int(steps))"
            }
        }
        
        ActivityModel.shared.yesterdayStepListener = { steps -> () in
            DispatchQueue.main.async {
                print("UPDATE")
                self.yesterdaysValLabel.text = "\(Int(steps))"
            }
        }
        
        ActivityModel.shared.updateSteps()
        ActivityModel.shared.startActivityMonitoring()

        // listen to gamestate updates
        GameModel.shared.gameStateListeners["startbutton"] = UpdateStartButton
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        self.scoreBoard.translatesAutoresizingMaskIntoConstraints = true
        self.scoreBoard.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.frame.height * (1.0 - 0.7) - 40)

//        startGame.titleLabel?.font =  UIFont(name: "Digital-7", size: 35)

        let stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
        goalSlider.value = Float(stepGoal)
        goalTextField.text = "\(stepGoal)"

        var scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView

        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    // MARK: Button Handling
    
    @IBAction func start(_ sender: UIButton) {
        GameModel.shared.Start()
    }

    func UpdateStartButton(state: GameModel.State) {
        DispatchQueue.main.async {

            self.startGame.isEnabled = state != GameModel.State.IN_GAME

            let attribTitle = self.startGame.attributedTitle(for: .normal)

            switch state {

            case GameModel.State.IN_GAME:
                attribTitle?.setValue(" ", forKey: "string")

            case GameModel.State.IDLE:
                attribTitle?.setValue("Start Game", forKey: "string")

            case GameModel.State.FINISHED:
                attribTitle?.setValue("Restart", forKey: "string")

            }

            self.startGame.setAttributedTitle(attribTitle, for: .normal)
        }
    }

    
    // MARK: Field Handling
    
    @IBAction func sliderChanged(_ sender: Any) {
        let updatedGoal = Int(round(goalSlider.value))
        
        goalTextField.text = "\(updatedGoal)"
        
        UserDefaults.standard.set(updatedGoal, forKey: "stepGoal")
        ActivityModel.shared.goal = updatedGoal
    }

    @IBAction func textFieldChange(_ sender: Any) {
        if let input = Int(goalTextField.text!) {
            UserDefaults.standard.set(input, forKey: "stepGoal")
            ActivityModel.shared.goal = input
        }

    }

    @IBAction func screenTapped(_ sender: Any) {
        goalTextField.resignFirstResponder()
    }
}
