//
//  ViewController.swift
//  Lab3
//
//  Created by Zhengran Jiang on 10/4/21.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    @IBOutlet weak var pastStep: UILabel!
    //yesterday step label
    @IBOutlet weak var currStep: UILabel!
    //today's step label
    @IBOutlet weak var highScore: UILabel!
    //high score label
    @IBOutlet weak var currScore: UILabel!
    //current score label
    
    
    @IBOutlet weak var startGame: UIButton!
    
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    var pastStepNum = 0; //yesterday's step
    var currStepNum = 0; //today's step
    var highScoreNum = 0; //high score
    var currScoreNum = 0; //current score
    var currentAction = "Other"; //current action
    
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
        
        startActivityMonitoring()
        startPedometerMonitoring()
        getYesterdaysSteps()
        
    }
    


    
    
    @IBAction func start(_ sender: UIButton) {
        if(startGame.titleLabel?.text == "Start"){
            startGame.setTitle("Restart", for: .normal)
        }
        else{
            startGame.setTitle("Start", for: .normal)
        }
    }
    

     // MARK: ======Motion Methods======
     func startActivityMonitoring(){
         // if active, let's start processing
         if CMMotionActivityManager.isActivityAvailable(){
             // assign updates to the main queue for activity
             self.activityManager.startActivityUpdates(to: OperationQueue.main)
             {(activity:CMMotionActivity?)->Void in
                 if let unwrappedActivity = activity {
                                         
                     //print(unwrappedActivity.description)
                     if(unwrappedActivity.walking){
                         print("Walking")
                         self.currentAction = "Walking";
                     }
                     else if(unwrappedActivity.running){
                         print("Running")
                         self.currentAction = "Running";
                     }
                     else if(unwrappedActivity.stationary){
                         print("Stationary")
                         self.currentAction = "Stationary";
                     }else if(unwrappedActivity.automotive || unwrappedActivity.cycling){
                         print("You should not be playing this game.")
                         self.currentAction = "Other";
                     }else{
                         print("Unknown")
                         self.currentAction = "Unknown";
                     }
                 }
             }
         }
         
     }
    
    func startPedometerMonitoring(){
        // check if pedometer is okay to use
        
        let date = Calendar.current.startOfDay(for: Date())
        print("Start of today:")
        print(date)
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: date)
            {(pedData:CMPedometerData?, error:Error?)->Void in
                if let data = pedData {
                    
                    // display the output directly on the phone
                    DispatchQueue.main.async {
                        self.currStep.text = "Today's steps:\n\(data.numberOfSteps.floatValue)"
                    }
                }
            }
        }
    }
    
    func getYesterdaysSteps(){
        
        let startOfDay = Calendar.current.startOfDay(for: Date().dayBefore)
        let endOfDay = Calendar.current.startOfDay(for: Date())-1
        print("Start of yesterday:")
        print(startOfDay)
        print("End of yesterday:")
        print(endOfDay)
        
        
        // check if pedometer is okay to use
        if CMPedometer.isStepCountingAvailable(){
            pedometer.queryPedometerData(from: startOfDay, to: endOfDay)
            {(pedData:CMPedometerData?, error:Error?)->Void in
                if let data = pedData {

                    // display the output directly on the phone
                    DispatchQueue.main.async {
                        self.pastStep.text = "Yesterday's steps:\n\(data.numberOfSteps.floatValue)"
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
    
    public var removeTimeStamp : Date? {
           guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return nil
           }
           return date
       }
}
