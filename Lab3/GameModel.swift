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
    var highscore: Int
    var score: Int = 0

    init() {
        highscore = UserDefaults.standard.integer(forKey: "highscore")
        
        gameStateListeners["debuglog"] = { (state: State) -> () in
            print("Game State Updated: ", state)
        }

        gameStateListeners["score"] = { (state: State) -> () in
            if state == .FINISHED
            {
                self.score = 0
            }
        }
    }

    func Start() {
        currentState = State.IN_GAME
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
