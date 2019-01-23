//
//  SignIn.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-09.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import Alamofire
import Lottie

class SignIn: UIViewController, GIDSignInUIDelegate,  FBSDKLoginButtonDelegate, GIDSignInDelegate {
   
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            User.shared.id = user.userID
            User.shared.token = user.authentication.idToken
            User.shared.name = user.profile.name
            User.shared.email = user.profile.email
            self.postSocialLogin(provider: "google"){ (error) in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
                else if (self.success == true) {
                    User.shared.getUserInformation(){ error in
                        if let error = error {
                            fatalError(error.localizedDescription)
                        }
                        else {
                            Socket.shared.start()
                            self.performSegue(withIdentifier: "toHome", sender: self)
                        }
                    }
                }
            }
        }
        else {
             print(error.localizedDescription)
        }
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error == nil) {
            self.getFacebookUserInfo()
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        User.shared.resetUser()
    }
    
    var posts = [SignIn]()
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var success = false
    @IBOutlet weak var animationView: LOTAnimationView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        animationView.isHidden = true
        logInButtonFB.delegate = self
        logInButtonFB.readPermissions = ["public_profile", "email"]
    }
    
    
    //MARK: - UI elements
    @IBOutlet weak var signInButtonG: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var logInButtonFB: FBSDKLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func signInTapped(_ sender: Any) {
        if (FBSDKAccessToken.current() != nil) {
        }
            
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            
        }
        else {
            User.shared.email = emailTextField.text!
            User.shared.password = passWordTextField.text!
            //                do {
            //                    try checkLogIn()
            //                }
            //                catch LogInError.incompleteForm{
            //                    Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields", vc: self)
            //                }
            //                catch LogInError.incorrectPassWordLength {
            //                    Alert.showBasic(title: "Password too short", message: "Your password must be at least 8 caracthers long", vc: self)
            //                }
            //                catch LogInError.invalidEmail {
            //                    Alert.showBasic(title: "Invalid Email", message: "Please fill in a valid email adress", vc: self)
            //                }
            //                catch {
            //                    Alert.showBasic(title: "LogIn Error", message: "There was an error in when attempting to login ", vc: self)
            //                }
            let signInUser = SignInPost.init(usernameOrEmail: User.shared.email, password: User.shared.password)
            self.postToServer(signInUser: signInUser){ error in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
                else if (self.success == true){
                    User.shared.getUserInformation(){ error in
                        if let error = error {
                            fatalError(error.localizedDescription)
                        }
                        else {
                            self.stopAnimation()
                            Socket.shared.start()
                            self.performSegue(withIdentifier: "toHome", sender: self)
                        }
                    }
                }
                else {
                    Alert.showBasic(title: "Error", message: "Error in the log in method, please try again", vc: self)
                    self.stopAnimation()
                }
            }
        }
    }
    
    
    @IBAction func goFacebookTapped(_ sender: Any) {
        self.postSocialLogin(provider: "facebook"){ error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            else if (self.success == true){
                User.shared.getUserInformation(){ error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    else {
                        Socket.shared.start()
                        self.performSegue(withIdentifier: "toHome", sender: self)
                    }
                }
            }
            else {
                Alert.showBasic(title: "Error", message: "Error in the log in method, please try again", vc: self)
            }
        }
    }
    
    
    func checkLogIn() throws {
        if ((User.shared.email.isEmpty) || (User.shared.password.isEmpty)) {
            throw LogInError.incompleteForm
        }
        if (!(User.shared.email.isValidEmail)) {
            throw LogInError.invalidEmail
        }
        if ((User.shared.password.count) < 0) {
            throw LogInError.incorrectPassWordLength
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHome" {
            if let homeVC = segue.destination as? Home {
                homeVC.firstHome = true
            }
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        
        self.emailTextField.text = ""
        self.passWordTextField.text = ""
        User.shared.resetUser()
        self.performSegue(withIdentifier: "backLogINFSI", sender: self)
    }
    
    // MARK: - Animation
    
    func startAnimation() {
        animationView.isHidden = false
        animationView.setAnimation(named: "material_loader")
        animationView.loopAnimation = true
        animationView.play()
    }
    func stopAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.animationView.stop()
            self.animationView.loopAnimation = false
            self.animationView.isHidden = true
        }
    }
    
    
    //MARK: -HTTP REQUEST TO SERVER-
    
    
    func postToServer(signInUser:SignInPost, completion:@escaping (Error?) -> Void) {
        self.startAnimation()
        //URL CREATION
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/login"
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        var message = ""
        //REQUEST CREATION
        Alamofire.request(url,
                          method: .post,
                          parameters: ["usernameOrEmail": signInUser.usernameOrEmail, "password": signInUser.password])
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    Alert.showBasic(title: "Error", message: "Error loging in, please check your internet conection", vc: self)
                    self.stopAnimation()
                    return
                }
                
                guard let value = response.result.value as? [String: Any]  else
                {
                    print("Error in response")
                    self.stopAnimation()
                    return
                }
                if let messageFS = value["message"] as? String {
                    message = messageFS
                }
                if let success = value["success"] as? Bool {
                    self.success = success
                    if(!success) {
                        Alert.showBasic(title: "Error", message: message, vc: self)
                    }
                }
                if let tokenServer = value["token"] as? String {
                    User.shared.token = tokenServer
                }
                completion(nil)
        }
    }
    
    func postSocialLogin(provider: String, completion:@escaping (Error?) -> Void) {
        //URL CREATION
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/socialLoginIos"
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        var message = ""
        
        //REQUEST CREATION
        Alamofire.request(url,
                          method: .post,
                          parameters: ["email": User.shared.email, "id": User.shared.socialID, "name": User.shared.name, "provider": provider, "token": User.shared.token])
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    Alert.showBasic(title: "Error", message: "Error in social login, please check your internet conection", vc: self)
                    return
                }
                
                guard let value = response.result.value as? [String: Any]  else
                {
                    print("Error in response")
                    return
                }
                if let messageFS = value["message"] as? String {
                    message = messageFS
                }
                if let success = value["success"] as? Bool {
                    self.success = success
                    if(!success) {
                        Alert.showBasic(title: "Error", message: message, vc: self)
                    }
                }
                if let token = value["token"] as? String  {
                    if (self.success) {
                        User.shared.token = token
                    }
                }
            completion(nil)
        }
    }
    
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.current() != nil)
        {
            User.shared.token = FBSDKAccessToken.current().tokenString
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                guard let data = result as? [String : AnyObject] else {
                    Alert.showBasic(title: "Error", message: "Error in the Facebook LogIn process, please check your internet and try again", vc: self)
                    return
                }
                
                if let name = data["name"] as? String {
                    User.shared.name = name
                }
                
                if let id = data["id"] as? String {
                    User.shared.socialID = id
                }
                
                if let email = data["email"] as? String {
                    User.shared.email = email
                }
                if (!User.shared.socialID.isEmpty) {
                    self.postSocialLogin(provider: "facebook"){ (error) in
                        if let error = error {
                            fatalError(error.localizedDescription)
                        }
                        else if (self.success == true) {
                            User.shared.getUserInformation(){ error in
                                if let error = error {
                                    fatalError(error.localizedDescription)
                                }
                                else {
                                    Socket.shared.start()
                                    self.performSegue(withIdentifier: "toHome", sender: self)
                                }
                            }
                        }
                    }
                }
            })
            connection.start()
        }
    }
}
