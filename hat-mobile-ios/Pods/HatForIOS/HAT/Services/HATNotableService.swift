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
import Alamofire

// MARK: Class

/// A class about the methods concerning the Notables service
public class HATNotablesService: NSObject {

    // MARK: - Get Notes
    
    /**
     Checks if notables table exists
     
     - parameter authToken: The auth token from hat
     */
    public class func fetchNotables(userDomain: String, authToken: String, structure: Dictionary<String, Any>, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void, failure: @escaping () -> Void ) -> Void {
        
        func createNotablesTables(error: HATTableError) {
            
            switch error {
            case .tableDoesNotExist:
                
                HATAccountService.createHatTable(userDomain: userDomain, token: authToken, notablesTableStructure: structure, failed: {(error: HATTableError) -> Void in return})()
                
                failure()
            default:
                
                break
            }
        }
        
        HATAccountService.checkHatTableExists(userDomain: userDomain, tableName: "notablesv1",
            sourceName: "rumpel",
            authToken: authToken,
            successCallback: getNotes(userDomain: userDomain, token: authToken, parameters: parameters, success: success),
            errorCallback: createNotablesTables)
    }
    
    /**
     Gets the notes of the user from the HAT
     
     - parameter token: The user's token
     - parameter tableID: The table id of the notes
     */
    private class func getNotes (userDomain: String, token: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void {
        
        return { (tableID: NSNumber) -> Void in
            
            HATAccountService.getHatTableValues(token: token, userDomain: userDomain, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: showNotablesFetchError)
        }
    }
    
    /**
     Shows alert that the notes couldn't be fetched
     */
    public class func showNotablesFetchError(error: HATTableError) {
        
        // alert magic
    }
    
    // MARK: - Delete notes
    
    /**
     Deletes a note from the hat
     
     - parameter id: the id of the note to delete
     - parameter tkn: the user's token as a string
     */
    public class func deleteNoteWithKeychain(id: Int, tkn: String, userDomain: String) -> Void {
        
        HATAccountService.deleteHatRecord(userDomain: userDomain, token: tkn, recordId: id, success: self.completionDeleteNotesFunction, failed: {(HATTableError) -> Void in return})
    }
    
    /**
     Delete notes completion function
     
     - parameter token: The user's token as a string
     - returns: (_ r: Helper.ResultType) -> Void
     */
    public class func completionDeleteNotesFunction(token: String) -> Void {
        
        print(token)
    }
    
    // MARK: - Post note
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    public class func postNote(userDomain: String, userToken: String, appToken: String, noteAsJSON: Dictionary<String, Any>, successCallBack: @escaping () -> Void) -> Void {
        
        func posting(resultJSON: Dictionary<String, Any>) {
            
            // create the headers
            let headers = ["Accept": ContentType.JSON,
                           "Content-Type": ContentType.JSON,
                           "X-Auth-Token": userToken]
            
            // make async request
            ΗΑΤNetworkHelper.AsynchronousRequest("https://" + userDomain + "/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: noteAsJSON, headers: headers, completion: { (r: ΗΑΤNetworkHelper.ResultType) -> Void in
                
                // handle result
                switch r {
                    
                case .isSuccess(let isSuccess, _, _):
                    
                    if isSuccess {
                        
                        // reload table
                        successCallBack()
                        
                        HATAccountService.triggerHatUpdate(userDomain: userDomain, completion: {()})
                    }
                    
                case .error(let error, _):
                    
                    print("error res: \(error)")
                }
            })
        }
        
        func errorCall(error: HATTableError) {
            
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "notablesv1", sourceName: "rumpel", authToken: userToken, successCallback: posting, errorCallback: errorCall)
    }
    
    // MARK: - Remove duplicates
    
    /**
     Removes duplicates from an array of NotesData and returns the corresponding objects in an array
     
     - parameter array: The NotesData array
     - returns: An array of NotesData
     */
    public class func removeDuplicatesFrom(array: [HATNotesData]) -> [HATNotesData] {
        
        // the array to return
        var arrayToReturn: [HATNotesData] = []
        
        // go through each tweet object in the array
        for note in array {
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(note2: HATNotesData) -> Bool in
                
                if (note.data.createdTime == note2.data.createdTime) && (note.data.message == note2.data.message) {
                    
                    return true
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(note)
            }
        }
        
        for (outterIndex, note) in arrayToReturn.enumerated().reversed() {
            
            for (innerIndex, innerNote) in arrayToReturn.enumerated().reversed() {
                
                if outterIndex != innerIndex {
                    
                    if innerNote.data.createdTime == note.data.createdTime {
                        
                        if innerNote.lastUpdated != note.lastUpdated {
                            
                            if innerNote.lastUpdated > note.lastUpdated {
                                
                                arrayToReturn.remove(at: outterIndex)
                            } else {
                                
                                arrayToReturn.remove(at: innerIndex)
                            }
                        }
                    }
                }
            }
        }
        
        return HATNotablesService.sortNotables(notes: arrayToReturn)
    }
    
    // MARK: - Sort notables
    
    /**
     Sorts notes based on updated time
     
     - parameter notes: The NotesData array
     - returns: An array of NotesData
     */
    public class func sortNotables(notes: [HATNotesData]) -> [HATNotesData] {
        
        return notes.sorted{ $0.data.updatedTime > $1.data.updatedTime }
    }
}