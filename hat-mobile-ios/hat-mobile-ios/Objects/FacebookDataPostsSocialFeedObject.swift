/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import SwiftyJSON

// MARK: Class

/// A class representing the actual data of the post
class FacebookDataPostsSocialFeedObject {
    
    // MARK: - Variables

    /// The user that made the post
    var from: FacebookDataPostsFromSocialFeedObject = FacebookDataPostsFromSocialFeedObject()

    /// The privacy settings for the post
    var privacy: FacebookDataPostsPrivacySocialFeedObject = FacebookDataPostsPrivacySocialFeedObject()
    
    /// The updated time of the post
    var updatedTime: Date? = nil
    /// The created time of the post
    var createdTime: Date? = nil
    
    /// The message of the post
    var message: String = ""
    /// The id of the post
    var id: String = ""
    /// The status type of the post
    var statusType: String = ""
    /// The type of the post, status, video, image, etc,
    var type: String = ""

    /// The full picture url
    var fullPicture: String = ""
    /// If the post has a link to somewhere has the url
    var link: String = ""
    /// The picture url
    var picture: String = ""
    /// The story of the post
    var story: String = ""
    /// The name of the post
    var name: String = ""
    /// The description of the post
    var description: String = ""
    /// The object id of the post
    var objectID: String = ""
    /// The caption of the post
    var caption: String = ""
    
    /// The application details of the post
    var application: FacebookDataPostsApplicationSocialFeedObject = FacebookDataPostsApplicationSocialFeedObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        from = FacebookDataPostsFromSocialFeedObject()
        id = ""
        statusType = ""
        privacy = FacebookDataPostsPrivacySocialFeedObject()
        updatedTime = nil
        type = ""
        createdTime = nil
        message = ""
        
        fullPicture = ""
        link = ""
        picture = ""
        story = ""
        name = ""
        description = ""
        objectID = ""
        application = FacebookDataPostsApplicationSocialFeedObject()
        caption = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempFrom = dictionary["from"]?.dictionaryValue {
            
            from = FacebookDataPostsFromSocialFeedObject(from: tempFrom)
        }
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
        if let tempStatusType = dictionary["status_type"]?.stringValue {
            
            statusType = tempStatusType
        }
        if let tempPrivacy = dictionary["privacy"]?.dictionaryValue {
            
            privacy = FacebookDataPostsPrivacySocialFeedObject(from: tempPrivacy)
        }
        if let tempUpdateTime = dictionary["updated_time"]?.stringValue {
            
            updatedTime = FormatterHelper.formatStringToDate(string: tempUpdateTime)
        }
        if let tempType = dictionary["type"]?.stringValue {
            
            type = tempType
        }
        if let tempCreatedTime = dictionary["created_time"]?.stringValue {
            
            createdTime = FormatterHelper.formatStringToDate(string: tempCreatedTime)
        }
        if let tempMessage = dictionary["message"]?.stringValue {
            
            message = tempMessage
        }
        
        if let tempFullPicture = dictionary["full_picture"]?.stringValue {
            
            fullPicture = tempFullPicture
        }
        if let tempLink = dictionary["link"]?.stringValue {
            
            link = tempLink
        }
        if let tempPicture = dictionary["picture"]?.stringValue {
            
            picture = tempPicture
        }
        if let tempStory = dictionary["story"]?.stringValue {
            
            story = tempStory
        }
        if let tempDescription = dictionary["description"]?.stringValue {
            
            description = tempDescription
        }
        if let tempName = dictionary["name"]?.stringValue {
            
            name = tempName
        }
        if let tempObjectID = dictionary["object_id"]?.stringValue {
            
            objectID = tempObjectID
        }
        if let tempApplication = dictionary["application"]?.dictionaryValue {
            
            application = FacebookDataPostsApplicationSocialFeedObject(from: tempApplication)
        }
        if let tempCaption = dictionary["caption"]?.stringValue {
            
            caption = tempCaption
        }
    }
}
