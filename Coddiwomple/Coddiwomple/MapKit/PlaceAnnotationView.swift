//
//  PlaceAnnotationView.swift
//  Coddiwomple
//
//  Created by Brian Sakhuja on 5/12/18.
//  Copyright © 2018 Brian Sakhuja. All rights reserved.
//

import MapKit

class PlaceAnnotationView: MKMarkerAnnotationView
{
    override var annotation: MKAnnotation? {
        willSet {
            // configure the callout
            guard let artwork = newValue as? PlaceAnnotation else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            // 2
            markerTintColor = UIColor.blue
            glyphText = String((artwork.title?.first)!)
        }
    }
}
