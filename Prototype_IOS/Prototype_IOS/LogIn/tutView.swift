//
//  tutView.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-25.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class Slide: UIView {
    var imageView: UIImageView!
    
    init(image: UIImage, frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
