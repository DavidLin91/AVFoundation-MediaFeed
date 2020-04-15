//
//  CoreDataManager.swift
//  AVFoundation-MediaFeed
//
//  Created by David Lin on 4/14/20.
//  Copyright © 2020 David Lin. All rights reserved.
//

import UIKit
import CoreData


class CoreDataManager {
    
    // creating a singleton
    private init() {}
    static let shared = CoreDataManager()
    
    private var mediaObjects = [CDMediaObject]()
    
    // get instance of the NSManageObjectContext from AppDelegate
    private let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    
    // NSManagerObjectContext does saving, fetching on NSManagedObject..
    
    //CRUD - create
    
    
    func createMediaObject(_ imageData: Data, videoURL: URL?) -> CDMediaObject {
        let mediaObject = CDMediaObject(entity: CDMediaObject.entity(), insertInto: context)
        mediaObject.createdDate = Date() // current date
        mediaObject.id = UUID().uuidString  // unique string
        mediaObject.imageData = imageData // both media and image objects has an image
        mediaObject.videoData = Data()
        
        if let videoURL = videoURL {
            //if exists, means its a media object
            // convert a URL to data
            do {
                mediaObject.videoData = try Data(contentsOf: videoURL)
            } catch {
                print("failed to convert URL to data object with error : \(error)")
            }
        }
        
        // save the newly created media object entity instance to the NSManagedObjectContext
        
        do {
            try context.save()
        } catch {
            print("failed to created newly created media object with error : \(error)")
        }
        return mediaObject
        
    }
    
    //Read
    
    func fetchMediaObject() -> [CDMediaObject] {
        do {
            mediaObjects = try context.fetch(CDMediaObject.fetchRequest())
            // fetch all the created media objects from CDMediaObject entity
        } catch {
            print("failed to fetch mediaobjects with error: \(error)")
        }
        return mediaObjects
    }
    
    
    // Update
    
    
    // Delete
    
    
    
    
}
