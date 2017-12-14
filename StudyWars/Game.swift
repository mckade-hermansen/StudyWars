//
//  Game.swift
//  StudyWars
//
//  Created by Mckade Hermansen on 4/23/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation

class Game {
    
    var game_id = -1,
    owner_id = -1,
    opponent_id = -1,
    quiz_id = -1,
    turn_id = -1,
    owner_quest = -1,
    opponent_quest = -1,
    owner_score = -1,
    opponent_score = -1,
    owner_time = -1,
    opponent_time = -1,
    question_list = [Int]()
    
    
    init(json: [String: Any]){
        guard let gameID = json["game_id"] as? Int,
        let ownerID = json["owner_id"] as? Int,
        let opponentID = json["opponent_id"] as? Int,
        let quizID = json["quiz_id"] as? Int,
        let turnID = json["turn_id"] as? Int,
        let ownerQuest = json["owner_quest"] as? Int,
        let opponentQuest = json["opponent_quest"] as? Int,
        let ownerScore = json["owner_score"] as? Int,
        let opponentScore = json["opponent_score"] as? Int,
        let questionList = json["question_list"] as? [Int]
            else {
                print("could not parse Game JSON")
                return
        }
        self.game_id = gameID
        self.owner_id = ownerID
        self.opponent_id = opponentID
        self.quiz_id = quizID
        self.turn_id = turnID
        self.owner_quest = ownerQuest
        self.opponent_quest = opponentQuest
        self.owner_score = ownerScore
        self.opponent_score = opponentScore
        self.question_list = questionList
    }
    
}
