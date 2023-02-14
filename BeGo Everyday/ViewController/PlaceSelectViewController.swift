//
//  PlaceSelectViewController.swift
//  BeGo Everyday
//
//  Created by yoonbumtae on 2023/02/11.
//

import UIKit
import MapKit
import SPAlert

class PlaceSelectViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCoordinate: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let locationManager = GPSLocationManager()
    private var currentLocation: CLLocationCoordinate2D!
    private var isFoundLocation = false
    private var lastAddedAnnotation: MKPointAnnotation?
    private var currentLocationAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch locationManager.authStatus {
        case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
            locationManager.instantStartUpdatingLocation(delegateTo: self)
        case .restricted:
            break
        case .denied:
            break
        @unknown default:
            break
        }
        
        mapView.delegate = self
        loadUserCoordinate()
        mapView.setZoomByDelta(delta: pow(2, -13), animated: true)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressMapEndLocation))
        mapView.addGestureRecognizer(longPressGesture)
        
        // mapView.setCenter(CLLocationCoordinate2D(latitude: 36.6769, longitude: 126.8486), animated: false)
        
        searchBar.delegate = self
    }
    
    @IBAction func btnActMoveCurrentLocation(_ sender: UIButton) {
        guard let currentLocation = currentLocation else {
            return
        }
        
        mapView.setCenter(currentLocation, animated: true)
    }
    
    @IBAction func btnActGoSelectedPlace(_ sender: UIButton) {
        guard let lastAddedAnnotation = lastAddedAnnotation else {
            return
        }
        
        mapView.setCenter(lastAddedAnnotation.coordinate, animated: true)
    }
    
    @IBAction func btnActResetAllRecords(_ sender: UIButton) {
        // UserDefaults.standard.set([], forKey: APP_OPEN_DATES)
        SPAlert.present(title: "NO", preset: .error, haptic: .error)
    }
    
    
    @objc func longPressMapEndLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            // Add annotation:
            if let lastAddedAnnotation = lastAddedAnnotation {
                mapView.removeAnnotation(lastAddedAnnotation)
            }
            
            lastAddedAnnotation = addAnnotation(coordinate: coordinate, title: "Selected Place")
            saveUserCoordinate()
            updateCoordinateLabel()
            
            // https://developer.apple.com/forums/thread/126473
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, title: String) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
        
        return annotation
    }
    
    private func updateCoordinateLabel() {
        guard let coordinate = lastAddedAnnotation?.coordinate else {
            fatalError("No selected coordinate.")
        }
        
        let latitudeText = String(format: "%.4f", coordinate.latitude)
        let longitudeText = String(format: "%.4f", coordinate.longitude)
        let text = "위도(lat), 경도(lon): \(latitudeText), \(longitudeText)"
        
        lblCoordinate.text = text
    }
    
    private func loadUserCoordinate() {
        guard let coordinate = loadCoordFromUserDefaults() else {
            return
        }
        
        lastAddedAnnotation = addAnnotation(coordinate: coordinate, title: "Selected Place")
        updateCoordinateLabel()
        
        mapView.centerCoordinate = coordinate
    }
    
    private func saveUserCoordinate() {
        guard let lastAddedAnnotation = lastAddedAnnotation else {
            print(#function, "lastAddedAnnotation is nil.")
            return
        }
        
        let coordinate = lastAddedAnnotation.coordinate
        UserDefaults.standard.set("\(coordinate.latitude);\(coordinate.longitude)", forKey: SELECTED_COORDINATE)
    }
}

extension PlaceSelectViewController: MKMapViewDelegate {
    // MARK: - PlaceSelectViewController
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let title = annotation.title ?? nil, title == "Current Location" {
            // print(annotation.title)
            
            let annotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            annotationView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            annotationView.layer.cornerRadius = 10
            
            let label = OutlinedLabel(frame:  CGRect(x: 0, y: annotationView.frame.maxY + 2.5, width: 200, height: 20))
            label.text = title
            label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            label.outlineColor = .white
            label.outlineWidth = 3
            label.textColor = .black
            label.textAlignment = .center
            
            // let attrString = NSAttributedString(
            //     string: title,
            //     attributes: [
            //         .strokeColor: UIColor.white,
            //         .foregroundColor: UIColor.black,
            //         .strokeWidth: 2.0,
            //         .font: UIFont.systemFont(ofSize: 10.0, weight: .semibold)
            //     ]
            // )
            // label.attributedText = attrString
            
            label.sizeToFit()
            let newWidth = label.frame.width + 3
            label.frame = CGRect(
                x: annotationView.frame.midX - (newWidth / 2),
                y: label.frame.minY,
                width: newWidth,
                height: label.frame.height)
            annotationView.addSubview(label)
            
            return annotationView
        }

        return nil
    }
}

extension PlaceSelectViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        
        // 현재 위치 업데이트 (정보만)
        currentLocation = locValue
        if let currentLocationAnnotation = currentLocationAnnotation {
            mapView.removeAnnotation(currentLocationAnnotation)
        }
        currentLocationAnnotation = addAnnotation(coordinate: locValue, title: "Current Location")
        
        guard UserDefaults.standard.string(forKey: SELECTED_COORDINATE) == nil else {
            // print(#function, "Saved coordinate does exist.")
            return
        }
        
        guard !isFoundLocation else {
            return
        }
        
        // 현재 위치 업데이트 (지도)
        mapView.centerCoordinate = locValue
        isFoundLocation = true
    }
}

extension PlaceSelectViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
