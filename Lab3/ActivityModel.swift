//
//  ActivityModel.swift
//  Lab3
//
//  Created by Nathan Gage on 10/19/21.
//

import Foundation

class ActivityModel {
    static let shared = ActivityModel()

    // can't play game cycling/driving
    enum ValidatedActivity {
        case STANDING
        case WALKING
        case RUNNING
        case INVALID
        case UNKNOWN
    }
    
    private var currentActivity: ValidatedActivity = ValidatedActivity.INVALID {
        didSet {
            print(currentActivity)
            activityChangeCallback()
        }
    }
    
    // for setting textures
    var activityIconName: String {
        switch currentActivity
        {
        case ValidatedActivity.STANDING:
            return "standing.png"
        case ValidatedActivity.WALKING:
            return "walking.png"
        case ValidatedActivity.RUNNING:
            return "running.png"
        case ValidatedActivity.INVALID:
            return "warning.png"
        default:
            return "unknown.png"
        }
    }
    
    // callback to update icon
    var activityChangeCallback: (()->()) = {} {
        didSet {
            activityChangeCallback()
        }
    }
    
    func getCurrentActivity() -> ValidatedActivity {
        return currentActivity
    }
    
    func setCurrentActivity(activity: ValidatedActivity)
    {
        if activity != currentActivity
        {
            currentActivity = activity
        }
    }
}
