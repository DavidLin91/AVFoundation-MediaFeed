//
//  MediaCell.swift
//  AVFoundation-MediaFeed
//
//  Created by David Lin on 4/13/20.
//  Copyright © 2020 David Lin. All rights reserved.
//

import UIKit

class MediaCell: UICollectionViewCell {
    @IBOutlet weak var mediaImageView: UIImageView!
    
    public func configureCell(for mediaObject: MediaObject) {
        if let imageData = mediaObject.imageData  {
            // converts Data object
            mediaImageView.image = UIImage(data: imageData)
        }
        
        //TODO: Create a video preview thumbnail
        if let videoURL = mediaObject.videoURL {
            let image = videoURL.videoPreviewThumbnail() ?? UIImage(systemName: "heart")
            mediaImageView.image = image
        }
        
    }
}
