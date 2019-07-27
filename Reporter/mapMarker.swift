//
//  mapMarker.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/16/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class mapMarker: NSObject, MKAnnotation {
    
    let title: String?
    var location: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, location: String, type: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.location = location
        self.type = type
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return location
    }
    
    func mapItem() -> MKMapItem {
        
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
        
    }
    
}
