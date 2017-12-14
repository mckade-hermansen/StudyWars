//
//  Home.swift
//  StudyWars
//
//  Created by Mckade Hermansen on 3/20/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation
import UIKit

class Home: UIViewController {
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    @IBAction func newGame(_ sender: UIButton) {
        tabBarController?.selectedIndex = 2
    }
    @IBOutlet weak var gamesTable: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    var usernameText = ""
    var avatarurlText = ""
    var user_id = -1
    var games = [Game]()
    var usersTurnGames = [Game]()
    var opponentTurnGames = [Game]()
    let headers = ["Your Turn", "Opponent's Turn"]
    let getStatsURL = "http://study-wars.herokuapp.com/getStatistics"
    let getGamesURL = "http://study-wars.herokuapp.com/getGames"
    
    @IBOutlet weak var wins: UILabel!
    @IBOutlet weak var losses: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = usernameText
        requestImage(urlString: avatarurlText)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getStats(user_id: user_id)
        getGames(user_id: user_id)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func getStats(user_id: Int){
        
        let json: [String: Any] = ["id": user_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getStatsURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        print(json)
        print("task")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let responseJSON = responseJSON as? [String: Any] {
                print("***************")
                print(responseJSON)
                DispatchQueue.main.async {
                    self.wins.text = String(describing: responseJSON["wins"]!)
                    self.losses.text = String(describing: responseJSON["losses"]!)
                }
            }
            else {
                print("responseJSON error")
            }
        }
        
        task.resume()
        
    }
    
    func getGames(user_id: Int){
        
        let json: [String: Any] = ["user_id": user_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getGamesURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        print(json)
        print("task")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let responseJSON = responseJSON as? [[String: Any]] {
                print("******* Games ********")
                print(responseJSON)
                //if self.games.count != responseJSON.count {
                    self.games.removeAll()
                    self.usersTurnGames.removeAll()
                    self.opponentTurnGames.removeAll()
                //}
//                else {
//                    return
//                }
                for item in responseJSON {
                    self.games.append(Game(json: item))
                }
                for game in self.games {
                    
                    if game.turn_id == user_id {
                        self.usersTurnGames.append(game)
                    }
                    else {
                        self.opponentTurnGames.append(game)
                    }
                }
                DispatchQueue.main.async {
                    self.gamesTable.reloadData()
                }
            }
            else {
                if let responseJSON = responseJSON as? [String: Any] {
                    print("**** Games ****")
                    print(responseJSON)
                }
            }
        }
        
        task.resume()

    }
    
    func requestImage(urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                guard let data = data, error == nil else {
                    print("didn't find image")
                    return
                }
                DispatchQueue.main.async {
                    print(urlString)
                    self.profilePic.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

extension Home: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return usersTurnGames.count
        }
        else {
            return opponentTurnGames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = String(usersTurnGames[indexPath.row].game_id)
        }
        else {
            cell.textLabel?.text = String(opponentTurnGames[indexPath.row].game_id)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        return cell
    }
}

extension Home: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let VC = storyboard?.instantiateViewController(withIdentifier: "play") as? Play else {
            print("could not load view controller play")
            return
        }
        if indexPath.section == 0 {
            VC.game = usersTurnGames[indexPath.row]
        }
        else {
            return
        }
        present(VC, animated: true)
    }
}
