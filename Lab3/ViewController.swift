//
//  ViewController.swift
//  Lab3
//
//  Created by Zhengran Jiang on 10/4/21.
//

import UIKit
import SpriteKit
import CoreMotion

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

    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()

    var pastStepNum = 0; //yesterday's step
    var currStepNum = 0; //today's step
    var highScoreNum = 0; //high score
    var currScoreNum = 0; //current score

    override func viewDidLoad() {
        super.viewDidLoad()
        pastStepNum = 0
        currStepNum = 0
        highScoreNum = 0
        currScoreNum = 0
        todaysValLabel.text = "\(Int(pastStepNum))"
        yesterdaysValLabel.text = "\(Int(currStepNum))"
        print(self.view.frame.width)
        print(self.view.frame.height)
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
//

        startActivityMonitoring()
        startPedometerMonitoring()
        getYesterdaysSteps()

    }





    @IBAction func start(_ sender: UIButton) {
       
        print((startGame.titleLabel?.text)! == "Start")
        if((startGame.titleLabel?.text)! == "Start") {
            print("in restart")
            startGame.setTitle("Restart", for: .normal)
//            startGame.titleLabel?.font =  UIFont(name: "Digital-7", size: 35)
        }
        else {
            startGame.setTitle("Start", for: .normal)
//            startGame.titleLabel?.font =  UIFont(name: "Digital-7", size: 35)
            
        }
    }


    // MARK: ======Motion Methods======
    func startActivityMonitoring() {
        // if active, let's start processing
        if CMMotionActivityManager.isActivityAvailable() {
            // assign updates to the main queue for activity
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            { (activity: CMMotionActivity?) -> Void in
                if let unwrappedActivity = activity {
                    if(unwrappedActivity.walking) {
                        print("Walking")
                        ActivityModel.shared.currentActivity = ActivityModel.ValidatedActivity.WALKING
                    }
                    else if(unwrappedActivity.running) {
                        print("Running")
                        ActivityModel.shared.currentActivity = ActivityModel.ValidatedActivity.RUNNING
                    }
                    else if(unwrappedActivity.stationary) {
                        print("Stationary")
                        ActivityModel.shared.currentActivity = ActivityModel.ValidatedActivity.STANDING
                    } else if(unwrappedActivity.automotive || unwrappedActivity.cycling) {
                        print("You should not be playing this game.")
                        ActivityModel.shared.currentActivity = ActivityModel.ValidatedActivity.INVALID
                    } else {
                        print("Unknown")
                        ActivityModel.shared.currentActivity = ActivityModel.ValidatedActivity.UNKNOWN
                    }
                }
            }
        }

    }

    func startPedometerMonitoring() {
        // check if pedometer is okay to use

        let date = Calendar.current.startOfDay(for: Date())
        print("Start of today:")
        print(date)
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: date)
            { (pedData: CMPedometerData?, error: Error?) -> Void in
                if let data = pedData {

                    // display the output directly on the phone
                    DispatchQueue.main.async {
                        self.todaysValLabel.text = "\(Int(data.numberOfSteps.floatValue))"
                    }
                }
            }
        }
    }

    @IBAction func sliderChanged(_ sender: Any) {
        let updatedGoal = Int(round(goalSlider.value))
        goalTextField.text = "\(updatedGoal)"
        UserDefaults.standard.set(updatedGoal,forKey: "stepGoal")
    }
    
    @IBAction func textFieldChange(_ sender: Any) {
        if let input = Int(goalTextField.text!) {
            print(input)
            UserDefaults.standard.set(input,forKey: "stepGoal")
        }
        
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        goalTextField.resignFirstResponder();
    }
    
    
    func getYesterdaysSteps() {

        let startOfDay = Calendar.current.startOfDay(for: Date().dayBefore)
        let endOfDay = Calendar.current.startOfDay(for: Date()) - 1
        print("Start of yesterday:")
        print(startOfDay)
        print("End of yesterday:")
        print(endOfDay)


        // check if pedometer is okay to use
        if CMPedometer.isStepCountingAvailable() {
            pedometer.queryPedometerData(from: startOfDay, to: endOfDay)
            { (pedData: CMPedometerData?, error: Error?) -> Void in
                if let data = pedData {

                    // display the output directly on the phone
                    DispatchQueue.main.async {
                        self.yesterdaysValLabel.text = "\(Int(data.numberOfSteps.floatValue))"
                    }
                }
            }
        }
    }


}

extension Date {

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
