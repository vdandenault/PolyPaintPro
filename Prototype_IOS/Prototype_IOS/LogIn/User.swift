//
//  User.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-11.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class User {
    var username:String
    var password:String
    var token:String
    var name:String
    var email:String
    var idTokenGoogle:String
    var userIdGoogle:String
    var userIdFacebook:String
    var profilPicture: UIImage
    var wifi:Bool
    var images: [Image] = []
    var id: String
    var socialID: String
    var localShapes: [ShapeView] = []
//    var localTexts: [UITextView] = []
//    var localPictures: [UIImageView] = []
//    var localActor: [ActorView] = []
//    var localClassD: [ClassView] = []
    
    static let shared = User()
    
    init() {
        self.username = ""
        self.password = ""
        self.token = ""
        self.name = ""
        self.idTokenGoogle = ""
        self.userIdGoogle = ""
        self.userIdFacebook = ""
        self.email = ""
        self.profilPicture = #imageLiteral(resourceName: "ProfilPicture")
        self.wifi = false
        self.id = ""
        self.socialID = ""
    }
    func resetUser() {
        self.username = ""
        self.password = ""
        self.token = ""
        self.name = ""
        self.idTokenGoogle = ""
        self.userIdGoogle = ""
        self.userIdFacebook = ""
        self.email = ""
        self.wifi = false
        self.profilPicture = #imageLiteral(resourceName: "ProfilPicture")
        self.id = ""
        self.socialID = ""
        self.localShapes = []
//        self.localTexts = []
//        self.localPictures = []
//        self.localActor = []
//        self.localClassD = []
    }
    func setWifi(wifi:Bool) {
        self.wifi = wifi
    }
    func setProfilPicture(image: UIImage) {
        self.profilPicture = image
    }
    
    func offLineImage() -> Bool{
        return (!self.localShapes.isEmpty)
            //!self.localPictures.isEmpty ||  || !self.localTexts.isEmpty || !self.localActor.isEmpty || !self.localClassD.isEmpty)
    }
    
    func getUserInformation(completion:@escaping (Error?) -> Void) {
        //URL CREATION
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/profile"
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        
        let headers: HTTPHeaders = [
            "authorization": self.token,
            ]
        //REQUEST CREATION
        Alamofire.request(url,
                          headers: headers)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    return
                }
                
                guard let value = response.result.value as? [String: Any]  else
                {
                    print("Error in response")
                    return
                }
                if let jsonUser = value["user"] as? [String: Any] {
                    if let name = jsonUser["name"] as? String {
                        self.name = name
                    }
                    if let email = jsonUser["user"] as? String {
                        self.email = email
                    }
                    if let username = jsonUser["username"] as? String {
                        self.username = username
                    }
                    if let id = jsonUser["_id"] as? String {
                        self.id = id
                    }
                }
                completion(nil)
        }
    }
}
