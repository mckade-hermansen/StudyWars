//
//  Players.swift
//  StudyWars
//
//  Created by Student on 4/17/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation
import UIKit

class Player {
    
    var user_id = -1
    var name = ""
    
    init(json: [String: Any]){
        guard let user_id = json["user_id"] as? Int,
            let name = json["username"] as? String else {
            return
        }
        self.user_id = user_id
        self.name = name
    }
}

class Players: UIViewController {
    
    var group_id = -1
    var quiz_id = -1
    var user_id = -1
    var players = [Player]()
    let findGroupsUsersURL = "https://study-wars.herokuapp.com/findGroupsUsers"
    let createGameURL = "https://study-wars.herokuapp.com/createGame"
    @IBOutlet weak var playersTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select an Opponent"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPlayers(group_id: group_id)
    }
    
    func getPlayers(group_id: Int){
        
        players.removeAll()
        let json: [String: Any] = ["group_id": group_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: findGroupsUsersURL)
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
                
                if responseJSON.count == self.players.count {
                    return
                }
                for item in self.players.count ..< responseJSON.count {
                    self.players.append(Player(json: responseJSON[item]))
                }
                DispatchQueue.main.async {
                    self.playersTable.reloadData()
                }
                
            }
            else {
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    self.players.append(Player(json: responseJSON))
                }
            }
        }
        
        task.resume()

    }
    
    func startNewGame(owner_id: Int, opp_id: Int){
        
        let json: [String: Any] = ["quiz_id": quiz_id, "owner_id": owner_id, "opponent_id": opp_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: createGameURL)
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
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                guard let game_id = responseJSON["game_id"] as? Int else {
                    print("could not get game id")
                    return
                }
                DispatchQueue.main.async {
                    self.displayGame(game: Game(json: responseJSON))
                }
                
            }
            else {
                print("no json parsed")
            }
        }
        
        task.resume()
        
    }
    
    func displayGame(game: Game?){
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "play") as? Play else {
            print("=== failed to load viewcontroller ===")
            return
        }
        
        viewController.game = game
        present(viewController, animated: true)
    }
}

extension Players: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
        cell.textLabel?.text = players[indexPath.row].name
        return cell
    }
}

extension Players: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startNewGame(owner_id: user_id, opp_id: players[indexPath.row].user_id)
    }
}


