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
import MessageUI

// MARK: Class

/// A class responsible for the more tab in the tab bar controller
class MoreTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["PHATA"], ["Storage Info", "Change Password"], ["Show Data", "Location Settings"], ["Release Notes", "Rumpel Terms of Service", "HAT Terms of Service"], ["Report Problem", "Log Out", "Version"]]
    /// The headers of the table view
    private let headers: [String] = ["PHATA", "HAT", "Location", "About", ""]
    /// The footers of the table view
    private let footers: [String] = []
    
    /// The file url, used to show the pdf file for terms of service
    private var fileURL: String?
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the table view
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view methods

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath)

        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.performSegue(withIdentifier: "phataSegue", sender: self)
        } else if indexPath.section == 1 {
            
            if indexPath.row == 1 {
                
                self.performSegue(withIdentifier: "moreToResetPasswordSegue", sender: self)
            }
        } else if indexPath.section == 2 {
            
            if self.sections[indexPath.section][indexPath.row] == "Show Data" {
                
                self.performSegue(withIdentifier: "dataSegue", sender: self)
            } else if self.sections[indexPath.section][indexPath.row] == "Location Settings" {
                
                self.performSegue(withIdentifier: "locationsSettingsSegue", sender: self)
            }
        } else if indexPath.section == 3 {
            
            if self.sections[indexPath.section][indexPath.row] == "Rumpel Terms of Service" {
                
                self.fileURL = (Bundle.main.url(forResource: "Rumpel Lite iOS Application Terms of Service", withExtension: "pdf", subdirectory: nil, localization: nil)?.absoluteString)!
                self.performSegue(withIdentifier: "moreToTermsSegue", sender: self)
            } else if self.sections[indexPath.section][indexPath.row] == "HAT Terms of Service" {
                
                self.fileURL = (Bundle.main.url(forResource: "2.1 HATTermsofService v1.0", withExtension: "pdf", subdirectory: nil, localization: nil)?.absoluteString)!
                self.performSegue(withIdentifier: "moreToTermsSegue", sender: self)
            }
        } else if indexPath.section == 4 {
            
            if self.sections[indexPath.section][indexPath.row] == "Report Problem" {
                
                if MFMailComposeViewController.canSendMail() {
                    
                    // create mail view controler
                    let mailVC = MFMailComposeViewController()
                    mailVC.mailComposeDelegate = self
                    mailVC.setToRecipients(["contact@hatdex.org"])
                    
                    // present view controller
                    self.present(mailVC, animated: true, completion: nil)
                } else {
                    
                    self.createClassicOKAlertWith(alertMessage: "This device has not been configured to send emails", alertTitle: "Email services disabled", okTitle: "ok", proceedCompletion: {})
                }
            } else if self.sections[indexPath.section][indexPath.row] == "Log Out" {
                
                TabBarViewController.logoutUser(from: self)
            }
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section < self.footers.count {
            
            return self.footers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]

        if indexPath.section == 0 {
            
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.textColor = .black
            cell.isUserInteractionEnabled = true
        } else if indexPath.section == 1 {
            
            cell.textLabel?.textColor = .black
            
            cell.accessoryType = .none
            
            cell.isUserInteractionEnabled = true
            
            if self.sections[indexPath.section][indexPath.row] == "Storage Info" {
                
                cell.textLabel?.textColor = .lightGray
                cell.isUserInteractionEnabled = false
                
                let userDomain = HATAccountService.TheUserHATDomain()
                let userToken = HATAccountService.getUsersTokenFromKeychain()
                cell.textLabel?.text = "Getting storage info..."
                HATService.getSystemStatus(userDomain: userDomain, authToken: userToken, completion: self.updateSystemStatusLabel(cell: cell), failCallBack: {error in
                    
                    cell.textLabel?.text = "Unable to get storage info"
                    _ = CrashLoggerHelper.JSONParsingErrorLog(error: error)
                })
            } else if self.sections[indexPath.section][indexPath.row] == "Change Password" {
                
                cell.accessoryType = .disclosureIndicator
            }
        } else if indexPath.section == 2 {
            
            cell.textLabel?.textColor = .black
            
            cell.accessoryType = .disclosureIndicator
            
            cell.isUserInteractionEnabled = true
        } else if indexPath.section == 3 {
            
            cell.textLabel?.textColor = .black
            
            cell.accessoryType = .disclosureIndicator
            
            cell.isUserInteractionEnabled = true
        } else if indexPath.section == 4 {
            
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = true
            
            if self.sections[indexPath.section][indexPath.row] == "Report Problem" {
                
                cell.textLabel?.textColor = .tealColor()
            } else if self.sections[indexPath.section][indexPath.row] == "Log Out" {
                
                cell.textLabel?.textColor = .red
            } else if self.sections[indexPath.section][indexPath.row] == "Version" {
                
                cell.textLabel?.textColor = .lightGray
                cell.isUserInteractionEnabled = false
                
                // app version
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    
                    cell.textLabel?.text = "Version " + version
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Update system status
    
    func updateSystemStatusLabel(cell: UITableViewCell) -> (([HATSystemStatusObject], String?) -> Void) {
        
        return { (systemStatusFile, renewedUserToken) in
        
            if systemStatusFile.count > 0 {
                
                let totalSpaceAvailable = systemStatusFile[2].kind.metric + " " + systemStatusFile[2].kind.units!
                let usedSpace = String(describing: Int(Float(systemStatusFile[4].kind.metric)!)) + " " + systemStatusFile[4].kind.units!
                let freeSpace = (Float(systemStatusFile[2].kind.metric)! * 1024) - Float(systemStatusFile[4].kind.metric)!.rounded()
                
                if freeSpace < 1024 {
                    
                    cell.textLabel?.text = "\(usedSpace) / \(totalSpaceAvailable) (\(Int(freeSpace)) MB available)"
                } else {
                    
                    let formattedFreeSpace = floor((freeSpace / 1024) / 0.01) * 0.01
                    cell.textLabel?.text = "\(usedSpace) / \(totalSpaceAvailable) (\(formattedFreeSpace) GB available)"
                }
            }
            
            // refresh user token
            if renewedUserToken != nil {
                
                _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: renewedUserToken!)
            }
        }
    }
    
    // MARK: - Mail View controller methods
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moreToTermsSegue" && self.fileURL != nil {
            
            // pass data to next view
            let termsVC = segue.destination as! TermsAndConditionsViewController
            
            termsVC.filePathURL = self.fileURL!
        }
    }
    
}