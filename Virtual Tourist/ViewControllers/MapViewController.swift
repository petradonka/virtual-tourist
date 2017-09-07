//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 02.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    private var tappedAlbumIdentifier: String?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreMapState()
    }

    @IBAction func longPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .ended) {
            let location = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            
            dropPin(atLocation: location);
//            showAlbum(withIdentifier: "\(location.latitude), \(location.longitude)")
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState(withRegion: mapView.region)
    }

    func showAlbum(withIdentifier albumIdentifier: String) {
        tappedAlbumIdentifier = albumIdentifier
        performSegue(withIdentifier: "showAlbumSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoAlbumViewController = segue.destination as? PhotoAlbumViewController, segue.identifier == "showAlbumSegue" {
            guard let albumIdentifier = tappedAlbumIdentifier else {
                print("There was no album identifier set. Can not open album")
                return
            }
            photoAlbumViewController.albumIdentifier = albumIdentifier
        }
    }

    private func dropPin(atLocation location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation.init()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }

    private func saveMapState(withRegion region: MKCoordinateRegion) {
        UserDefaults.standard.set(region.center.latitude, forKey: "savedMapRegion.latitude")
        UserDefaults.standard.set(region.center.longitude, forKey: "savedMapRegion.longitude")
        UserDefaults.standard.set(region.span.latitudeDelta, forKey: "savedMapRegion.latitudeDelta")
        UserDefaults.standard.set(region.span.longitudeDelta, forKey: "savedMapRegion.longitudeDelta")
    }

    private func restoreMapState() {
        let latitude = UserDefaults.standard.double(forKey: "savedMapRegion.latitude")
        let longitude = UserDefaults.standard.double(forKey: "savedMapRegion.longitude")

        if latitude > 0 && longitude > 0 {
            let latitudeDelta = UserDefaults.standard.double(forKey: "savedMapRegion.latitudeDelta")
            let longitudeDelta = UserDefaults.standard.double(forKey: "savedMapRegion.longitudeDelta")

            let center = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)

            let region = MKCoordinateRegion.init(center: center, span: span)
            mapView.setRegion(region, animated: true);
        }
    }

}
