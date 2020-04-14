//
//  MediaObject.swift
//  AVFoundation-MediaFeed
//
//  Created by David Lin on 4/13/20.
//  Copyright © 2020 David Lin. All rights reserved.
//

import Foundation

// media object instance can either be a video or image content
struct MediaObject {
    let imageData: Data?
    let videoURL: URL?
    let caption: String?  // UI so user can enter text
    let id = UUID().uuidString
    let createdDate = Date()
}
