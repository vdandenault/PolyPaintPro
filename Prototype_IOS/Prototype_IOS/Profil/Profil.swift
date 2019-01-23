//
//  Profil.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-04.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import Alamofire
import Lottie

class Profil: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profilPictureImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var animationView: LOTAnimationView!
    
    var images:[Image] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.isHidden = true
        nameTextField.text = User.shared.name
        emailTextField.text = User.shared.email
        usernameTextField.text = User.shared.username
        profilPictureImage.image = User.shared.profilPicture
        self.addGrestures()
        self.startAnimation()
        self.getAllImagesFromServercompletion(){ (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            else {
                self.setUpGalelerie()
            }
        }
    }
    
    func setUpGalelerie() {
        if let layout = imagesCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        self.imagesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
    }
    
    func addGrestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        leftSwipe.direction = .left
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            self.performSegue(withIdentifier: "toHomeFP", sender: self)
        }
        if (sender.direction == .left) {
            self.performSegue(withIdentifier: "toHomeFP", sender: self)
        }
    }
    
    func changeProfilPicture() {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.profilPictureImage.image = image
            User.shared.setProfilPicture(image: image)
        }
    }
    //Mark : -Animation
    func startAnimation() {
        animationView.isHidden = false
        animationView.setAnimation(named: "material_loader")
        animationView.loopAnimation = true
        animationView.play()
    }
    func stopAnimation() {
        animationView.stop()
        animationView.loopAnimation = false
        animationView.isHidden = true
    }
    
    // MARK: - Navigation
    @IBAction func plusButtonTapped(_ sender: Any) {
        self.changeProfilPicture()
    }
    
    func getAllImagesFromServercompletion(completion: @escaping (Error?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/images"
        urlComponents.query = "author=" + User.shared.id
        guard let url = urlComponents.url
            else {
                print("Could not create URL from components")
                return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": User.shared.token,
            ]
        
        //REQUEST CREATION
        Alamofire.request(url,
                          headers: headers)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while getting response")
                    Alert.showBasic(title: "Error", message: "Error in getting images, please try check your internet conection", vc: self)
                    return
                }
                guard let value = response.result.value as? [String: Any]
                    else {
                        print("ERROR IN RESPONSE")
                        return
                }
                guard let success = value["success"] as? Bool else {
                    Alert.showBasic(title: "ERROR", message: "Error in getting images, please try check your internet conection", vc: self)
                    return
                }
                guard let jsonArray = value["images"] as? NSArray else {
                    print("Error in jsonArray")
                    Alert.showBasic(title: "ERROR", message: "Error in getting images, please try check your internet conection", vc: self)
                    return
                }
                if (success) {
                    for jsonImage in jsonArray {
                        var newImage = Image.init()
                        var idImage: String = ""
                        if let image = jsonImage as? [String:Any]
                        {
                            if let id = image["_id"] as? String {
                                idImage = id
                            }
                            if let metadata = image["metadata"] as? [String:Any] {
                                var author: String = ""; var name: String = ""; var protection: Bool = false; var password: String = ""; var pngImage = UIImage(); var tags = [String](); var isBlurred:Bool = false; var Private:Bool = false; var username: String = "";
                                if let authorD = metadata["author"] as? String {
                                    author = authorD
                                }
                                if let nameD = metadata["name"] as? String {
                                    name = nameD
                                }
                                if let usernameD = metadata["username"] as? String {
                                    username = usernameD
                                }
                                if let protectionD = metadata["protection"] as? Bool {
                                    protection = protectionD
                                }
                                if let passwordD = metadata["password"] as? String {
                                    password = passwordD
                                }
                                if let privateD = metadata["isPrivate"] as? Bool {
                                    Private = privateD
                                }
                                if let isBlurredD = metadata["isBlurred"] as? Bool {
                                    isBlurred = isBlurredD
                                }
                                if let pngImageD = metadata["pngImage"] as? String {
                                    let dataDecoded:NSData = NSData(base64Encoded: pngImageD, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                    pngImage = UIImage(data: dataDecoded as Data)!
                                }
                                if let tagsD = metadata["tags"] as? [String] {
                                    for tag in tagsD {
                                        tags.append(tag)
                                    }
                                }
                                let metadata = MetaData.init(author: author, name: name, protection: protection, password: password, tags: tags, pngImage: pngImage, isBlurred: isBlurred, Private: Private, username: username, id: idImage)
                                newImage.metaData = metadata
                            }
                        }
                        self.images.append(newImage)
                    }
                }
                completion(nil)
        }
        self.stopAnimation()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImagePreviewFP" {
            if let imagePreviewVC = segue.destination as? ImagePreview {
                imagePreviewVC.image = (sender as? Image)!
                imagePreviewVC.sourceSegue = "Profil"
            }
        }
    }
}

extension Profil: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let image = images[indexPath.item].metaData.pngImage
        let height = image.size.height
        
        return height
    }
    
}

extension Profil: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = images[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCell
        cell.setCell(imageName: image.metaData.name, UIImage: image.metaData.pngImage, blure: false, imageAuthor: image.metaData.author)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.item]
        performSegue(withIdentifier: "toImagePreviewFP", sender: image)
        return
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.imagesCollectionView.reloadData()
    }
}

