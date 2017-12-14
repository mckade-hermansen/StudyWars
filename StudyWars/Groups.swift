//
//  Groups.swift
//  StudyWars
//
//  Created by Student on 4/11/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation
import UIKit

class Group {
    
    var group_id = -1
    var name = ""
    var owner_id = -1
    var pass = ""
    
    init(json: [String: Any]){
        
        guard let group_id = json["group_id"] as? Int,
            let name = json["name"] as? String,
            let owner_id = json["owner_id"] as? Int,
            let pass = json["pass"] as? String else {
                return
        }
        
        self.group_id = group_id
        self.name = name
        self.owner_id = owner_id
        self.pass = pass
    }
}

class Groups: UIViewController {
    
    @IBAction func findGroup(_ sender: UIButton) {
        performSegue(withIdentifier: "findGroups", sender: nil)
    }
    
    @IBOutlet weak var groupsTable: UITableView!
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    var userID = -1
    var curGroupID = -1
    let getGroupsURL = "https://study-wars.herokuapp.com/getUserGroups"
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getGroups(id: userID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quizzesSegue" {
            guard let VC = segue.destination as? Quizzes else {
                return
            }
            VC.group_id = curGroupID
            VC.user_id = userID
        }
        if segue.identifier == "findGroups" {
            guard let vc = segue.destination as? findGroups else {
                return
            }
            vc.user_id = userID
        }
    }
    
    func getGroups(id: Int) {
        
        print(id)
        let json: [String: Any] = ["id": id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getGroupsURL)
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
                if responseJSON.count == self.groups.count {
                    return
                }
                self.groups.removeAll()
                for item in responseJSON {
                    self.groups.append(Group(json: item))
                }
                DispatchQueue.main.async {
                    self.groupsTable.reloadData()
                }
                
            }
            else {
                if let responseJSON = responseJSON as? [String: Any] {
                    self.groups.append(Group(json: responseJSON))
                    DispatchQueue.main.async {
                            self.groupsTable.reloadData()
                    }
                }
            }
        }
        
        task.resume()
    }
}

extension Groups: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count \(groups.count)")
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = groups[indexPath.row].name
        print("cell")
        return cell
    }
}

extension Groups: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curGroupID = groups[indexPath.row].group_id
        performSegue(withIdentifier: "quizzesSegue", sender: nil)
    }
}
