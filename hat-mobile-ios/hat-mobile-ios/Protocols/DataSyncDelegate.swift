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

// MARK: Protocol

/// used to provide feedback while syncing data
public protocol DataSyncDelegate: class {
    
    // MARK: - Protocol's functions
    
    /**
     DataSyncDelegate
     */
    func onDataSyncFeedback(_ isSuccess: Bool, message: String)
}
