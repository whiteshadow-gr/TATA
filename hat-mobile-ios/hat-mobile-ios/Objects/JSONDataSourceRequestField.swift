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

// MARK: Struct

/// The request field structure
class JSONDataSourceRequestField {
    
    // MARK: - Variables
    
    /// the ID of the object
    var id: Int = 0
    
    /// the name of the object
    var name: String = ""
    
    /// the fieldEnum of the object
    var fieldEnum: Constants.RequestFields = Constants.RequestFields.Latitude // give default for now
}
