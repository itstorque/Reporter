//
//  photosViewController.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/15/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import CoreLocation

class photosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate, CLLocationManagerDelegate {
    
    var assets: [PHAsset] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var captureButton: UIButton!
    
    //@IBOutlet var imageView: UIImageView?
    
    @IBOutlet weak var activateButton: UIButton!
    
    fileprivate var imageAssets = [PHAsset]()
    
    var widthDimension : CGFloat = 0
    
    var ratio : [CGFloat] = []
    
    var sizingSmallify = 0
    
    var newLine = 2
    
    let albumName = Constants.albumName
    
    let colors = Constants.colors
    
    var flash = -1
    
    var picTakenCount = 0
    
    var assetCollection = PHAssetCollection()
    
    var quickPhoto = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locationManager: CLLocationManager! = nil
    
    var currentLocation : CLLocation? = nil
    
    var noPhotos = UILabel()
    
    var explanation = UILabel()
    
    ///
    
    @IBOutlet var overlayView: UIView?
    
    // Camera controls found in the overlay view.
    @IBOutlet var takePictureButton: UIButton?
    @IBOutlet var startStopButton: UIButton?
    @IBOutlet var delayedPhotoButton: UIButton?
    @IBOutlet var doneButton: UIButton?
    
    var cameraTimer = Timer()
    var capturedImages = [UIImage]()
    
    let imagePickerController = UIImagePickerController()
    
    ///
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var flashIcon: UIImageView!
    @IBOutlet weak var infoIcon: UIImageView!
    
    @IBOutlet weak var type1: UIButton!
    @IBOutlet weak var type2: UIButton!
    
    var collection:PHFetchResult<PHAssetCollection>? = nil
    
    var photoAssets = PHFetchResult<PHAsset>()
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        currentLocation = locations.last as! CLLocation
        
    }
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.assets.count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func createAlbum() {
        
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            
        }) {
            
            success, error in
            
            if success {
                
                print("WOOHOO!")
                
            } else {
                
                print("error \(error)")
                
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseCollectionViewCell", for: indexPath as IndexPath) as! photoCell
        
        cell.layer.cornerRadius = 5
        
        PHImageManager.default().requestImage(for: assets[indexPath.item], targetSize: CGSize(width: assets[indexPath.item].pixelWidth, height: assets[indexPath.item].pixelHeight), contentMode: .default, options: nil, resultHandler: {
            
            (image, info) in
            
            cell.imageView.image = image
            
            cell.imageView.contentMode = .scaleAspectFill
            
        })
        
        return cell
        
    }
    
    var test = 100
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        PHImageManager.default().requestImage(for: assets[indexPath.item], targetSize: CGSize(width: assets[indexPath.item].pixelWidth, height: assets[indexPath.item].pixelHeight), contentMode: .default, options: nil, resultHandler: {
            
            (image, info) in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Preview") as! previewViewController
            
            vc.modalTransitionStyle = .coverVertical
            
            vc.asset = self.assets[indexPath.item]
            
            self.present(vc, animated: true, completion: nil)
            
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if newLine == 0 {
            
            newLine = 2
            
        }
        
        if test > 0 {
            
            test -= 1
            
        }
        
        var size = CGSize(width: widthDimension, height: widthDimension)
        
        if sizingSmallify > 0 {
            
            sizingSmallify -= 1
            
            size = CGSize(width: collectionView.frame.width * 1/3 - 7, height: collectionView.frame.width * 1.9/3 - 5)
            
        } else if newLine == 2 {
            
            if Int(arc4random_uniform(UInt32(8))) == 6 {
                
                size = CGSize(width: collectionView.frame.width * 1.9/3 - 5, height: collectionView.frame.width * 1.9/3 - 5)
                
                sizingSmallify = 1
                
            } else if Int(arc4random_uniform(UInt32(7))) == 3 {
                
                size = CGSize(width: collectionView.frame.width * 1/3 - 7, height: collectionView.frame.width * 1.9/3 - 5)
                
                sizingSmallify = 2
                
                newLine += 1
                
            } else if Int(arc4random_uniform(UInt32(4))) == 3 {
                
                size = CGSize(width: collectionView.frame.width - 25, height: collectionView.frame.width / 1.5)
                
                sizingSmallify = 3
                
                newLine = 4
                
            }
            
        }
        
        newLine -= 1
        
        return size
        
    }
    
    func fetchFromAlbum() {
        
        assets = []
        
        var photoAssets = PHFetchResult<AnyObject>()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let first_Obj:AnyObject = collection?.firstObject {
            //found the album
            assetCollection = collection?.firstObject as! PHAssetCollection
            
            photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
            
            //        let imageManager = PHImageManager.defaultManager()
            
            photoAssets.enumerateObjects{(object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>)
                
                in
                
                if object is PHAsset{
                    
                    let asset = object as! PHAsset
                    
                    self.assets.append(asset)
                    
                }
                
            }
            
            assets.reverse()
            
        } else {
                
            createAlbum()
            
            fetchFromAlbum()
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.delegate = self
        
        fetchFromAlbum()
        
        // Remove the camera button if the camera is not currently available.
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            captureButton.isHidden = true
            
        }
        
        widthDimension = view.frame.width/2 - 25
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        
        //layout.itemSize = CGSize(width: widthDimension, height: widthDimension)
        
        //layout.estimatedItemSize = CGSize(width: widthDimension, height: widthDimension)
        
        //layout.sectionInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        
        //layout.minimumLineSpacing = 10.0
        
        //layout.minimumInteritemSpacing = 7.0
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.reloadData()
        
        captureButton.adjustsImageWhenHighlighted = false
        
        captureButton.addTarget(self, action: #selector(addNewTouchDown), for: [.touchDown,.touchDragInside])
        
        captureButton.addTarget(self, action: #selector(addNewTouchComplete), for: [.touchUpInside])
        
        captureButton.addTarget(self, action: #selector(addNewTouchUp), for: [.touchUpOutside,.touchDragOutside])
        
        if assets.count == 0 {
            
            noPhotos = UILabel(frame: CGRect(x: 0, y: -30, width: view.frame.width, height: view.frame.height))
            
            noPhotos.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            
            noPhotos.textColor = UIColor.darkGray
            
            noPhotos.text = "No Evidence"
            
            noPhotos.textAlignment = .center
            
            explanation = UILabel(frame: CGRect(x: 15, y: 20, width: view.frame.width - 30, height: view.frame.height))
            
            explanation.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            explanation.textColor = UIColor.lightGray
            
            explanation.text = "Capture evidence or add photos from your photos library to the folder \"Reporter\""
            
            explanation.numberOfLines = 2
            
            explanation.adjustsFontSizeToFitWidth = true
            
            explanation.textAlignment = .center
            
            view.addSubview(noPhotos)
            
            view.addSubview(explanation)
            
        }
        
        print("I:", assets.count)
        
        for asset in assets {
            
            /*
            
            print(asset.location)
            
            print(asset.creationDate)
            
            print(asset.isFavorite)
            
            print(asset.mediaType)*/
            
            ratio.append(CGFloat(asset.pixelHeight)/CGFloat(asset.pixelWidth))
            
        }
        
        if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            
            registerForPreviewing(with: self, sourceView: collectionView)
            
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print("AppDelegate: ", appDelegate.takeImage)
        
        if appDelegate.takeImage {
            
            addNewTouchComplete(sender: UIButton())
            
            appDelegate.takeImage = false
            
        }
        
        let backup = assets
        
        fetchFromAlbum()
        
        if assets != backup {
            
            let layout = UICollectionViewFlowLayout()
            
            layout.scrollDirection = .vertical
            
            collectionView.setCollectionViewLayout(layout, animated: true)
            
            collectionView.reloadData()
            
            if assets.count == 0 {
                
                noPhotos = UILabel(frame: CGRect(x: 0, y: -30, width: view.frame.width, height: view.frame.height))
                
                noPhotos.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
                
                noPhotos.textColor = UIColor.darkGray
                
                noPhotos.text = "No Evidence"
                
                noPhotos.textAlignment = .center
                
                explanation = UILabel(frame: CGRect(x: 15, y: 20, width: view.frame.width - 30, height: view.frame.height))
                
                explanation.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                
                explanation.textColor = UIColor.lightGray
                
                explanation.text = "Capture evidence or add photos from your photos library to the folder \"Reporter\""
                
                explanation.numberOfLines = 2
                
                explanation.adjustsFontSizeToFitWidth = true
                
                explanation.textAlignment = .center
                
                view.addSubview(noPhotos)
                
                view.addSubview(explanation)
                
            } else {
                
                if noPhotos == UILabel(frame: CGRect(x: 0, y: -30, width: view.frame.width, height: view.frame.height)) {
                    
                    noPhotos.removeFromSuperview()
                    
                    explanation.removeFromSuperview()
                    
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let popVC = storyboard?.instantiateViewController(withIdentifier: "Preview") as! previewViewController
        
        guard let indexPath = collectionView?.indexPathForItem(at:location) else { return nil }
        
        guard  let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        
        popVC.asset = self.assets[indexPath.item]
        
        popVC.preferredContentSize = CGSize(width: 0.0, height: view.frame.height - 100)
        
        previewingContext.sourceRect = cell.frame
        
        return popVC
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        //if let ViewController = viewControllerToCommit as? previewViewController {
            
            //ViewController.back.isHidden = false
            
        //}
        
        show(viewControllerToCommit, sender: self)
        
    }
    
    //MARK: - Add New Image
    
    @objc func addNewTouchUp() {
        
        captureButton.layer.opacity = 1
        
    }
    
    @objc func addNewTouchDown() {
        
        captureButton.layer.opacity =  Constants.opacityFadeButton
        
    }
    
    @objc func addNewTouchComplete(sender: UIButton) {
        
        addNewTouchUp()
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == AVAuthorizationStatus.denied {
            // Denied access to camera, alert the user.
            // The user has previously denied access. Remind the user that we need camera access to be useful.
            let alert = UIAlertController(title: "Unable to access the Camera",
                                          message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Take the user to Settings app to possibly change permission.
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                }
            })
            alert.addAction(settingsAction)
            
            present(alert, animated: true, completion: nil)
        }
        else if (authStatus == AVAuthorizationStatus.notDetermined) {
            // The user has not yet been presented with the option to grant access to the camera hardware.
            // Ask for permission.
            //
            // (Note: you can test for this case by deleting the app on the device, if already installed).
            // (Note: we need a usage description in our Info.plist to request access.
            //
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.showImagePicker(sourceType: UIImagePickerControllerSourceType.camera, button: sender)
                    }
                }
            })
        } else {
            // Allowed access to camera, go ahead and present the UIImagePickerController.
            showImagePicker(sourceType: UIImagePickerControllerSourceType.camera, button: sender)
        }
        
    }
    
    fileprivate func showImagePicker(sourceType: UIImagePickerControllerSourceType, button: UIButton) {
        // If the image contains multiple frames, stop animating.
        //if (imageView?.isAnimating)! {
        //    imageView?.stopAnimating()
        //}
        
        //view.bringSubview(toFront: imageView!)
        
        if capturedImages.count > 0 {
            capturedImages.removeAll()
        }
        
        imagePickerController.sourceType = sourceType
        imagePickerController.modalPresentationStyle =
            (sourceType == UIImagePickerControllerSourceType.camera) ?
                UIModalPresentationStyle.fullScreen : UIModalPresentationStyle.popover
        
        let presentationController = imagePickerController.popoverPresentationController
        
        presentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        if sourceType == UIImagePickerControllerSourceType.camera {
            
            imagePickerController.showsCameraControls = false
            
            imagePickerController.cameraOverlayView?.isOpaque = false
            imagePickerController.cameraOverlayView?.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            activateButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            activateButton.layer.borderWidth = 15
            
            activateButton.clipsToBounds = false
            
            infoLabel.textColor = UIColor.white
            
            let toggleFlashGR = UITapGestureRecognizer(target: self, action: #selector(self.toggleFlash))
            
            if flash == -1 {
                
                flash = 0
                
                toggleFlash(sender: toggleFlashGR)
                
            }
            
            flashLabel.isUserInteractionEnabled = true
            
            flashLabel.addGestureRecognizer(toggleFlashGR)
            
            flashIcon.isUserInteractionEnabled = true
            
            flashIcon.addGestureRecognizer(toggleFlashGR)
            
            activateButton.backgroundColor = colors[0]
            
            changeToDefault()
            
            type1.addTarget(self, action: #selector(changeToTimer), for: .touchUpInside)
            
            type2.addTarget(self, action: #selector(changeToShutter), for: .touchUpInside)
            
            overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0)
            overlayView?.isOpaque = false
            
            overlayView?.frame = (imagePickerController.cameraOverlayView?.frame)!//CGRect(x: 0, y: (imagePickerController.cameraOverlayView?.frame.height)! - 150, width: (imagePickerController.cameraOverlayView?.frame.width)!, height: 150)/
            imagePickerController.cameraOverlayView = overlayView
        }
        
        present(imagePickerController, animated: true, completion: {
            // Done presenting.
        })
    }
    
    @objc func changeToTimer() {
        
        type1.setImage(#imageLiteral(resourceName: "cameraGlyph"), for: [])
        
        type2.setImage(#imageLiteral(resourceName: "shutterGlyph"), for: [])
        
        activateButton.backgroundColor = colors[3]
        
        type1.addTarget(self, action: #selector(changeToDefault), for: .touchUpInside)
        
        type2.addTarget(self, action: #selector(changeToShutter), for: .touchUpInside)
        
        activateButton.removeTarget(nil, action: nil, for: .allEvents)
        
        activateButton.addTarget(self, action: #selector(delayedTakePhoto), for: .touchUpInside)
        
        infoLabel.text = "5s"
        
        infoIcon.image = #imageLiteral(resourceName: "timerGlyph")
        
    }
    
    @objc func changeToShutter() {
        
        type1.setImage(#imageLiteral(resourceName: "timerGlyph"), for: [])
        
        type2.setImage(#imageLiteral(resourceName: "cameraGlyph"), for: [])
        
        activateButton.backgroundColor = colors[7]
        
        type1.addTarget(self, action: #selector(changeToTimer), for: .touchUpInside)
        
        type2.addTarget(self, action: #selector(changeToDefault), for: .touchUpInside)
        
        activateButton.removeTarget(nil, action: nil, for: .allEvents)
        
        activateButton.addTarget(self, action: #selector(startTakingPicturesAtIntervals), for: .touchUpInside)
        
        infoLabel.text = "10 max"
        
        infoIcon.image = #imageLiteral(resourceName: "shutterGlyph")
        
    }
    
    @objc func changeToDefault() {
        
        type1.setImage(#imageLiteral(resourceName: "timerGlyph"), for: [])
        
        type2.setImage(#imageLiteral(resourceName: "shutterGlyph"), for: [])
        
        type1.addTarget(self, action: #selector(changeToTimer), for: .touchUpInside)
        
        type2.addTarget(self, action: #selector(changeToShutter), for: .touchUpInside)
        
        infoLabel.text = "Default"
        
        infoIcon.image = #imageLiteral(resourceName: "cameraGlyph")
        
        activateButton.backgroundColor = colors[0]
        
        activateButton.removeTarget(nil, action: nil, for: .allEvents)
        
        activateButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
    }
    
    @objc func toggleFlash(sender: UITapGestureRecognizer) {
        
        print("FLASH TOGGLE")
        
        if flash == 0 {
            
            imagePickerController.cameraFlashMode = .auto
            
            flashIcon.image = #imageLiteral(resourceName: "flashAuto")
            
            flashLabel.text = "Flash Auto"
            
            flashLabel.textColor = colors[7]
            
            flash = 2
            
        } else if flash == 1 {
            
            imagePickerController.cameraFlashMode = .off
            
            flashIcon.image = #imageLiteral(resourceName: "flashOff")
            
            flashLabel.text = "Flash Off"
            
            flashLabel.textColor = UIColor.white
            
            flash = 0
            
        } else {
            
            imagePickerController.cameraFlashMode = .on
            
            flashIcon.image = #imageLiteral(resourceName: "flashOn")
            
            flashLabel.textColor = colors[2]
            
            flashLabel.text = "Flash On"
            
            flash = 1
            
        }
        
    }
    
    // MARK: - Camera View Actions
    
    @IBAction func done(_ sender: UIButton) {
        if cameraTimer.isValid {
            cameraTimer.invalidate()
        }
        finishAndUpdate()
    }
    
    fileprivate func finishAndUpdate() {
        dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            for i in self.capturedImages {
                
                self.saveImage(image: i)
                
            }
            
            /*
            if `self`.capturedImages.count > 0 {
                if self.capturedImages.count == 1 {
                    // Camera took a single picture.
                    `self`.imageView?.image = `self`.capturedImages[0]
                } else {
                    // Camera took multiple pictures; use the list of images for animation.
                    `self`.imageView?.animationImages = `self`.capturedImages
                    `self`.imageView?.animationDuration = 5    // Show each captured photo for 5 seconds.
                    `self`.imageView?.animationRepeatCount = 0   // Animate forever (show all photos).
                    `self`.imageView?.startAnimating()
                }
                
                // To be ready to start again, clear the captured images array.
                `self`.capturedImages.removeAll()
            }*/
        })
    }
    
    func saveImage(image: UIImage) {
        
        PHPhotoLibrary.shared().savePhoto(image: image, albumName: "Reporter", location: currentLocation)
        
        let test = assets.count
        
        while test == assets.count {
            
            fetchFromAlbum()
            
        }
        
        if noPhotos == UILabel(frame: CGRect(x: 0, y: -30, width: view.frame.width, height: view.frame.height)) {
            
            noPhotos.removeFromSuperview()
            
            explanation.removeFromSuperview()
            
        }
        
        collectionView.reloadData()
        
        collectionView.invalidateIntrinsicContentSize()
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.reloadData()
        
    }
    
    @objc func takePhoto() {
        
        determineCurrentLocation()
        
        imagePickerController.takePicture()
        
    }
    
    @objc func delayedTakePhoto() {
        // These controls can't be used until the photo has been taken.
        doneButton?.isEnabled = false
        takePictureButton?.isEnabled = false
        delayedPhotoButton?.isEnabled = false
        startStopButton?.isEnabled = false
        
        var count = 5
        
        let fireDate = Date(timeIntervalSinceNow: 0)
        
        activateButton.setTitleColor(colors[3], for: [])
        
        activateButton.setTitleColor(colors[0], for: .highlighted)
        
        activateButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        
        UIView.animate(withDuration: 0.14) {
            
            self.activateButton.backgroundColor = UIColor.white
            
        }
        
        cameraTimer = Timer.init(fire: fireDate, interval: 1.0, repeats: true, block: { timer in
            
            count -= 1
            
            if count == 0 {
                
                self.cameraTimer.invalidate()
                
                self.activateButton.setTitle("", for: [])
                
                self.infoLabel.text = "5s"
                
                self.imagePickerController.takePicture()
                
                self.doneButton?.isEnabled = true
                self.takePictureButton?.isEnabled = true
                self.delayedPhotoButton?.isEnabled = true
                self.startStopButton?.isEnabled = true
                
            } else if count > 0 {
                
                self.infoLabel.text = String(describing: count)+"s"
                
                self.activateButton.setTitle(String(describing: count)+"s", for: [])
                
            } else {
                
                count = 5
                
                self.cameraTimer.invalidate()
                
            }
            
        })
        
        RunLoop.main.add(cameraTimer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    @objc func startTakingPicturesAtIntervals() {
        
        doneButton?.isEnabled = false
        delayedPhotoButton?.isEnabled = false
        takePictureButton?.isEnabled = false
        startStopButton?.isEnabled = false
        
        activateButton.isEnabled = true
        
        picTakenCount = 0
        
        activateButton.setTitleColor(colors[7], for: [])
        
        activateButton.setTitleColor(colors[0], for: .highlighted)
        
        activateButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        
        UIView.animate(withDuration: 0.14) {
            
            self.activateButton.backgroundColor = UIColor.white
            
        }
        
        activateButton.removeTarget(nil, action: nil, for: .allEvents)
        
        activateButton.addTarget(self, action: #selector(stopTakingPicturesAtIntervals), for: .touchUpInside)
        
        cameraTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            
            self.picTakenCount += 1
            
            self.activateButton.setTitle(String(describing: self.picTakenCount), for: [])
            
            self.imagePickerController.takePicture()
            
            if self.picTakenCount > 10 {
                
                self.stopTakingPicturesAtIntervals()
                
            }
            
        }
    }
    
    @objc func stopTakingPicturesAtIntervals() {
        // Stop and reset the timer.
        cameraTimer.invalidate()
        
        finishAndUpdate()
        
        // Make these buttons available again.
        self.doneButton?.isEnabled = true
        self.takePictureButton?.isEnabled = true
        self.delayedPhotoButton?.isEnabled = true
        self.startStopButton?.isEnabled = true
        
        activateButton.setTitle("", for: [])
        
        activateButton.backgroundColor = colors[7]
        
        activateButton.removeTarget(nil, action: nil, for: .allEvents)
        
        activateButton.addTarget(self, action: #selector(startTakingPicturesAtIntervals), for: .touchUpInside)
        
        // Reset the button back to start taking pictures again.
        //startStopButton?.title = NSLocalizedString("Start", comment: "Title for overlay view controller start/stop button")
        //startStopButton?.action = #selector(startTakingPicturesAtIntervals)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        capturedImages.append(image as! UIImage)
        
        if !cameraTimer.isValid {
            // Timer is done firing so Finish up until the user stops the timer from taking photos.
            finishAndUpdate()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            // Done cancel dismiss of image picker.
        })
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

class photoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}

extension PHPhotoLibrary {
    // MARK: - PHPhotoLibrary+SaveImage
    
    // MARK: - Public
    
    func savePhoto(image:UIImage, albumName:String, location: CLLocation? = nil, completion:((PHAsset?)->())? = nil) {
        func save() {
            if let album = PHPhotoLibrary.shared().findAlbum(albumName: albumName) {
                
                PHPhotoLibrary.shared().saveImage(image: image, album: album, location: location,completion: completion)
                
            } else {
                PHPhotoLibrary.shared().createAlbum(albumName: albumName, completion: { (collection) in
                    if let collection = collection {
                        PHPhotoLibrary.shared().saveImage(image: image, album: collection, completion: completion)
                    } else {
                        completion?(nil)
                    }
                })
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            save()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    save()
                }
            })
        }
    }
    
    // MARK: - Private
    
    fileprivate func findAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    fileprivate func createAlbum(albumName: String, completion: @escaping (PHAssetCollection?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    completion(nil)
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(album)
            } else {
                completion(nil)
            }
        })
    }
    
    fileprivate func saveImage(image: UIImage, album: PHAssetCollection, location: CLLocation? = nil, completion:((PHAsset?)->())? = nil) {
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
            placeholder = photoPlaceholder
            
            if let location = location {
                
                createAssetRequest.location = location
                
            }
            
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                completion?(nil)
                return
            }
            if success {
                let assets:PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                let asset:PHAsset? = assets.firstObject
                
                completion?(asset)
                
            } else {
                completion?(nil)
            }
        })
    }
}

