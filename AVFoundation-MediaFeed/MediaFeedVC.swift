//
//  ViewController.swift
//  AVFoundation-MediaFeed
//
//  Created by David Lin on 4/13/20.
//  Copyright © 2020 David Lin. All rights reserved.
//

import UIKit
import AVFoundation  // video playback is done on a CALayer - all views are backed by a CALayer e.g.if we want to make a view rounded we can only do this using the CALayer of that view e.g. someView
import AVKit // video playback is done using the AVPlayerViewController


class MediaFeedVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
        let pickerController = UIImagePickerController()
        pickerController.mediaTypes = mediaTypes ?? ["kUTTypeImage"]
        pickerController.delegate = self
        return pickerController
    }()
    
    
    private var mediaObjects = [MediaObject]() {
        didSet { // property observer
            collectionView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCV()
        
        // disable video button if camera is not available
             if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                 videoButton.isEnabled = false
             }
             
    }
    
    private func configureCV() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    

    @IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    @IBAction func photoLibraryButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    
    
    private func playRandomVideo() {
        // we want all non-nill media objects from the media object array
        // compact map - it removes all non nill values
        let videoURLs = mediaObjects.compactMap { $0.videoURL }
        
        // get a random video URL
        if let videoURL = videoURLs.randomElement() {
            let player = AVPlayer(url: videoURL)
            
        // create a sublayer
        let playerLayer = AVPlayerLayer(player: player)
            
        // set it's frame
            playerLayer.frame = view.bounds  // takes up the entire header view
            
            // set video aspect ratio
            playerLayer.videoGravity = .resizeAspect
            
            // remove all sublayers from headerView
            view.layer.sublayers?.removeAll()
            
            // add the playerLayer to the headerView's layer
            view.layer.addSublayer(playerLayer)
            
            // play video
            player.play()
            
            
        }
    }
    
    
}

// MARK: UICollectionView Datasource Methods

extension MediaFeedVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
            fatalError("could not dequeue a MediaCell")
        }
        let mediaObject = mediaObjects[indexPath.row]
        cell.configureCell(for: mediaObject)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
            fatalError("could not dequeue")
        }
        return headerView
    }
}


// MARK: UICollectionView Delegate Methods

extension MediaFeedVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediaObject = mediaObjects[indexPath.row]
        guard let videoURL = mediaObject.videoURL else {
            return
        }
        let playerVC = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        playerVC.player = player
        present(playerVC, animated: true) {
            // play video automatically
            player.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize: CGSize = UIScreen.main.bounds.size // max width & height of current device
        let itemWidth: CGFloat = maxSize.width
        let itemHeight: CGFloat = maxSize.height * 0.40
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    // size for header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height * 0.40)
    }
    
    
}

extension MediaFeedVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // info dictionary keys
        // InfoKey.originalImage - UIImage
        // InfoKey.mediaType - String
        // Infokey.mediaURL - URL
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            return
        }
        
        switch mediaType {
        case "public.image":
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = originalImage.jpegData(compressionQuality: 1.0) {
                let mediaObject = MediaObject(imageData: imageData, videoURL: nil, caption: nil)
                mediaObjects.append(mediaObject) // 0 => 1
            }
            break
        case "public.movie":
            if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                print("mediaURL: \(mediaURL)")
                let mediaObject = MediaObject(imageData: nil, videoURL: mediaURL, caption: nil)
                mediaObjects.append(mediaObject)
            }
        default:
            print("Unsupported media typed")
        }
        
        print("mediaType: \(mediaType)") // "public.video" , "public.image"
        picker.dismiss(animated: true)
    }
}
