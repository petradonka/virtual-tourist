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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    private var tappedPin: Pin?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showExistingPins()
        restoreMapState()
    }

    @IBAction func longPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let location = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)

            if let pin = savePin(atLocation: location) {
                mapView.addAnnotation(pin.annotation)
                showAlbum(forPin: pin)
            }
        }
    }

    func showAlbum(forPin pin: Pin) {
        tappedPin = pin
        performSegue(withIdentifier: "showAlbumSegue", sender: self)
    }

    func showExistingPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let pins = try SharedPersistentContainer.viewContext.fetch(fetchRequest)
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(pins.map({ $0.annotation }))
        } catch (let error) {
            print(error)
        }
    }

    func savePin(atLocation location: CLLocationCoordinate2D) -> Pin? {
        let viewContext = SharedPersistentContainer.viewContext

        let pin = Pin.init(entity: Pin.entity(), insertInto: viewContext)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        SharedPersistentContainer.saveContext()

        SharedPersistentContainer.persistentContainer.performBackgroundTask { context in
            pin.downloadPhotos(inViewContext: context) { error in
                guard error == nil else {
                    self.handleError(error!)
                    return
                }
                try? context.save()
            }
        }
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

    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState(withRegion: mapView.region)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PinAnnotation {
            let identifier = "pinAnnotation"

            if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequedView.annotation = annotation
                return dequedView
            } else {
                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                return view
            }
        } else {
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? PinAnnotation {
            showAlbum(forPin: annotation.pin)
        }
    }

}
