//
//  findGroups.swift
//  StudyWars
//
//  Created by Student on 4/11/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation
import UIKit

class findGroup {
    
    var group_id = -1
    var name = ""
    var owner_id = -1
    var pass = ""
    
    init(json: [String: Any]){
        
        print(json)
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

class findGroups: UIViewController {
    
    
    @IBOutlet weak var findGroupTable: UITableView!
    
    let getGroupURL = "https://study-wars.herokuapp.com/findGroup"
    let joinGroupURL = "https://study-wars.herokuapp.com/joinGroup"
    var searchResult = ""
    var groupArray = [findGroup]()
    var user_id = -1
    
    func displayGroups(name: String){
    
        if name == "" {
            print("no group")
            return
        }
        let json: [String: Any] = ["name": name]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getGroupURL)
        var groupRequest = URLRequest(url: url!)
        groupRequest.httpMethod = "POST"
        groupRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        groupRequest.httpBody = jsonData
        print("task")
        let task = URLSession.shared.dataTask(with: groupRequest) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
            print("data \(data)")
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let responseJSON = responseJSON as? [[String: Any]] {
                for item in responseJSON {
                    self.groupArray.append(findGroup(json: item))
                }
                DispatchQueue.main.async {
                    self.findGroupTable.reloadData()
                }
            }
            else {
                if let responseJSON = responseJSON as? [String: Any] {
                    self.groupArray.append(findGroup(json: responseJSON))
                    DispatchQueue.main.async {
                            self.findGroupTable.reloadData()
                    }
                }
            }
        }
        
        task.resume()
    }
    
}

extension findGroups: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        displayGroups(name: (searchBar.text)!)
    }
}

extension findGroups: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let group_id = groupArray[indexPath.row].group_id
        let json: [String: Any] = ["groupID": group_id, "userID": user_id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: joinGroupURL)
        var groupRequest = URLRequest(url: url!)
        groupRequest.httpMethod = "POST"
        groupRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        groupRequest.httpBody = jsonData
        print("task")
        let task = URLSession.shared.dataTask(with: groupRequest) { data, response, error in
            guard let data = data, error == nil  else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
        }
        task.resume()

        performSegue(withIdentifier: "groupsUnwind", sender: nil)
    }
}

extension findGroups: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "findGroupCell", for: indexPath)
        cell.textLabel?.text = groupArray[indexPath.row].name
        return cell
    }
}
