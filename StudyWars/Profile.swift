//
//  Profile.swift
//  StudyWars
//
//  Created by Mckade Hermansen on 3/26/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import FacebookLogin

class Profile: UIViewController {
    
    @IBAction func settings(_ sender: UIButton) {
        performSegue(withIdentifier: "settings", sender: nil)
    }
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var wins: UILabel!
    @IBOutlet weak var loses: UILabel!
    @IBOutlet weak var ratio: UILabel!
    @IBOutlet weak var gamesPlayed: UILabel!
    @IBOutlet weak var numberOfGroups: UILabel!
    var winText = ""
    
    let getStatsURL = "https://study-wars.herokuapp.com/getStatistics"
    var usernameText = ""
    var avatarurlText = ""
    var user_id = -1
    @IBAction func signOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "login") else {
            print("=== failed to load viewcontroller ===")
            return
        }
        FacebookLogin.LoginManager().logOut()
        
        present(viewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = usernameText
        print(usernameText)
        requestImage(urlString: avatarurlText)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                    self.loses.text = String(describing: responseJSON["losses"]!)
                    self.gamesPlayed.text = String(describing: responseJSON["gamesplayed"]!)
                }
            }
            else {
                print("responseJSON error")
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

