//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 02.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!

    @IBOutlet weak var noPhotosLabel: UILabel!

    var pin: Pin!

    var fetchedResultsController: NSFetchedResultsController<Photo>!

    var persistentContainer: NSPersistentContainer {
        get {
            return SharedPersistentContainer.persistentContainer
        }
    }

    override func viewDidLayoutSubviews() {
        setupFlowLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomToolbar.frame.size.height, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }

    override func viewDidLoad() {
        initializeFetchedResultsController()
        noPhotosLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        newCollectionButton.isEnabled = !pin.loading
        noPhotosLabel.isHidden = true

        pin.downloadMissingPhotos { error in
            guard error == nil else {
                self.handleError(error!)
                return
            }

            SharedPersistentContainer.saveContext()
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = !self.pin.loading
                self.noPhotosLabel.isHidden = self.pin.photos!.count > 0 || self.pin.loading
            }
        }
    }

    @IBAction func downloadNewPhotos(_ sender: Any) {
        newCollectionButton.isEnabled = false
        noPhotosLabel.isHidden = true
        SharedPersistentContainer.persistentContainer.performBackgroundTask { context in
            self.pin.downloadPhotos(inViewContext: context) { error in
                guard error == nil else {
                    self.handleError(error!)
                    return
                }

                try? context.save()
                DispatchQueue.main.async {
                    self.newCollectionButton.isEnabled = !self.pin.loading
                    self.noPhotosLabel.isHidden = self.pin.photos!.count > 0
                }
            }
        }
    }

    func initializeFetchedResultsController() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "imageUrlString", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        let moc = persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func setupFlowLayout() {
        let space: CGFloat = 1

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = calculateFlowLayoutItemSize(withSpacing: space)
        flowLayout.sectionHeadersPinToVisibleBounds = true
    }

    private func calculateFlowLayoutItemSize(withSpacing space: CGFloat) -> CGSize {
        let approximateItemMinSize: CGFloat
        if let smallerScreenSide = [view.frame.size.width, view.frame.size.height].min() {
            approximateItemMinSize = smallerScreenSide / 3
        } else {
            approximateItemMinSize = 120
        }

        let rowLength = view.frame.size.width
        let numberOfItemsInRow: CGFloat = (rowLength / approximateItemMinSize).rounded()
        let allSpacingInRow = (numberOfItemsInRow - 1) * space
        let itemDimension = (rowLength - allSpacingInRow) / numberOfItemsInRow

        return CGSize(width: itemDimension, height: itemDimension)
    }

    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard fetchedResultsController.sections?.count ?? 0 > indexPath.section,
            let section = fetchedResultsController.sections?[indexPath.section],
            section.objects?.count ?? 0 > indexPath.row else {
                print("cell index out of bounds")
                return
        }

        let photo = fetchedResultsController.object(at: indexPath)
        SharedPersistentContainer.viewContext.delete(photo)
        SharedPersistentContainer.saveContext()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "photoCell", for: indexPath)

        guard fetchedResultsController.sections?.count ?? 0 > indexPath.section,
            let section = fetchedResultsController.sections?[indexPath.section],
            section.objects?.count ?? 0 > indexPath.row else {
                print("cell index out of bounds")
                return cell
        }

        if let cell = cell as? PhotoCollectionViewCell {
            let photo = fetchedResultsController.object(at: indexPath)
            if (photo.loading) {
                cell.loadingIndicator.startAnimating()
            } else {
                cell.loadingIndicator.stopAnimating()
            }
            cell.imageView.image = photo.image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
        UICollectionReusableView {
            switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: "headerView",
                                                                                 for: indexPath) as! MapHeaderCollectionReusableView

                let delta = 0.2

                let center = CLLocationCoordinate2D.init(latitude: pin.latitude, longitude: pin.longitude)
                let span = MKCoordinateSpan.init(latitudeDelta: delta, longitudeDelta: delta)

                let region = MKCoordinateRegion.init(center: center, span: span)
                headerView.mapView.setRegion(region, animated: true);
                headerView.mapView.addAnnotation(pin.annotation)
                return headerView
            default:
                assert(false, "Unexpected element kind")
            }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        default:
            collectionView.reloadData()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        newCollectionButton.isEnabled = !pin.hasMissingPhotos
        noPhotosLabel.isHidden = pin.photos!.count > 0 || pin.loading
    }
    
}
