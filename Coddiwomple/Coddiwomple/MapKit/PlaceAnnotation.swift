//
//  AnnotationArtwork.swift
//  Coddiwomple
//
//  Created by Brian Sakhuja on 5/12/18.
//  Copyright © 2018 Brian Sakhuja. All rights reserved.
//

import MapKit
import Contacts

class PlaceAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
//    var subtitle: String? {
//        return locationName
//    }
    
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}


