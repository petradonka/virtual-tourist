//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 02.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var bottomToolbar: UIToolbar!

    var pin: Pin!

    override func viewDidLayoutSubviews() {
        setupFlowLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomToolbar.frame.size.height, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset

        print(pin)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "photoCell", for: indexPath)
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "headerView",
                                                                             for: indexPath)
            return headerView
        default:
            assert(false, "Unexpected element kind")
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

}
