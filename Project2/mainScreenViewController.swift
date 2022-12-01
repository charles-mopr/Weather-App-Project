//
//  ViewController.swift
//  Project2
//
//  Created by Charles Roy on 2022-11-30.
//

import UIKit
import MapKit

class mainScreenViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
func addAnnotation(location: CLLocation){
    let annotation = MyAnnotation(coordinate: location.coordinate,
                                  title: "My Location",
                                  subtitle: "\(location.coordinate.latitude), \(location.coordinate.longitude)", glyphText: "-5º")
          mapView.addAnnotation(annotation)
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToLocation", sender: self)
        
    }
    
}

extension mainScreenViewController: CLLocationManagerDelegate, MKMapViewDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        print(currentLocation)
        let radiousInMeter: CLLocationDistance = 1000
        let region = MKCoordinateRegion(center: currentLocation.coordinate,
                                        latitudinalMeters: radiousInMeter,
                                        longitudinalMeters: radiousInMeter)
        mapView.setRegion(region, animated: true)
        addAnnotation(location: currentLocation)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "identifier"
        var view = MKMarkerAnnotationView()
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            dequeuedView.annotation = annotation
            
            view = dequeuedView
        }
        else{
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            let button = UIButton(type: .detailDisclosure)
            button.tag = 100
            view.rightCalloutAccessoryView = button
            
            let image = UIImage(systemName: "snowflake")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            //annotation pin color
            view.markerTintColor = UIColor.purple
            
            //accessories color
            view.tintColor = UIColor.purple
            
            if let myAnnotation = annotation as? MyAnnotation{
                view.glyphText = myAnnotation.glyphText
            }

        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
        super.init()
    }
}





//Function for annotation
//func addAnnotation(currentLocation: CLLocation){
//    let annotation = MyAnnotation(coordinate: currentLocation.coordinate,
//                                  title: "My Location",
//                                  subtitle: "\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
////          mapView.addAnnotation(annotation)
////        let annotation = MKPointAnnotation()
////        annotation.coordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
////        annotation.title = "My Location"
//          mapView.addAnnotation(annotation)
//    }


//Function for annotation
//extension mainScreenViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let currentLocation = locations.last else {return}
//        print(locations)
//        let radiousInMeter: CLLocationDistance = 1000
//        let region = MKCoordinateRegion(center: currentLocation.coordinate,
//                                        latitudinalMeters: radiousInMeter,
//                                        longitudinalMeters: radiousInMeter)
//        mapView.setRegion(region, animated: true)
//
////        let annotation = MyAnnotation(coordinate: currentLocation.coordinate,
////                                      title: "My Location",
////                                      subtitle: "\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.latitude)")
////            annotation.coordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
////        mapView.addAnnotation(annotation)
//        addAnnotation(currentLocation: currentLocation)
//}}

//Function for default location load
//    private func setupMap(){
//        let location = CLLocation(latitude: 43.0130, longitude: -81.1994)
//        let radiousInMeter: CLLocationDistance = 1000
//        let region = MKCoordinateRegion(center: location.coordinate,
//                                        latitudinalMeters: radiousInMeter,
//                                        longitudinalMeters: radiousInMeter)
//        mapView.setRegion(region, animated: true)
//    }
