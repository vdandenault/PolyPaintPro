//
//  ImageCell.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-09.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit
import Hero

class imageCell: UICollectionViewCell {
    
    @IBOutlet weak var blureEffect: UIVisualEffectView!
    @IBOutlet weak var Image: UIImageView!
    
    var blure = false
    var effect = UIBlurEffect(style : .light)
    var imageAuthor:String = ""
    
    func setCell(imageName:String, UIImage: UIImage, blure:Bool, imageAuthor: String) {
        self.Image.image = UIImage
        self.Image.hero.id = imageAuthor
        self.Image.contentMode = .scaleAspectFit
        if (blure) {
            self.blure = true
            self.blureEffect.effect = effect
        }
        else {
            self.blure = false
            self.blureEffect.effect = nil
        }
    }
}
