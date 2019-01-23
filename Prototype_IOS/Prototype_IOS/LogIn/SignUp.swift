//
//  SignUp.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-09.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import Alamofire
import Lottie

class SignUp: UIViewController {
    
    var succes = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: -  UI elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var animationView: LOTAnimationView!
    
    //MARK: - LogIn Functions
    
    @IBAction func loginTapped(_ sender: Any) {
        User.shared.email = emailTextField.text!
        User.shared.name = nameTextField.text!
        User.shared.username = usernameTextField.text!
        User.shared.password = passwordTextField.text!
        
        do {
            try logIn()
        }
        catch LogInError.invalidUserName{
            Alert.showBasic(title: "InvalidUserName", message: "Your username must be at least 6 caracthers long", vc: self)
            self.stopAnimation()
        }
        catch LogInError.incompleteForm{
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields", vc: self)
            self.stopAnimation()
        }
        catch LogInError.incorrectPassWordLength {
            Alert.showBasic(title: "Password too short", message: "Your password must be at least 8 caracthers long", vc: self)
            self.stopAnimation()
        }
        catch LogInError.invalidEmail {
            Alert.showBasic(title: "Invalid Email", message: "Please fill in a valid email adress", vc: self)
            self.stopAnimation()
        }
        catch {
            Alert.showBasic(title: "LogIn Error", message: "There was an error in when attempting to login ", vc: self)
            self.stopAnimation()
        }
    }
    
    func logIn() throws {
        if ((User.shared.email.isEmpty) || (User.shared.password.isEmpty) || (User.shared.name.isEmpty) || (User.shared.username.isEmpty)) {
            throw LogInError.incompleteForm
        }
        if (!(User.shared.email.isValidEmail)) {
            throw LogInError.invalidEmail
        }
        if ((User.shared.username.count) < 4) {
            throw LogInError.invalidUserName
        }
        if ((User.shared.password.count) < 8) {
            throw LogInError.incorrectPassWordLength
        }
        let signUpPost = SignUpPost(name: User.shared.name, email: User.shared.email, username: User.shared.username, password: User.shared.password)
        self.postToServer(signUpUser: signUpPost){ (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            else if (self.succes == true) {
                User.shared.getUserInformation() {(error) in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    else {
                        self.stopAnimation()
                        Socket.shared.start()
                        self.nameTextField.text = ""
                        self.emailTextField.text = ""
                        self.usernameTextField.text = ""
                        self.passwordTextField.text = ""
                        self.performSegue(withIdentifier: "toTutoriel", sender: self)
                    }
                }
            }
        }
    }
    
    
    //MARK: - HTTP POST
    
    func postToServer(signUpUser:SignUpPost,  completion:@escaping (Error?) -> Void) {
        self.startAnimation()
        //URL CREATION
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/signup"
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        let parameters: Parameters = ["name": signUpUser.name, "email": signUpUser.email, "username": signUpUser.username, "password": signUpUser.password]
        
        //REQUEST CREATION
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.httpBody)
            .validate()
            .responseJSON { response in
                var message = ""
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    Alert.showBasic(title: "Error", message: "Error signing up, please check your internet conection", vc: self)
                    self.stopAnimation()
                    return
                }
                guard let value = response.result.value as? [String: Any]
                    else {
                        print("Error in response")
                        self.stopAnimation()
                        return
                }
                if let messageFS = value["message"] as? String {
                    message = messageFS
                }
                if let succes = value["success"] as? Bool {
                    self.succes = succes
                    if(!succes) {
                        Alert.showBasic(title: "Error", message: message, vc: self)
                    }
                }
                if let tokenServer = value["token"] as? String {
                    User.shared.token = tokenServer
                }
                completion(nil)
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        self.nameTextField.text = ""
        self.emailTextField.text = ""
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
        User.shared.resetUser()
        performSegue(withIdentifier: "backToLogInFSU", sender: self)
    }
    
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
}



enum  LogInError: Error {
    case incompleteForm
    case invalidEmail
    case invalidUserName
    case incorrectPassWordLength
}
