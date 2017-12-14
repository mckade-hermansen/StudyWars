//
//  Quizzes.swift
//  StudyWars
//
//  Created by Student on 4/12/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation

class Quiz {
    
    var owner = -1
    var quiz_id = -1
    var name = ""
    var quizGroupID = -1
    
    init(json: [String: Any]){
        guard let quizGroupID = json["group_id"] as? Int,
            let quiz_id = json["quiz_id"] as? Int,
            let name = json["name"] as? String else {
                print("no json in init")
                return
        }
        self.quiz_id = quiz_id
        self.name = name
        self.quizGroupID = quizGroupID
    }
}

class Quizzes: UIViewController {
    
    var group_id = -1
    var user_id = -1
    let getQuizzesURL = "https://study-wars.herokuapp.com/findQuizzes"
    var quizzes = [Quiz]()
    var curIndex = -1
    
    @IBOutlet weak var quizzesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select a Quiz"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getQuizzes(group_id: group_id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playersSegue" {
            guard let VC = segue.destination as? Players else {
                return
            }
            VC.group_id = group_id
            VC.quiz_id = quizzes[curIndex].quiz_id
            VC.user_id = user_id
        }
    }
    
    func getQuizzes(group_id: Int){
        
        let json: [String: Any] = ["group_id": group_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getQuizzesURL)
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
                
                if responseJSON.count == self.quizzes.count {
                    return
                }
                self.quizzes.removeAll()
                for item in responseJSON {
                    self.quizzes.append(Quiz(json: item))
                }
                DispatchQueue.main.async {
                    self.quizzesTable.reloadData()
                }
                
            }
            else {
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    self.quizzes.append(Quiz(json: responseJSON))
                }
            }
        }
        
        task.resume()

    }
}

extension Quizzes: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curIndex = indexPath.row
        performSegue(withIdentifier: "playersSegue", sender: nil)
    }
}

extension Quizzes: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quizCell", for: indexPath)
        cell.textLabel?.text = String(quizzes[indexPath.row].name)
        return cell
    }
}
