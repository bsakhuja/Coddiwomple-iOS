//
//  ViewController.swift
//  Coddiwomple
//
//  Created by Brian Sakhuja on 4/11/18.
//  Copyright © 2018 Brian Sakhuja. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
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
            
            // Remove items from the previous search
            self.matchingItems.removeAll()
            
            // Remove annotations on map from the previous search
            self.mapView.removeAnnotations(self.matchingItemAnnotations)
            
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
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        self.matchingItemAnnotations.append(annotation)
                        self.mapView.addAnnotation(annotation)
                    }
                    self.mapView.showAnnotations(self.matchingItemAnnotations, animated: true)
                }
            }
            
        }
    }
    
    // Customize the annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else
        {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.clusteringIdentifier = "myCluster"
            view.markerTintColor = UIColor.red
        }
        return view
    }
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

