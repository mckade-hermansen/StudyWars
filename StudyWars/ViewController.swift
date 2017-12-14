//
//  ViewController.swift
//  StudyWars
//
//  Created by Mckade Hermansen on 3/20/17.
//  Copyright © 2017 Mckade Hermansen. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn

class ViewController: UIViewController {
    
    let getUserByIdURL = "http://study-wars.herokuapp.com/getUserById"
    var profilePicURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/plus.login","https://www.googleapis.com/auth/plus.me"]
        
        if let currentToken = AccessToken.current {
            
            print("logged in with facebook")
            print("*** ID ***")
            let userId = currentToken.userId ?? "no id"
            print(userId)
            getUsersData(id: userId, protocolName: "facebook_id")
        }
        
//        else if GIDSignIn.sharedInstance().hasAuthInKeychain() {//google sign in persisting bug
//            
//            //GIDSignIn.sharedInstance().signInSilently()
//            print(GIDSignIn.sharedInstance().currentUser)
//            GIDSignIn.sharedInstance().signOut()
////            let userID = GIDSignIn.sharedInstance().currentUser.userID
////            getUsersData(id: userID!, protocolName: "google_id")
//            
//        }
        
        else {
            
            let loginButton = LoginButton(readPermissions: [ .publicProfile ])
            loginButton.delegate = self
            loginButton.center = view.center
            view.addSubview(loginButton)
            let googleLogin = GIDSignInButton()
            googleLogin.center = CGPoint(x: 187, y: 383)
            view.addSubview(googleLogin)
        }
    }
    
    func loadHomePage(json: [String: Any]) {
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "home") as? UITabBarController else {
            print("=== failed to load viewcontroller ===")
            return
        }
        let profile = viewController.viewControllers?[0] as? UINavigationController
        let profileVC = profile?.viewControllers.first as? Profile
        let home = viewController.viewControllers?[1] as? UINavigationController
        let homeVC = home?.viewControllers.first as? Home
        let groups = viewController.viewControllers?[2] as? UINavigationController
        let groupsVC = groups?.viewControllers.first as? Groups
        guard let displayName = json["username"] as? String,
            let avatarurl = json["avatarurl"] as? String,
            let user_id = json["user_id"] as? Int else {
            print("could not find username or avatarurl or user_id")
            return
        }
        profileVC?.usernameText = displayName
        homeVC?.usernameText = displayName
        profileVC?.avatarurlText = avatarurl
        homeVC?.avatarurlText = avatarurl
        profileVC?.user_id = user_id
        groupsVC?.userID = user_id
        homeVC?.user_id = user_id
        
        DispatchQueue.main.async {
            viewController.selectedIndex = 1
        }
        present(viewController, animated: true)
    }
    
    func getUsersData(id: String, protocolName: String){
        
        let json: [String: Any] = ["id": id, "protocol": protocolName]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: getUserByIdURL)
        print(url!)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error")
                print(error?.localizedDescription ?? "No data")
                return
            }
            print("data \(data)")
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            print("response json \(responseJSON)")
            if let responseJSON = responseJSON as? [String: Any] {
                self.loadHomePage(json: responseJSON)
            }
        }
        
        task.resume()
        
    }
    
}



extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        getUsersData(id: user.userID, protocolName: "google_id")
    }
}

extension ViewController: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult){
        print("*** id ****")
        let userId = AccessToken.current?.userId
        getUsersData(id: userId!, protocolName: "facebook_id")
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton){
        print("facebook logout")
    }
}



