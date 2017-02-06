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

/// A class representing the user's details that made the post
class FacebookDataPostsFromSocialFeedObject {
    
    // MARK: - Variables

    /// The user's name
    var name: String = ""
    /// The user's id
    var id: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        name = ""
        id = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempName = dictionary["name"]?.stringValue {
            
            name = tempName
        }
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
    }
}
