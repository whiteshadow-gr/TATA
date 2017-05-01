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

import HatForIOS

// MARK: Class

/// A class responsible for the profile info UITableViewController of the PHATA section
class ProfileInfoTableViewController: UITableViewController {
    
    // MARK: - Variables

    /// The sections of the table view
    private let sections: [[String]] = [["Age"], ["Gender"], ["Birth"]]
    /// The headers of the table view
    private let headers: [String] = ["Age", "Gender", "Birth"]
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    /// User's domain
    private let userDomain = HATAccountService.TheUserHATDomain()
    /// User's token
    private let userToken = HATAccountService.getUsersTokenFromKeychain()
    
    /// User's profile passed on from previous view controller
    var profile: HATProfileObject? = nil
    
    // MARK: - IBAction
    
    /**
     Sends the profile data to hat
     
     - parameter sender: The object that calls this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.darkView = UIView(frame: self.tableView.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30), color: .tealColor(), cornerRadius: 15, in: self.view, with: "Updating profile...", textColor: .white, font: UIFont(name: "OpenSans", size: 12)!)
        
        for (index, _) in self.headers.enumerated() {
            
            var cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? PhataTableViewCell
            
            if cell == nil {
                
                let indexPath = IndexPath(row: 0, section: index)
                cell = tableView.dequeueReusableCell(withIdentifier: "profileInfoCell", for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
            }
            
            // age
            if index == 0 {
                
                profile?.data.age.group = cell!.textField.text!
                profile?.data.age.isPrivate = !((cell?.privateSwitch.isOn)!)
            // gender
            } else if index == 1 {
                
                profile?.data.gender.type = cell!.textField.text!
                profile?.data.gender.isPrivate = !((cell?.privateSwitch.isOn)!)
            // birth
            } else if index == 2 {
                
                profile?.data.birth.date = cell!.textField.text!
                profile?.data.birth.isPrivate = !((cell?.privateSwitch.isOn)!)
            }
        }
        
        func tableExists(dict: Dictionary<String, Any>, renewedUserToken: String?) {
            
            HATAccountService.postProfile(userDomain: userDomain, userToken: userToken, hatProfile: self.profile!, successCallBack: {
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                _ = self.navigationController?.popViewController(animated: true)
            }, errorCallback: {error in
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                self.createClassicOKAlertWith(alertMessage: "There was an error posting profile", alertTitle: "Error", okTitle: "OK", proceedCompletion: {})
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            })
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: tableExists, errorCallback: {error in
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            self.createClassicOKAlertWith(alertMessage: "There was an error checking if it's possible to post the data", alertTitle: "Error", okTitle: "OK", proceedCompletion: {})
            
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
        })
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfoCell", for: indexPath) as! PhataTableViewCell
        
        return self.setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.headers[section]
    }
    
    // MARK: - Set up cell
    
    /**
     Updates and formats the cell accordingly
     
     - parameter cell: The PhataTableViewCell to update and format
     - parameter indexPath: The indexPath of the cell
     
     - returns: A UITableViewCell cell already updated and formatted accordingly
     */
    private func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            var array: [String] = []
            for i in 13...100 {
                
                array.append(String(describing: i))
            }
            cell.dataSourceForPickerView = array
            cell.textField.text = self.profile?.data.age.group
            cell.privateSwitch.isOn = !(self.profile?.data.age.isPrivate)!
            cell.tag = 0
        } else if indexPath.section == 1 {
            
            let array: [String] = ["", "Male", "Female", "Other"]
            cell.dataSourceForPickerView = array
            cell.textField.text = self.profile?.data.gender.type
            cell.privateSwitch.isOn = !(self.profile?.data.gender.isPrivate)!
            cell.tag = 1
        } else if indexPath.section == 2 {
            
            if self.profile?.data.birth.date != nil {
                
                cell.textField.text = self.profile?.data.birth.date
            }
            cell.privateSwitch.isOn = !(self.profile?.data.birth.isPrivate)!
            cell.tag = 2
        }
        
        return cell
    }

}