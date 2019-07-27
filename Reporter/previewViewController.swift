//
//  previewViewController.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/20/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit
import Photos

class previewViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imageView = UIImageView()
    
    var hidden = false
    
    var tapGR = UITapGestureRecognizer()
    
    var doubleTapGR = UITapGestureRecognizer()
    
    var asset = PHAsset()

    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let geocoder = CLGeocoder()
        
        imageView.frame = view.frame
        
        imageView.contentMode = .scaleAspectFit
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .default, options: nil, resultHandler: {
            
            (image, info) in
            
            self.imageView.image = image
            
        })
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
        
        if asset.creationDate != nil {
        
            dateLabel.text = dateFormatter.string(from: asset.creationDate!)
            
        }
        
        if asset.location != nil {
            
            geocoder.reverseGeocodeLocation(asset.location!, completionHandler: {
                
                placemarks, error in
                
                if error == nil && (placemarks?.count)! > 0 {
                    
                    let placeMark : CLPlacemark = (placemarks?.last)!
                    
                    var thoroughfare = placeMark.thoroughfare
                    
                    var postal = placeMark.postalCode
                    
                    var locality = placeMark.locality
                    
                    var country = placeMark.country
                    
                    var subL = placeMark.subLocality
                    
                    var subT = placeMark.subThoroughfare
                    
                    //var admin = placeMark.administrativeArea
                    
                    var name = placeMark.name
                    
                    if thoroughfare == nil {
                        
                        thoroughfare = ""
                        
                    } else {
                        
                        thoroughfare = thoroughfare! + ", "
                        
                    }
                    
                    if name == nil {
                        
                        name = ""
                        
                    } else {
                        
                        name = name! + ", "
                        
                    }
                    
                    if subL == nil {
                        
                        subL = ""
                        
                    } else {
                        
                        subL = subL! + ", "
                        
                    }
                    
                    if subT == nil {
                        
                        subT = ""
                        
                    } else {
                        
                        subT = subT! + ", "
                        
                    }
                    
                    //if admin == nil {
                    
                    //    admin = ""
                    
                    //}
                    
                    if postal == nil {
                        
                        postal = ""
                        
                    } else {
                        
                        postal = postal! + ", "
                        
                    }
                    
                    if locality == nil {
                        
                        locality = ""
                        
                    } else {
                        
                        locality = locality! + ", "
                        
                    }
                    
                    if country == nil {
                        
                        country = ""
                        
                    }
                    
                    let address = name! + subT! + thoroughfare! + postal! + subL! + locality! + country!
                    
                    self.locationLabel.text = address
                    
                }
                
            })
            
        } else {
            
            self.locationLabel.text = "No location data"
            
        }
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6.0
        scrollView.contentSize = self.imageView.frame.size
        scrollView.delegate = self
        
        scrollView.isUserInteractionEnabled = true
        
        tapGR = UITapGestureRecognizer(target: self, action: #selector(showHide))
        
        tapGR.cancelsTouchesInView = false
        
        tapGR.numberOfTapsRequired = 1
        
        doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(zoomOut))
        
        doubleTapGR.cancelsTouchesInView = false
        
        doubleTapGR.numberOfTapsRequired = 2
        
        scrollView.addGestureRecognizer(doubleTapGR)
        
        scrollView.addGestureRecognizer(tapGR)
        
        scrollView.addSubview(imageView)
        
        perform(#selector(showHideAction), with: nil, afterDelay: 5)
        
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    
    @objc func zoomOut(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            
            if scrollView.zoomScale == 1 {
                
                UIApplication.shared.isStatusBarHidden = true
                
                UIView.animate(withDuration: 0.2) {
                    
                    self.scrollView.zoomScale = 2//self.view.frame.height / (CGFloat(self.asset.pixelHeight) / CGFloat(self.asset.pixelWidth) * self.view.frame.width)
                    
                    let x = sender.location(in: self.scrollView).x - self.scrollView.center.x
                    
                    let y = sender.location(in: self.scrollView).y - self.scrollView.center.y
                    
                    self.scrollView.contentOffset = CGPoint(x: x, y: y)//self.scrollView.center - sender.location(in: self.scrollView)
                    
                }
                
            } else {
                
                UIView.animate(withDuration: 0.2) {
                    
                    self.scrollView.zoomScale = 1
                    
                }
                
                UIApplication.shared.isStatusBarHidden = false
                
            }
            
        }
        
    }

    
    @objc func done() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func showHideAction() {
        
        if hidden {
            
            doneButton.isHidden = false
            dateLabel.isHidden = false
            locationLabel.isHidden = false
            
            perform(#selector(showHideAction), with: nil, afterDelay: 5)
            
        } else {
            
            doneButton.isHidden = true
            dateLabel.isHidden = true
            locationLabel.isHidden = true
            
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            
        }
        
        hidden = !hidden
        
    }
    
    @objc func showHide(_ sender: UITapGestureRecognizer) {
        
        showHideAction()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
        
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
        hidden = false
        
        showHideAction()
        
        UIApplication.shared.isStatusBarHidden = true
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        if scale == 1 {
            
            hidden = true
            
            showHideAction()
            
            UIApplication.shared.isStatusBarHidden = false
            
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if abs(velocity.y) > 1 && scrollView.zoomScale == 1 && abs(velocity.x) < 1{
            
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                
                self.imageView.transform = CGAffineTransform.init(translationX: 0, y: -velocity.y*100)
                
                self.imageView.alpha = 0
                
                self.locationLabel.alpha = 0
                
                self.dateLabel.alpha = 0
                
                self.doneButton.alpha = 0
                
            }) { _ in
                
                self.done()
                
            }
        
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
