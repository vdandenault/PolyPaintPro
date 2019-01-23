//
//  ImagePreview.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-09.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Alamofire

class ImagePreview: UIViewController {
    
    @IBOutlet weak var privateSlider: UISwitch!
    @IBOutlet weak var protectionSlider: UISwitch!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var imageName: UILabel!
    @IBOutlet weak var Author: UILabel!
    @IBOutlet weak var passwordView: RoundUIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var confirmDeleteView: RoundUIView!
    
    
    var image:Image!
    var isProtected:Bool!
    var isPrivate:Bool!
    let blackView = UIView()
    var sourceSegue: String!
    var toPolyPaintPro:Bool = false
    
    override func viewDidLoad() {
        Image.image = self.image.metaData.pngImage
        Image.hero.id = self.image.metaData.author
        addPanGesture()
        Image.contentMode = .scaleAspectFit
        imageName.text = self.image.metaData.name
        Author.text = "Author: " + self.image.metaData.username
        isProtected = self.image.metaData.protection
        isPrivate = self.image.metaData.Private
        self.passwordView.isHidden = true
        self.confirmDeleteView.isHidden = true
        protectionSlider.isOn = isProtected
        privateSlider.isOn = isPrivate
        self.setUPImagePreseneter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    func setUPImagePreseneter() {
        if (self.sourceSegue == "Profil") {
            protectionSlider.isUserInteractionEnabled = true
            privateSlider.isUserInteractionEnabled = true
        }
        else {
            protectionSlider.isUserInteractionEnabled = false
            privateSlider.isUserInteractionEnabled = false
             self.deleteButton.isHidden = true
        }
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.passwordView.isHidden = true
            self.blackView.alpha = 0
            self.passwordTextField.text = ""
        }
        if (protectionSlider.isOn && !toPolyPaintPro) {
            protectionSlider.isOn = false
        }
        isProtected = protectionSlider.isOn
    }
    
    @IBAction func enterTapped(_ sender: Any) {
        if (toPolyPaintPro) {
            if (!(passwordTextField.text?.isEmpty)!) {
                if (passwordTextField.text == image.metaData.password) {
                    UIView.animate(withDuration: 0.5) {
                        self.passwordView.isHidden = true
                        self.blackView.alpha = 0
                        self.passwordTextField.text = ""
                    }
                    performSegue(withIdentifier: "toPPPFIP", sender: self)
                }
                else{
                    Alert.showBasic(title: "Wrong Password !", message: "Wrong password", vc: self)
                }
            }
            else {
                Alert.showBasic(title: "Empty Name", message: "Please enter a password", vc: self)
            }
        }
        else {
            //SetNewPassWord
            if (!(passwordTextField.text?.isEmpty)!) {
                image.metaData.password = passwordTextField.text!
                self.postImageToServer(isPrivate: self.isPrivate, isProtected: self.isProtected, newPassword: image.metaData.password) { error in
                    if let error = error {
                        Alert.showBasic(title: "Error", message: "You cannot edit this image. PLease check your internet connection", vc: self)
                        fatalError(error.localizedDescription)
                    }
                }
                UIView.animate(withDuration: 0.5) {
                    self.passwordView.isHidden = true
                    self.blackView.alpha = 0
                    self.passwordTextField.text = ""
                }
            }
            else {
                Alert.showBasic(title: "Empty Name", message: "Please enter a password", vc: self)
            }
        }
    }
    
    @IBAction func polyPaintProTapped(_ sender: Any) {
        self.toPolyPaintPro = true
        if (isProtected) {
            Alert.showBasic(title: "Stop !", message: "Image is protected. Please enter the password", vc: self)
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.view.addSubview(blackView)
            self.blackView.frame = self.view.frame
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                self.view.addSubview(self.passwordView)
                self.passwordView.isHidden = false
            })
        }
        else {
            performSegue(withIdentifier: "toPPPFIP", sender: self)
        }
    }
    
    @IBAction func protectedSlidderTapped(_ sender: Any) {
        self.isProtected = protectionSlider.isOn
        //toBeProtected
        if (self.isProtected) {
            setPasswordforImage()
            self.toPolyPaintPro = false
        }
        else {
            //toUnProtect
            self.postImageToServer(isPrivate: self.isPrivate, isProtected: self.isProtected, newPassword: "") { error in
                if let error = error {
                    Alert.showBasic(title: "Error", message: "You cannot edit this image. PLease check your internet connection", vc: self)
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    func setPasswordforImage() {
        self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(blackView)
        self.blackView.frame = self.view.frame
        self.blackView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 1
            self.view.addSubview(self.passwordView)
            self.passwordView.isHidden = false
        })
    }
    @IBAction func privateSliderTapped(_ sender: Any) {
        self.isPrivate  = privateSlider.isOn
        self.postImageToServer(isPrivate: self.isPrivate, isProtected: self.isProtected, newPassword: image.metaData.password) { error in
            if let error = error {
                Alert.showBasic(title: "Error", message: "You cannot edit this image. Please check your internet connection", vc: self)
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ImagePreview.handlePan(sender:)))
        Image.addGestureRecognizer(pan)
        Image.isUserInteractionEnabled = true
        
    }
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        guard self.view != nil else {return}
        let translation = sender.translation(in: view)
        let progress = (translation.y / 2) / view.bounds.height
        switch sender.state {
        case .began:
            hero.dismissViewController()
        case .changed:
            let translation = sender.translation(in: nil)
            let progress =     translation.y / 2 / view.bounds.height
            Hero.shared.update(progress)
            let currentPos = CGPoint(x: translation.x + Image.center.x, y: translation.y + Image.center.y)
            Hero.shared.apply(modifiers: [.position(currentPos)], to: Image)
        default:
            if (progress + sender.velocity(in: nil).y / view.bounds.height > 0.2) {
                Hero.shared.finish()
            }
            else {
                Hero.shared.cancel()
            }
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(blackView)
        self.blackView.frame = self.view.frame
        self.blackView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 1
            self.view.addSubview(self.confirmDeleteView)
            self.confirmDeleteView.isHidden = false
        })
        
    }
    
    @IBAction func yesTapped(_ sender: Any) {
        self.deleteImage(){ error in
            if let error = error {
                Alert.showBasic(title: "Error", message: "You cannot edit this image. Please check your internet connection", vc: self)
                fatalError(error.localizedDescription)
            }
            else {
                UIView.animate(withDuration: 1) {
                    self.confirmDeleteView.isHidden = true
                    self.blackView.alpha = 0
                }
                self.performSegue(withIdentifier: "toProfilFIP", sender: self)
            }
        }
    }
    
    @IBAction func noTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.confirmDeleteView.isHidden = true
            self.blackView.alpha = 0
        }
    }
    
    
    //MARK : - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPPPFIP" {
            Socket.shared.editorJoin(sessionId: image.metaData.id)
            if let PPPVC = segue.destination as? PolyPaintPro {
                PPPVC.isPrivate = self.image.metaData.Private
                PPPVC.isProctected = self.image.metaData.protection
                PPPVC.isNSFW = self.image.metaData.isBlurred
                PPPVC.password = self.image.metaData.password
            }
            
        }
    }
    
    @objc func keybordWillChange(notification: Notification) {
        guard let keybordRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if (notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame) {
             view.frame.origin.y = -keybordRect.height
        }
        else {
            view.frame.origin.y = 0
        }
    }
}

extension ImagePreview {
    func postImageToServer(isPrivate: Bool, isProtected:Bool,newPassword:String, completion: @escaping (Error?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/image/" + image.metaData.id
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        let parameters = ["isPrivate": isPrivate, "protection": isProtected, "password": newPassword] as [String : Any]
        let headers: HTTPHeaders = [ "Authorization": User.shared.token]
        //REQUEST CREATION
        Alamofire.request(url,
                          method: .put,
                          parameters: parameters,
                          headers: headers)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    Alert.showBasic(title: "Error", message: "Error in sending image, please check your internet conection", vc: self)
                    return
                }
                guard let value = response.result.value as? [String: Any]
                    else {
                        print("ERROR IN RESPONSE")
                        return
                }
                var Message:String = ""
                if let message = value["message"] as? String {
                    Message = message
                }
                if let success = value["success"] as? Bool {
                    if (!success) {
                        Alert.showBasic(title: "Error, you can't do that !", message: Message, vc: self)
                    }
                }
        }
        completion(nil)
    }
    
    func deleteImage(completion: @escaping (Error?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/image/" + image.metaData.id
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        let headers: HTTPHeaders = [ "Authorization": User.shared.token]
        //REQUEST CREATION
        Alamofire.request(url,
                          method: .delete,
                          headers: headers)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    Alert.showBasic(title: "Error", message: "Error in sending image, please check your internet conection", vc: self)
                    return
                }
                guard let value = response.result.value as? [String: Any]
                    else {
                        print("ERROR IN RESPONSE")
                        return
                }
                var Message:String = ""
                if let message = value["message"] as? String {
                    Message = message
                }
                if let success = value["success"] as? Bool {
                    if (!success) {
                        Alert.showBasic(title: "Error, you can't do that !", message: Message, vc: self)
                    }
                }
        }
        completion(nil)
    }
}

