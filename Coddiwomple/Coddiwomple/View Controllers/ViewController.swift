//
//  ViewController.swift
//  Coddiwomple
//
//  Created by Brian Sakhuja on 4/11/18.
//  Copyright © 2018 Brian Sakhuja. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var matchingItems = [MKMapItem]()
    var matchingItemAnnotations = [MKAnnotation]()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func searchButton(_ sender: Any)
    {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
    }
    
    // When user presses "Search"
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        // Remove items from the previous search
        self.matchingItems.removeAll()
        
        // Remove annotations on map from the previous search
        self.mapView.removeAnnotations(self.matchingItemAnnotations)
        self.matchingItemAnnotations.removeAll()
        
        // Disable interaction events while searching (ignore user)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator) // display activity indicator
        
        // Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        searchRequest.region = mapView.region
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        // The search is started
        activeSearch.start { (response, error) in
            
            // Stop updating location so that the map doesn't focus on your location when you move
            self.locationManager.stopUpdatingLocation()
            
            // Remove activity indicator
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let results = response
            {
                if let err = error
                {
                    print("Error occurred in search: \(err.localizedDescription)")
                }
                else if results.mapItems.count == 0
                {
                    print("No matches found")
                }
                else
                {
                    print("Matches found")
                    
                    for item in results.mapItems
                    {
                        self.matchingItems.append(item)
                        let annotation = PlaceAnnotation(title: item.name!, coordinate: item.placemark.coordinate)
                        self.matchingItemAnnotations.append(annotation)
                        self.mapView.addAnnotation(annotation)
                    }
                    self.mapView.showAnnotations(self.matchingItemAnnotations, animated: true)
                }
            }
            
        }
    }
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // Create the track button item
        let trackButton = MKUserTrackingBarButtonItem.init(mapView: mapView)
        
        // Display track user button on top left of nav bar
        self.navigationItem.leftBarButtonItem = trackButton
        
        // Initially focus on user location
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegionMake(center, span)
        
        self.mapView.setRegion(region, animated: false)
    }


}

extension ViewController: MKMapViewDelegate {
    
    // Show annotation info upon tapping annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check if this is a PlaceAnnotation object
        guard let annotation = annotation as? PlaceAnnotation else { return nil }
        
        // Display MarkerAnnotationViews
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        // A map view reuses annotation views that are no longer visible. So you check to see if a reusable annotation view is available before creating a new one
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            
            // Create a new MKMarkerAnnotationView object if one could not be dequeued.  Show callout bubble.
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .infoLight)
        }
        return view
    }
    
    // open the Maps app when user presses (i)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! PlaceAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

