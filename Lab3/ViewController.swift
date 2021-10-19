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

        ActivityModel.shared.updateSteps()
        ActivityModel.shared.startActivityMonitoring()

        // listen to gamestate updates
        GameModel.shared.gameStateListeners["startbutton"] = UpdateStartButton
        GameModel.shared.gameStateListeners["scorelabels"] = UpdateLabels
        GameModel.shared.setState(state: .IDLE)
        
        UpdateLabels()
        UpdateStartButton()
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        self.scoreBoard.translatesAutoresizingMaskIntoConstraints = true
        self.scoreBoard.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.frame.height * (1.0 - 0.7) - 40)

        let stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
        goalSlider.value = Float(stepGoal)
        goalTextField.text = "\(stepGoal)"

        var scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView

        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    // MARK: UI Update Handling

    @IBAction func start(_ sender: UIButton) {
        GameModel.shared.Start()
    }

    func UpdateStartButton(state: GameModel.State = GameModel.shared.getState()) {
        DispatchQueue.main.async {
            if Int(ActivityModel.shared.todaySteps) >= ActivityModel.shared.goal
            {
                self.startGame.isEnabled = state != .IN_GAME

                switch state {

                case .IN_GAME:
                    self.startGame.setTitle(" ", for: .normal)

                case .IDLE:
                    self.startGame.setTitle("Start Game", for: .normal)

                case .FINISHED:
                    self.startGame.setTitle("Restart", for: .normal)
                }
            } else {
                self.startGame.isEnabled = false

                self.startGame.setTitle(" ", for: .normal)
            }

            self.startGame.titleLabel?.font = UIFont(name: "Digital-7", size: 35)
        }
    }

    func UpdateLabels(state: GameModel.State = GameModel.shared.getState()) {
        DispatchQueue.main.async {
            
            if state == .IDLE {
                self.todaysValLabel.text = "\(Int(ActivityModel.shared.todaySteps))"
                self.yesterdaysValLabel.text = "\(Int(ActivityModel.shared.yesterdaySteps))"

                self.currStep.text = "Today"
                self.pastStep.text = "Yesterday"

                // listen to step updates
                ActivityModel.shared.todayStepListener = { steps -> () in
                    DispatchQueue.main.async {
                        self.todaysValLabel.text = "\(Int(steps))"
                        self.UpdateStartButton()
                    }
                }

                ActivityModel.shared.yesterdayStepListener = { steps -> () in
                    DispatchQueue.main.async {
                        self.yesterdaysValLabel.text = "\(Int(steps))"
                    }
                }

            } else {
                self.todaysValLabel.text = "\(Int(GameModel.shared.score))"
                self.yesterdaysValLabel.text = "\(Int(GameModel.shared.highscore))"

                self.currStep.text = "Score"
                self.pastStep.text = "High score"

                GameModel.shared.scoreListener = { (score: Int) -> () in
                    self.currStep.text = "\(Int(score))"
                }
            }
        }
    }

    // MARK: Field Handling

    @IBAction func sliderChanged(_ sender: Any) {
        let updatedGoal = Int(round(goalSlider.value))

        goalTextField.text = "\(updatedGoal)"

        UserDefaults.standard.set(updatedGoal, forKey: "stepGoal")
        ActivityModel.shared.goal = updatedGoal

        UpdateStartButton()
    }

    @IBAction func textFieldChange(_ sender: Any) {
        if let input = Int(goalTextField.text!) {
            UserDefaults.standard.set(input, forKey: "stepGoal")
            ActivityModel.shared.goal = input

            UpdateStartButton()
        }
    }

    @IBAction func screenTapped(_ sender: Any) {
        goalTextField.resignFirstResponder()
    }
}
