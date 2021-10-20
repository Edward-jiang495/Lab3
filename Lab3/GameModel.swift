//
//  GameModel.swift
//  Lab3
//
//  Created by Nathan Gage on 10/19/21.
//

import Foundation

class GameModel {
    static let shared = GameModel()

    enum State {
        case IDLE
        case STARTING
        case IN_GAME
        case FINISHED
    }

    private var currentState: State = State.IDLE {
        didSet
        {
            for (_, eventListener) in gameStateListeners {
                eventListener(currentState)
            }
        }
    }

    var gameStateListeners: [String: (State) -> ()] = [:]

    var scoreListener: ((Int) -> ()) = { _ in }
    var score: Int = 0 {
        didSet
        {
            scoreListener(score)
        }
    }

    var highscoreListener: ((Int) -> ()) = { _ in }
    var highscore: Int {
        didSet
        {
            highscoreListener(highscore)
        }
    }

    init() {
        highscore = UserDefaults.standard.integer(forKey: "highscore")

        gameStateListeners["debuglog"] = { (state: State) -> () in
            print("Game State Updated: ", state)
        }

        gameStateListeners["score"] = { (state: State) -> () in
            if state == .STARTING || state == .IDLE {
                self.score = 0
            }

            if state == .FINISHED
            {
                if self.score > self.highscore
                {
                    self.highscore = self.score
                    UserDefaults.standard.set(self.highscore, forKey: "highscore")
                }
            }
        }
    }

    var timeBankSeconds: Int = 0
    var didCountdown = false
    var timerCallback: ((Int, Int) -> ()) = { _, _ in }

    func Start() {
        timeBankSeconds = 10 * Int(ActivityModel.shared.todaySteps / Float(ActivityModel.shared.goal))
        var currentTimeBank = timeBankSeconds

        currentState = .STARTING
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            print("Time Remaining: \(Int(currentTimeBank))")
            self.timerCallback(currentTimeBank, self.timeBankSeconds)

            currentTimeBank -= 1

            if currentTimeBank < 0
            {
                timer.invalidate()
                self.currentState = .FINISHED
            }
        })

        var timeDelay = 10

        let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            
            if timeDelay >= 0 && !self.didCountdown
            {
                self.timerCallback(self.timeBankSeconds + Int(Float(ActivityModel.shared.goal) * (Float(timeDelay) / 10.0)), Int(ActivityModel.shared.goal))
            }

            timeDelay -= 1

            if timeDelay < 0 
            {
                timer.invalidate()
                self.didCountdown = true
                self.currentState = .IN_GAME
                self.timerCallback(self.timeBankSeconds, self.timeBankSeconds)
            }
        })
    }

    func getState() -> GameModel.State {
        return currentState
    }

    func setState(state: State) {
        if state != currentState
        {
            currentState = state
        }
    }
}
