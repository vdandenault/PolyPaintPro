//
//  CameraHandler.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-08.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//
// source : https://hackernoon.com/swift-access-ios-camera-and-photo-library-dc1dbe0cdd76

import Foundation
import UIKit

class CameraHandler: NSObject {
    static let shared = CameraHandler()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    
    private func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    private func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func saveImage(image: UIView) {
        UIGraphicsBeginImageContext(image.frame.size)
        image.layer.render(in: UIGraphicsGetCurrentContext()!)
        let compressedJPGImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
    
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = currentVC.view
            popoverController.sourceRect = CGRect(x: currentVC.view.bounds.midX, y: currentVC.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickedBlock?(image)
        }else{
            print("Something went wrong")
        }
        currentVC.dismiss(animated: true, completion: nil)
    }
    
}

