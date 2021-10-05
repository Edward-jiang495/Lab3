//
//  ModuleAViewController.swift
//  Lab3
//
//  Created by Zhengran Jiang on 10/4/21.
//

import UIKit
import CoreMotion

class ModuleAViewController: UIViewController {

    let activityManager = CMMotionActivityManager()
    
    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBOutlet weak var currActivity: UILabel!
    
    @IBOutlet weak var currStep: UILabel!
    @IBOutlet weak var pastStep: UILabel!
    
    func startActivityMonitoring(){
        // if active, let's start processing
        if CMMotionActivityManager.isActivityAvailable(){
            // assign updates to the main queue for activity
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                if let unwrappedActivity = activity {
                                        
                    print(unwrappedActivity.description)
                    if(unwrappedActivity.walking){
                        self.currActivity.text = "Walking, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    else if(unwrappedActivity.running){
                        self.currActivity.text = "Running, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    else if(unwrappedActivity.cycling){
                        self.currActivity.text = "Cycling, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    else if(unwrappedActivity.stationary){
                        self.currActivity.text = "Still, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    else if(unwrappedActivity.automotive){
                        self.currActivity.text = "Driving, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    else{
                        self.currActivity.text = "Unknown"
                    }
                }
            }
        }
        
    }
    
    func startPedometerMonitoring(){
        // check if pedometer is okay to use
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date())
            {(pedData:CMPedometerData?, error:Error?)->Void in
                if let data = pedData {
                    // display the output directly on the phone
                    DispatchQueue.main.async {
                        self.currStep.text = "Today's Step: \(data.numberOfSteps.floatValue)"
                    }
                }
            }
        }
    }
    /*
     
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
