//
//  NotablesData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

// MARK: Struct

/// A struct representing the notables table received from JSON
struct NotablesData {
    
    // MARK: - Variables
    
    /// the author data
    var authorData: AuthorData
    /// creation date
    var createdTime: Date
    /// if true this note is shared to facebook etc.
    var shared: Bool
    /// If shared, where is it shared? Coma seperated string (don't know if it's optional or not)
    var sharedOn: String
    /// the photo data
    var photoData: PhotoData
    /// the location data
    var locationData: LocationData
    /// the actual message of the note
    var message: String
    /// the date until this note will be public (don't know if it's optional or not)
    var publicUntil: Date
    /// the updated time of the note
    var updatedTime: Date
    /// the kind of the note. 3 types available note, blog or list
    var kind: String
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        authorData = AuthorData.init()
        createdTime = Date()
        shared = false
        sharedOn = ""
        photoData = PhotoData.init()
        locationData = LocationData.init()
        message = ""
        publicUntil = Date()
        updatedTime = Date()
        kind = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {

        // the tables are optional fields in the json so init them and check if they exist in our json
        authorData = AuthorData.init()
        photoData = PhotoData.init()
        locationData = LocationData.init()
        sharedOn = ""
        publicUntil = Date()
        createdTime = Date()
        shared = false
        sharedOn = ""
        message = ""
        updatedTime = Date()
        kind = ""
        
        if let tempAuthorData = dict["authorv1"]?.dictionary {
            
             authorData = AuthorData.init(dict: tempAuthorData)
        }
        
        if let tempPhotoData = dict["photov1"]?.dictionaryObject {
            
            photoData = PhotoData.init(dict: tempPhotoData as! Dictionary<String, String>)
        }
        
        if let tempLocationData = dict["locationv1"]?.dictionary {
            
            locationData = LocationData.init(dict: tempLocationData)
        }
        
        // init optional values to default values and then assign the value if found in JSON
        sharedOn = ""
        publicUntil = Date()
        
        if let tempSharedOn = dict["shared_on"]?.string {
            
            sharedOn = tempSharedOn
        }
        
        if let tempPublicUntil = dict["public_until"]?.string {
            
            publicUntil = FormatterHelper.formatStringToDate(string: tempPublicUntil)
        }
        
        if let tempCreatedTime = dict["created_time"]?.string {
            
            createdTime = FormatterHelper.formatStringToDate(string: tempCreatedTime)
        }

        if let tempDict = dict["shared"]?.string {
            
            if tempDict == "" {
                
                shared = false
            } else {
                
                if let boolShared = Bool(tempDict) {
                    
                    shared = boolShared
                }
            }
        }
        
        if let tempMessage = dict["message"]?.string {
            
            message = tempMessage
        }
        
        if let tempKind = dict["kind"]?.string {
            
            kind = tempKind
        }
    }
}
