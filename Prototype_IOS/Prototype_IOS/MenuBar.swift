//
//  MenuBar.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-12.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let cellId: String = "cellId"
    let imageNames = ["home", "galerie", "p", "chat"]
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        collectionView.register(MenuCell .self, forCellWithReuseIdentifier: cellId)
        self.backgroundColor = UIColor.init(red: 230, green: 32, blue: 31, alpha: 1)
        let selectedIndexPath = IndexPath(row: 1, section: 1)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
    }
    
    lazy var collectionView: UICollectionView = {
        let layout =  UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        cell.imageView.image = UIImage(named: imageNames[indexPath.item])?.withRenderingMode(.alwaysTemplate)
        cell.tintColor = UIColor.init(red: 291, green: 32, blue: 31, alpha: 1)
        return cell
    }
}

class MenuCell: UICollectionViewCell {
    
    let imageView:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.init(red: 291, green: 32, blue: 31, alpha: 1)
        return iv
    }()
    
    override var isSelected: Bool {
        didSet{
            imageView.tintColor = isSelected ? UIColor.white : UIColor.init(red: 291, green: 32, blue: 31, alpha: 1)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews(
        )
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        addSubview(imageView)
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        imageView.centerXAnchor.constraint(equalTo: self.backgroundView!.centerXAnchor)
        imageView.centerYAnchor.constraint(equalTo: self.backgroundView!.centerYAnchor)
    }
}
