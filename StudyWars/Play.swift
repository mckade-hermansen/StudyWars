//
//  Play.swift
//  StudyWars
//
//  Created by Student on 4/18/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation
import UIKit

class Play: UIViewController {
    
    let getQuestionURL = "https://study-wars.herokuapp.com/getQuestion"
    let deleteGameURL = "https://study-wars.herokuapp.com/deleteGame"
    let updateGameURL = "https://study-wars.herokuapp.com/updateGame"
    var questionText = "what is the best black bear in the northern region of the upmost rocky mountain area without trees"
    var correctButton = -1
    var cur_id = -1
    var cur_index = -1
    var answer = ""
    var answerIndex = -1
    var wrongAnswers = [String]()
    var buttons = [UIButton]()
    var game: Game?
    var isOwner = false;
    
    @IBOutlet weak var question: UITextView!
    @IBOutlet weak var button1Display: UIButton!
    @IBOutlet weak var button2Display: UIButton!
    @IBOutlet weak var button3Display: UIButton!
    @IBOutlet weak var button4Display: UIButton!
    @IBAction func button1(_ sender: UIButton) {
        checkAnswer(buttonIndex: 0)
    }
    @IBAction func button2(_ sender: UIButton) {
        checkAnswer(buttonIndex: 1)
    }
    @IBAction func button3(_ sender: UIButton) {
        checkAnswer(buttonIndex: 2)
    }
    @IBAction func button4(_ sender: UIButton) {
        checkAnswer(buttonIndex: 3)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hue: 0.5833, saturation: 0.25, brightness: 0.42, alpha: 1.0)
        cur_id = (game?.turn_id)!
        if cur_id == (game?.owner_id)! {
            isOwner = true
            cur_index = (game?.owner_quest)!
        }
        else {
            cur_index = (game?.opponent_quest)!
        }
        getQuestion(question_id: (game?.question_list[cur_index])!)
        buttons.append(button1Display)
        buttons.append(button2Display)
        buttons.append(button3Display)
        buttons.append(button4Display)
    }
    
    func getQuestion(question_id: Int){
        
        wrongAnswers.removeAll()
        let json: [String: Any] = ["questionID": question_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getQuestionURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        print("task")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
            print("data \(data)")
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let responseJSON = responseJSON as? [[String: Any]] {
                print(responseJSON)
                guard let question = responseJSON[0]["question"] as? String,
                    let answer = responseJSON[0]["answer"] as? String,
                    let WA1 = responseJSON[0]["wronganswer1"] as? String,
                    let WA2 = responseJSON[0]["wronganswer2"] as? String,
                    let WA3 = responseJSON[0]["wronganswer3"] as? String else {
                    print("didn't get question")
                    return
                }
                self.questionText = question
                self.answer = answer
                self.wrongAnswers.append(WA1)
                self.wrongAnswers.append(WA2)
                self.wrongAnswers.append(WA3)
                
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }
            else {
                print("json did not work")
                if let responseJSON = responseJSON as? [[String: Any]] {
                        print(responseJSON)
                }
            }
        }
        
        task.resume()
    }
    
    func updateUI(){
        
        answerIndex = Int(arc4random_uniform(4))
        for i in 0 ... 3 {
            if i != answerIndex{
                buttons[i].setTitle(wrongAnswers.removeLast(), for: .normal)
            }
            else {
                buttons[i].setTitle(answer, for: .normal)
            }
        }
        
        print(answerIndex)
        question.text = questionText
        
    }
    
    func checkAnswer(buttonIndex: Int){
        
        if buttonIndex == answerIndex {
            answeredCorrectly(buttonIndex: buttonIndex)
        }
        else {
            answeredIncorrectly(buttonIndex: buttonIndex)
        }
    }
    
    func answeredCorrectly(buttonIndex: Int){
        
        buttons[buttonIndex].backgroundColor = UIColor(hue: 0.2889, saturation: 1, brightness: 1, alpha: 1.0)
        var userQuest = -1
        
        if isOwner {
            game?.owner_quest += 1
            game?.owner_score += 1
            userQuest = (game?.owner_quest)!
        }
        else {
            game?.opponent_quest += 1
            game?.opponent_score += 1
            userQuest = (game?.opponent_quest)!
        }
        
        if userQuest >= (game?.question_list.count)! {
            gameOver()
            return
        }
        
        let alertController = UIAlertController(title: "You Answered Correctly!", message: "Message", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            DispatchQueue.main.async {
                self.buttons[buttonIndex].backgroundColor = UIColor.white
                self.getQuestion(question_id: (self.game?.question_list[userQuest])!)
            }
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func answeredIncorrectly(buttonIndex: Int){
        
        buttons[buttonIndex].backgroundColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 1.0)
        buttons[answerIndex].backgroundColor = UIColor(hue: 0.2889, saturation: 1, brightness: 1, alpha: 1.0)
        var userQuest = -1
        
        
        if isOwner {
            game?.owner_quest += 1
            game?.turn_id = (game?.opponent_id)!
            userQuest = (game?.owner_quest)!
            
        }
        else {
            game?.opponent_quest += 1
            game?.turn_id = (game?.owner_id)!
            userQuest = (game?.opponent_quest)!
        }
        
        if userQuest >= (game?.question_list.count)! {
            gameOver()
            return
        }
        updateGame()
        
        let alertController = UIAlertController(title: "You Answered Incorrectly", message: "You'll get them next time", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func gameOver() {
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
        }
        
        var alertController = UIAlertController(title: "You Won the Game", message: "You truely are a StudyWars master", preferredStyle: .alert)
        
        if isOwner {
            
            if (game?.owner_quest)! >= (game?.question_list.count)! {
                
                if (game?.opponent_quest)! >= (game?.question_list.count)! {
                    
                    if (game?.owner_score)! > (game?.opponent_score)! {
                        
                        alertController = UIAlertController(title: "You Won the Game", message: "You truely are a StudyWars master", preferredStyle: .alert)
                        deleteGame(game_id: (game?.game_id)!)
                    }
                    else {
                        
                        alertController = UIAlertController(title: "You Lost the Game", message: "sorry", preferredStyle: .alert)
                        deleteGame(game_id: (game?.game_id)!)
                    }
                }
                else {
                    alertController = UIAlertController(title: "Waiting for opponent", message: "My money is on you (;", preferredStyle: .alert)
                    game?.turn_id = (game?.opponent_id)!
                    updateGame()
                }
            }
        }
        else {
            if (game?.opponent_quest)! >= (game?.question_list.count)! {
                
                if (game?.owner_quest)! >= (game?.question_list.count)! {
                    
                    if (game?.opponent_score)! >= (game?.owner_score)! {
                        
                        alertController = UIAlertController(title: "You Won the Game", message: "You truely are a StudyWars master", preferredStyle: .alert)
                        deleteGame(game_id: (game?.game_id)!)
                    }
                    else {
                        
                        alertController = UIAlertController(title: "You Lost the Game", message: "sorry", preferredStyle: .alert)
                        deleteGame(game_id: (game?.game_id)!)
                    }
                }
                else {
                    
                    alertController = UIAlertController(title: "Waiting for opponent", message: "My money is on you (;", preferredStyle: .alert)
                    game?.turn_id = (game?.owner_id)!
                    updateGame()
                }
            }
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func updateGame(){
        
        let json: [String: Any] = ["game_id": (game?.game_id)!, "owner_quest": (game?.owner_quest)!, "opponent_quest": (game?.opponent_quest)!, "owner_score": (game?.owner_score)!, "opponent_score": (game?.opponent_score)!, "turn_id": (game?.turn_id)!]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: updateGameURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        print("task")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
        }
        task.resume()
    }
    
    func deleteGame(game_id: Int){
        
        let json: [String: Any] = ["game_id": game_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: deleteGameURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        print("task")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
        }
        task.resume()
    }
}
