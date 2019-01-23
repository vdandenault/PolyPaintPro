//
//  Galerie.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-04.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import Alamofire
import Lottie
import SwiftyJSON
import AVFoundation
import FBSDKLoginKit
import GoogleSignIn

class Home: UIViewController {
    
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet private var animationView: LOTAnimationView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var newWorkspaceView: RoundUIView!
    @IBOutlet weak var newWorkSpaceTextField: UITextField!
    @IBOutlet weak var logoButton: UIButton!
    
    
    
    var images: [Image] = []
    var filtered:[Image] = []
    
    let blackView = UIView()
    var firstHome:Bool = false
    let whiteView = UIView()
    let searchController = UISearchController(searchResultsController: nil)
    var audioPlayer = AVAudioPlayer()
    let welcomeUserTitle = UILabel()
    let welcomeUserBody = UILabel()
    var newWorkSpace: Workspace!
    
    let transition = CircularTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newWorkspaceView.isHidden = true
        animationView.isHidden = true
        setUpSearchBar()
        Socket.shared.socketDeleteUser = self
        User.shared.setWifi(wifi: true)
        if(self.firstHome) {
            self.welcomeUser()
            Sounds.shared.playSounds(fileName:"logInSound")
        }
        getAllImagesFromServercompletion(){ (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            else {
                self.setUpGalelerie()
            }
        }
        logoButton.layer.cornerRadius = logoButton.frame.size.width/4
    }
    
    //UI Navigation
    @IBAction func logOutButtonTapped(_ sender: Any) {
        User.shared.resetUser()
        Socket.shared.disconnect()
        self.performSegue(withIdentifier: "toLogInFH", sender: self)
        GIDSignIn.sharedInstance().disconnect()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    
    @IBAction func PPPTapped(_ sender: Any) {
        if let window = UIApplication.shared.keyWindow {
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                window.addSubview(self.newWorkspaceView)
                self.newWorkspaceView.isHidden = false
            })
        }
    }
    
    @IBAction func toChatTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toChatRoom", sender: self)
    }
    @IBAction func toProfil(_ sender: Any) {
        self.performSegue(withIdentifier: "toProfil", sender: self)
    }
    
    func setUpGalelerie() {
        if let layout = imagesCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        self.imagesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.reloadData()
    }
    
    func createEditorWorkSpace(newWorkSpaceName: String) {
        let workspace = Workspace(name: newWorkSpaceName, sessionId: "", author: User.shared.username)
        self.newWorkSpace = workspace
        Socket.shared.editorCreate(name: newWorkSpaceName)
        self.performSegue(withIdentifier: "toPPPFHV", sender: self)
    }
    
    @IBAction func newWorkspaceGoTapped(_ sender: Any) {
        if (!(newWorkSpaceTextField.text?.isEmpty)!) {
            UIView.animate(withDuration: 0.5) {
                self.newWorkspaceView.isHidden = true
                self.blackView.alpha = 0
                self.createEditorWorkSpace(newWorkSpaceName: self.newWorkSpaceTextField.text!)
            }
        }
        else {
            Alert.showBasic(title: "Empty Name", message: "Please enter a name", vc: self)
        }
    }
    
    @IBAction func newWorkSpaceExitTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.newWorkspaceView.isHidden = true
            self.blackView.alpha = 0
        }
    }
    
    //Mark: - Welcome User
    func welcomeUser() {
        self.welcomeUserTitle.font = UIFont(name: "Futura", size: 40)
        self.welcomeUserBody.font = UIFont(name: "Futura", size: 20)
        self.welcomeUserBody.numberOfLines = 0
        self.welcomeUserTitle.numberOfLines = 0
        self.welcomeUserBody.text = "New in PolyPaintPro: Cooperative Design !"
        self.welcomeUserTitle.text = ("Welcome " + User.shared.name)
        let stackView = UIStackView(arrangedSubviews: [welcomeUserTitle, welcomeUserBody])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        
        whiteView.backgroundColor = UIColor(white: 1, alpha: 1)
        whiteView.frame = view.frame
        view.addSubview(whiteView)
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -300).isActive = true
        
        whiteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapAnimations)))
        
    }
    
    @objc fileprivate func handleTapAnimations() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.welcomeUserTitle.transform = CGAffineTransform(translationX: -60, y: 0)
            
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.welcomeUserTitle.alpha = 0
                self.welcomeUserTitle.transform = self.welcomeUserTitle.transform.translatedBy(x: 0, y: -400)
            })
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.welcomeUserBody.transform = CGAffineTransform(translationX: -60, y: 0)
            
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.welcomeUserBody.alpha = 0
                self.welcomeUserBody.transform = self.welcomeUserBody.transform.translatedBy(x: 0, y: -400)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.whiteView.alpha = 0
                })
                { (_) in
                    self.whiteView.removeFromSuperview()
                    Socket.shared.setSocketOn()
                    Socket.shared.editorLogIn()
                    Socket.shared.chatLogIn()
                    if (User.shared.offLineImage()) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            let workspace = Workspace(name: "No name", sessionId: "", author: User.shared.username)
                            self.newWorkSpace = workspace
                            Socket.shared.editorCreate(name: "No name")
                            self.performSegue(withIdentifier: "toPPPFHV", sender: self)
                        }
                    }
                }
            }
        }
        self.firstHome = false
    }
    
    //Mark: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImagePreview" {
            if let imagePreviewVC = segue.destination as? ImagePreview {
                imagePreviewVC.image = (sender as? Image)!
                imagePreviewVC.sourceSegue = "Galerie"
            }
        }
        if segue.identifier == "toPPPFHV" {
            if let PPPVC = segue.destination as? PolyPaintPro {
                guard self.newWorkSpace != nil
                    else {return}
                PPPVC.workspace = self.newWorkSpace
            }
        }
        if segue.identifier == "toAbout" {
            if let AboutVC = segue.destination as? AboutViewController {
                AboutVC.transitioningDelegate = self
                AboutVC.modalPresentationStyle = .custom
            }
        }
    }
    
    //Mark : -Animation and Blure
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
    
    func doAlertForUnBlure(path: IndexPath, completion: @escaping (Error?) -> Void) {
        self.images[path.item].metaData.isBlurred = false
        Alert.showBasic(title: "NSFW", message: "You're seeing the image", vc: self)
        completion(nil)
    }
}




extension Home: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        var image:UIImage
        if (isFiltering()) {
            image = self.filtered[indexPath.item].metaData.pngImage
        }
        else {
            image = self.images[indexPath.item].metaData.pngImage
        }
        let height = image.size.height
        
        return height
    }
    
}

// MARK: -Galerie extension functions
extension Home: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filtered.count
        }
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var image:Image
        if (isFiltering()) {
            image = self.filtered[indexPath.item]
        }
        else {
            image = self.images[indexPath.item]
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCell
        cell.setCell(imageName: image.metaData.name, UIImage: image.metaData.pngImage, blure: image.metaData.isBlurred, imageAuthor: image.metaData.author)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image:Image
        if (isFiltering()) {
            image = self.filtered[indexPath.item]
        }
        else {
            image = self.images[indexPath.item]
        }
        if (image.metaData.isBlurred) {
            image.metaData.isBlurred = false
            self.doAlertForUnBlure(path: indexPath){ (error) in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
                else {
                    self.imagesCollectionView.reloadData()
                }
            }
        }
        else {
            if (isFiltering()) {
                searchController.dismiss(animated: false, completion: {
                    self.searchController.isActive = false
                    self.searchController.searchBar.text = ""
                    self.performSegue(withIdentifier: "toImagePreview", sender: image)
                    return
                })
            }
            performSegue(withIdentifier: "toImagePreview", sender: image)
            return
        }
    }
}



//Mark: - SearchResults
extension Home: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func setUpSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search in Images"
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchBarView.addSubview(searchController.searchBar)
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        searchBar.text = ""
        self.imagesCollectionView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = self.searchController.searchBar.text
        self.getSearchResuts(searchInput: searchString!) { (error) in
            if let error = error {
                Alert.showBasic(title: "Error", message: "Error in Search. ", vc: self)
                fatalError(error.localizedDescription)
            } else {
                self.imagesCollectionView.collectionViewLayout.invalidateLayout()
                self.setUpGalelerie()
                self.imagesCollectionView.setNeedsLayout()
                
            }
        }
    }
}

extension Home {
    //HTTP REQUEST
    
    func getAllImagesFromServercompletion(completion: @escaping (Error?) -> Void) {
        self.startAnimation()
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/images"
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
                    Alert.showBasic(title: "ERROR", message: "Error in getting images, please check your internet conection", vc: self)
                    return
                }
                guard let message = value["message"] as? String else {
                    Alert.showBasic(title: "ERROR", message: "Error in getting images, please check your internet conection", vc: self)
                    return
                }
                guard let jsonArray = value["images"] as? NSArray else {
                    print("Error in jsonArray")
                    Alert.showBasic(title: "ERROR", message: "Error in getting images, please check your internet conection", vc: self)
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
                        if (!newImage.metaData.Private) {
                            self.images.append(newImage)
                        }
                    }
                }
                self.stopAnimation()
                completion(nil)
        }
    }
    
    func getSearchResuts(searchInput:String, completion: @escaping (Error?) -> Void) {
        var filteredImages:[Image] = []
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "project3server.herokuapp.com"
        urlComponents.path = "/api/accounts/images"
        urlComponents.query = "tags=" + searchInput
        
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
                
                guard let jsonArray = value["images"] as? NSArray else {
                    print("Error in jsonArray")
                    return
                }
                for jsonImage in jsonArray {
                    var newImage = Image.init()
                    var idImage:String = ""
                    if let image = jsonImage as? [String:Any]
                    {
                        if let id = image["_id"] as? String {
                            idImage = id
                        }
                        if let metadata = image["metadata"] as? [String:Any] {
                            var author: String = ""; var name: String = ""; var protection: Bool = false; var password: String = ""; var pngImage = UIImage(); var tags = [String](); var isBlurred:Bool = false; var Private:Bool = false; var username:String = "";
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
                            if let privateD = metadata["isPrivate"] as? Bool {
                                Private = privateD
                            }
                            if let passwordD = metadata["password"] as? String {
                                password = passwordD
                            }
                            if let isBlurredD = metadata["isBlurred"] as? Bool {
                                isBlurred = isBlurredD
                            }
                            if let pngImageD = metadata["pngImage"] as? String {
                                if ( !pngImageD.isEmpty) {
                                    let dataDecoded:NSData = NSData(base64Encoded: pngImageD, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                    pngImage = UIImage(data: dataDecoded as Data)!
                                }
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
                    if (!newImage.metaData.Private) {
                        filteredImages.append(newImage)
                    }
                }
                self.filtered = filteredImages
                completion(nil)
        }
    }
}


extension Home: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = logoButton.center
        transition.circleColor = UIColor.white
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = logoButton.center
        transition.circleColor = UIColor.white
        
        return transition
    }
}

extension Home: SocketDeleteUser {
    func deleteUser() {
        User.shared.resetUser()
        Socket.shared.disconnect()
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        //        let viewController = LogInView()
        //        let navCtrl = self.view.window!.rootViewController as! UINavigationController;
        //        navCtrl.pushViewController(viewController, animated: true)
        //        guard
        //            let window = UIApplication.shared.keyWindow,
        //            let rootViewController = window.rootViewController
        //            else {
        //                return
        //        }
        //
        //        navCtrl.view.frame = rootViewController.view.frame
        //        navCtrl.view.layoutIfNeeded()
        //
        //        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
        //            window.rootViewController = navCtrl
        //        })
    }
}




