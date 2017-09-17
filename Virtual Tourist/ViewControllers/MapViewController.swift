//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 02.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    private var tappedPin: Pin?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showExistingPins()
        restoreMapState()
    }

    @IBAction func longPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .ended) {
            let location = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)

            if let pin = savePin(atLocation: location) {
                mapView.addAnnotation(pin.annotation)
                showAlbum(forPin: pin)
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState(withRegion: mapView.region)
    }

    func showAlbum(forPin pin: Pin) {
        tappedPin = pin
        performSegue(withIdentifier: "showAlbumSegue", sender: self)
    }

    func showExistingPins() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("No app delegate")
            return
        }

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let pins = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            mapView.addAnnotations(pins.map({ $0.annotation }))
        } catch (let error) {
            print(error)
        }
    }

    func savePin(atLocation location: CLLocationCoordinate2D) -> Pin? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("No app delegate")
            return nil
        }

        let viewContext = appDelegate.persistentContainer.viewContext

        let pin = Pin.init(entity: Pin.entity(), insertInto: viewContext)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        appDelegate.saveContext()
        return pin
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoAlbumViewController = segue.destination as? PhotoAlbumViewController, segue.identifier == "showAlbumSegue" {
            guard let tappedPin = tappedPin else {
                print("No tapped pin?")
                return
            }
            photoAlbumViewController.pin = tappedPin
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PinAnnotation {
            let identifier = "pinAnnotation"

            if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequedView.annotation = annotation
                return dequedView
            } else {
                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return view
            }
        } else {
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PinAnnotation {
            showAlbum(forPin: annotation.pin)
        }
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

        if latitude != 0 && longitude != 0 {
            let latitudeDelta = UserDefaults.standard.double(forKey: "savedMapRegion.latitudeDelta")
            let longitudeDelta = UserDefaults.standard.double(forKey: "savedMapRegion.longitudeDelta")

            let center = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)

            let region = MKCoordinateRegion.init(center: center, span: span)
            mapView.setRegion(region, animated: true);
        }
    }

}
