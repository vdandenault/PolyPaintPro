//
//  Tutoriel.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-04.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class Tutoriel: UIViewController {
    
    var slides:[Slide] = [];

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        scrollView.delegate = self
    }

    @IBAction func doneTapped(_ sender: Any) {
         performSegue(withIdentifier: "toHomeViewFt", sender: self)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeViewFt" {
            if let homeVC = segue.destination as? Home {
                homeVC.firstHome = true
            }
        }
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        User.shared.resetUser()
        performSegue(withIdentifier: "backToSignInTUT", sender: self)
    }
    
    func createSlides() -> [Slide] {
        let slide1: Slide = Slide(image: #imageLiteral(resourceName: "tuto1"), frame: scrollView.frame)
        let slide2: Slide = Slide(image: #imageLiteral(resourceName: "tuto2"), frame: scrollView.frame)
        let slide3: Slide = Slide(image: #imageLiteral(resourceName: "tuto3"), frame: scrollView.frame)
        let slide4: Slide = Slide(image: #imageLiteral(resourceName: "tuto4"), frame: scrollView.frame)
        let slide5: Slide = Slide(image: #imageLiteral(resourceName: "tuto5"), frame: scrollView.frame)
        let slide6: Slide = Slide(image: #imageLiteral(resourceName: "tuto6"), frame: scrollView.frame)
        let slide7: Slide = Slide(image: #imageLiteral(resourceName: "tuto7"), frame: scrollView.frame)
        let slide8: Slide = Slide(image: #imageLiteral(resourceName: "tuto8"), frame: scrollView.frame)
        let slide9: Slide = Slide(image: #imageLiteral(resourceName: "tuto9"), frame: scrollView.frame)
        let slide10: Slide = Slide(image: #imageLiteral(resourceName: "tuto10"), frame: scrollView.frame)
        let slide11: Slide = Slide(image: #imageLiteral(resourceName: "tuto11"), frame: scrollView.frame)
        let slide12: Slide = Slide(image: #imageLiteral(resourceName: "tuto12"), frame: scrollView.frame)
        let slide13: Slide = Slide(image: #imageLiteral(resourceName: "tuto13"), frame: scrollView.frame)
        let slide14: Slide = Slide(image: #imageLiteral(resourceName: "tuto14"), frame: scrollView.frame)
        let slide15: Slide = Slide(image: #imageLiteral(resourceName: "tuto15"), frame: scrollView.frame)
        
        
        return [slide1, slide2, slide3, slide4, slide5, slide6, slide7, slide8, slide9, slide10, slide11, slide12, slide13, slide14, slide15]
    }
    
    
}

extension Tutoriel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}

