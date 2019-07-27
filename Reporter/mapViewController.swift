//
//  mapViewController.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/16/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Photos

class mapViewController: UIViewController, CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 2000
    
    let colors = Constants.colors
    
    var locationManager: CLLocationManager!
    
    let addLocation = UIButton()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var locationFindButton: UIButton!
    
    @IBOutlet weak var zoomButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    var annotations : [mapMarker] = []
    
    var annotationToAdd = mapMarker(title: "New Pin", location: "", type: "LocationNew", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    var addPinAvailable = true
    
    var personLocation = CLLocation()
    
    var focusOnPerson = true
    
    var selectedLocation = CLLocationCoordinate2D()
    
    //EXTENSION
    
    var assets: [PHAsset] = []
    
    var assetsMarkers: [mapMarker] = []
    
    let albumName = Constants.albumName
    
    var collection:PHFetchResult<PHAssetCollection>? = nil
    
    var photoAssets = PHFetchResult<PHAsset>()
    
    var assetCollection = PHAssetCollection()
    
    var editMode = false
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        determineCurrentLocation()
        
        locationFindButton.addTarget(self, action: #selector(self.findLocation), for: .touchUpInside)
        
        mapView.fitAll()
        
    }
    
    @objc func findLocation() {
        
        determineCurrentLocation()
        
        locationFindButton.setImage(#imageLiteral(resourceName: "locationActive"), for: .normal)
        
    }
    
    @objc func zoom() {
        
        let region = MKCoordinateRegionMakeWithDistance(selectedLocation, regionRadius, regionRadius)
        
        mapView.setRegion(region, animated: true)
        
        zoomButton.setImage(#imageLiteral(resourceName: "zoomToggled"), for: .normal)
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        let mapLongPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        
        mapView.addGestureRecognizer(mapLongPress)
        
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(removePin))
        
        mapView.addGestureRecognizer(mapTap)
        
    }
    
    @objc func removePin() {
        
        if addPinAvailable == false {
            
            addPinAvailable = true
            
            mapView.removeAnnotation(annotationToAdd)
            
            UIView.animate(withDuration: 0.25) {
                
                self.addLocation.transform = CGAffineTransform(translationX: 0, y: 190)
                
            }
            
        }
        
    }
    
    @objc func addPin(press: UILongPressGestureRecognizer) {
        
        if press.state == .began {
            
            removePin()
            
            let coordinate = mapView.convert(press.location(in: mapView), toCoordinateFrom: mapView)
            
            annotationToAdd = mapMarker(title: "New Pin", location: "", type: "LocationNew", coordinate: coordinate)
            
            addPinAvailable = false
            
            mapView.addAnnotation(annotationToAdd)
            
            for i in mapView.annotations {
                
                if (i as? mapMarker) == nil {
                    
                    mapView.deselectAnnotation(i, animated: true)
                    
                }
                
            }
            
            UIView.animate(withDuration: 0.25) {
                
                self.addLocation.transform = CGAffineTransform.identity
                
            }
            
        }
        
    }
    
    @objc func toggleEditMode() {
        
        if editMode {
            
            editButton.setTitle("Edit", for: [])
            
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
        } else {
            
            editButton.setTitle("Done", for: [])
            
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            
        }
        
        editMode = !editMode
        
    }
    
    func search(searchTerm: String) {
        
        //let titleMatches = annotationsArray.filter{$0.title == titleToMatch}
        
        removePin()
        
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotations(annotations)
        
        let searchResults = mapView.annotations.filter { annotation in
            return (annotation.title??.localizedCaseInsensitiveContains(searchTerm) ?? false) ||
                (annotation.subtitle??.localizedCaseInsensitiveContains(searchTerm) ?? false)
        }
        
        print(searchResults)
        
        mapView.removeAnnotations(mapView.annotations)
            
        mapView.addAnnotations(searchResults)
        
        mapView.fitAll()
        
        searchBar.resignFirstResponder()
        
        if searchTerm == "" {
            
            mapView.addAnnotations(annotations)
            
        }
        
        if let cancelButton : UIButton = searchBar.value(forKey: "_cancelButton") as? UIButton {
            
            cancelButton.isEnabled = true
            
            cancelButton.setTitleColor(colors[0], for: .normal)
            
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        removePin()
        
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotations(annotations)
        
        searchBar.text = ""
        
        searchBar.resignFirstResponder()
        
        searchBar.setShowsCancelButton(false, animated: true)
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        if let cancelButton : UIButton = searchBar.value(forKey: "_cancelButton") as? UIButton {
            
            cancelButton.setTitleColor(colors[0], for: .normal)
            
        }
        
        return true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if focusOnPerson {
            
            personLocation = locations[0] as CLLocation
            
            let coor = CLLocationCoordinate2D(latitude: personLocation.coordinate.latitude, longitude: personLocation.coordinate.longitude)
            
            let region = MKCoordinateRegionMakeWithDistance(coor, regionRadius, regionRadius)
            
            mapView.setRegion(region, animated: true)
            
        } else {
            
            mapView.fitAll()
            
        }
        
        focusOnPerson = !focusOnPerson
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        removePin()
        
        if animated == false {
            
            locationFindButton.setImage(#imageLiteral(resourceName: "locationInactive"), for: .normal)
            
            zoomButton.setImage(#imageLiteral(resourceName: "zoom"), for: .normal)
            
        }
        
    }
    
    @objc func addNewTouchUp() {
        
        addLocation.layer.opacity = 1
        
    }
    
    @objc func addNewTouchDown() {
        
        addLocation.layer.opacity =  Constants.opacityFadeButton
        
    }
    
    @objc func addNewTouchComplete() {
        
        addNewTouchUp()
        
        var coor = personLocation
        
        if addPinAvailable == false {
            
            coor = CLLocation(coordinate: annotationToAdd.coordinate, altitude: 0, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, course: 0, speed: 0, timestamp: Date.distantFuture)//annotationToAdd.coordinate
            
            print("SSSS", annotationToAdd.coordinate)
            
        }
        
        print(coor.coordinate)
            
        let alertController = UIAlertController(title: "New Location", message: "Enter a title for the location and a brief description of the location.", preferredStyle: .alert)
            
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            let nameField = alertController.textFields![0] as UITextField
            let roleField = alertController.textFields![1] as UITextField
                
            if nameField.text != "", roleField.text != "" {
                
                let annotation = mapMarker(title: nameField.text!, location: roleField.text!, type: "Location", coordinate: coor.coordinate)
                
                self.mapView.addAnnotation(annotation)
                    
                self.annotations.append(annotation)
                
                self.removePin()
                    
            } else {
                    
                let errorAlert = UIAlertController(title: "Error", message: "Please input both the title AND the location of the new point.", preferredStyle: .alert)
                    
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                    
                self.present(errorAlert, animated: true, completion: nil)
                    
            }
        }))
            
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
        
            alert -> Void in
            
            self.removePin()
        
        }))
            
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Title"
            textField.textAlignment = .center
        })
        
        let geocoder = CLGeocoder()
            
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Location"
            textField.textAlignment = .center
            textField.text = ""
            
            //FIX THIS
            
            geocoder.reverseGeocodeLocation(coor, completionHandler: {
                
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
                        
                    textField.text = address
                    
                }
                
            })
            
        })
            
        self.present(alertController, animated: true, completion: nil)
        
        alertController.view.tintColor = colors[0]
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFromAlbum()
        
        addLocation.setImage(#imageLiteral(resourceName: "plusWhite"), for: [])
        
        addLocation.backgroundColor = colors[0]
        
        addLocation.setTitle("  Add Location", for: [])
        
        addLocation.setTitleColor(UIColor.white, for: [])
        
        addLocation.adjustsImageWhenHighlighted = false
        
        addLocation.addTarget(self, action: #selector(addNewTouchDown), for: [.touchDown,.touchDragInside])
        
        addLocation.addTarget(self, action: #selector(addNewTouchComplete), for: [.touchUpInside])
        
        addLocation.addTarget(self, action: #selector(addNewTouchUp), for: [.touchUpOutside,.touchDragOutside])
        
        addLocation.layer.cornerRadius = 30

        addLocation.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        addLocation.frame = CGRect(x: view.frame.width/2 - 147.5, y: view.frame.height - 120, width: 295, height: 60)
        
        if view.frame.height > 810 {
            
            addLocation.frame = CGRect(x: view.frame.width/2 - 147.5, y: view.frame.height - 160, width: 295, height: 60)
            
        }
        
        addLocation.transform = CGAffineTransform(translationX: 0, y: 190)
        
        view.addSubview(addLocation)
        
        editButton.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)
        
        //searchBar.showsBookmarkButton = true
        
        //searchBar.setImage(#imageLiteral(resourceName: "search"), for: UISearchBarIcon.bookmark, state: .normal)
        
        //searchBar.setImage(#imageLiteral(resourceName: "searchToggled"), for: UISearchBarIcon.bookmark, state: .highlighted)
        
        searchBar.delegate = self
        
        if (CLLocationManager.locationServicesEnabled()) {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
        }
        
        let initialLocation = CLLocation(latitude: 42.357044, longitude: -71.09286)
        centerMapOnLocation(location: initialLocation)
        
        var pin = mapMarker(title: "Lorem Ipsum", location: "Next House", type: "Recording", coordinate: CLLocationCoordinate2D(latitude: 42.354681, longitude: -71.10258))
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        mapView.showsTraffic = false
        
        //mapView.register(markerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.addAnnotation(pin)
        
        pin = mapMarker(title: "Another Location", location: "Boston Marriott", type: "Location", coordinate: CLLocationCoordinate2D(latitude: 42.363015, longitude: -71.086264))
        
        mapView.addAnnotation(pin)
        
        pin = mapMarker(title: "The Last Recording in Boston", location: "MIT Museum", type: "Recording", coordinate: CLLocationCoordinate2D(latitude: 42.362254, longitude: -71.09755))
        
        mapView.addAnnotation(pin)
        
        annotations = mapView.annotations as! [mapMarker]
        
        zoomButton.isHidden = true
        
        zoomButton.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        
        mapView.fitAll()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        search(searchTerm: searchBar.text!)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as! mapMarker
        
        let type = annotation.type
        
        let personAlert = UIAlertController(title: annotation.title! + " - " + annotation.location, message: type, preferredStyle: .actionSheet)
        
        let openMsg = "Open " + type
        
        if type == "Location" {
            
            personAlert.addAction(UIAlertAction(title: "Remove Location", style: .destructive, handler: {
                
                alert -> Void in
                
                let delAlert = UIAlertController(title: "Remove Pin", message: "Are you sure you want to remove this pin permanently?", preferredStyle: .alert)
                
                delAlert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
                    
                    alert -> Void in
                    
                    mapView.removeAnnotation(view.annotation!)
                    
                    self.annotations = self.annotations.filter() { $0 !== view.annotation }
                    
                }))
                
                delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(delAlert, animated: true, completion: nil)
                
            }))
            
        } else {
            
            personAlert.addAction(UIAlertAction(title: openMsg, style: .default, handler: {
                
                alert -> Void in
                
                if type == "Photo" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Preview") as! previewViewController
                    
                    vc.modalTransitionStyle = .coverVertical
                    
                    vc.asset = self.assets[self.assetsMarkers.index(of: view.annotation as! mapMarker)!]
                    
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
            }))
            
        }
        
        personAlert.addAction(UIAlertAction(title: "Open Location in Maps", style: .default, handler: {
            
            alert -> Void in
            
            let location = view.annotation as! mapMarker
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
            
        }))
        
        personAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            alert -> Void in
            
            self.removePin()
            
        }))
        
        self.present(personAlert, animated: true, completion: nil)
        
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        
        //HERE
        
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        
        //HERE
        
    }
    
    let loading = UIActivityIndicatorView()
    
    var loadingView: UIView = UIView()
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        loadingView.center = mapView.center
        
        loadingView.backgroundColor = UIColor.gray
        
        loadingView.alpha = 0.7
        
        loadingView.clipsToBounds = true
        
        loadingView.layer.cornerRadius = 10
        
        loading.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        loading.center = mapView.center
        
        loading.activityIndicatorViewStyle = .whiteLarge
        
        view.addSubview(loadingView)
        
        view.addSubview(loading)
        
        loading.startAnimating()
        
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        loading.stopAnimating()
        
        loadingView.removeFromSuperview()
        
        loading.removeFromSuperview()
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect annView: MKAnnotationView) {
        
        selectedLocation = (annView.annotation?.coordinate)!
        
        zoomButton.isHidden = false
        
        if !editMode {
            
            if (annView.annotation as? mapMarker) == nil {
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.addLocation.transform = CGAffineTransform.identity
                    
                }
                
            }
            
        }
        
        //let coordinateRegion = MKCoordinateRegionMakeWithDistance((annView.annotation?.coordinate)!, regionRadius, regionRadius)
        
        //mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        zoomButton.isHidden = true
        
        if !editMode {
            
            if (view.annotation as? mapMarker) == nil {
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.addLocation.transform = CGAffineTransform(translationX: 0, y: 190)
                    
                }
                
            }
            
        } else {
            
            //alert
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
    }
    
}

extension mapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? mapMarker else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            
            dequeuedView.annotation = annotation
            view = dequeuedView
            
        } else {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24)))
            
            mapsButton.setBackgroundImage(#imageLiteral(resourceName: "export"), for: UIControlState())
            
            view.rightCalloutAccessoryView = mapsButton
            
        }
        return view
    }
    
    func fetchFromAlbum() {
        
        //MULTIPLE PHOTOS => ALBUM
        
        let geocoder = CLGeocoder()
        
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
                
                if object is PHAsset {
                    
                    let asset = object as! PHAsset
                    
                    if asset.location != nil {
                        
                        let annot = mapMarker(title: "Image", location: "Unable to load...", type: "Photo", coordinate: (asset.location?.coordinate)!)
                        
                        print("SSSS", annot.coordinate)
                        
                        self.mapView.addAnnotation(annot)
                        
                        self.assetsMarkers.append(annot)
                        
                        self.assets.append(asset)
                        
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
                                
                            }
                            
                        })
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRectNull;
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect       = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.01, 0.01);
            zoomRect            = MKMapRectUnion(zoomRect, pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(100, 100, 100, 100), animated: true)
    }
    
    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRectNull
        
        for annotation in annotations {
            let aPoint          = MKMapPointForCoordinate(annotation.coordinate)
            let rect            = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
}
