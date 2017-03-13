//
//  WalletTableViewController.swift
//  league-challenge
//
//  Created by Evan Cloutier on 2017-03-08.
//  Copyright © 2017 Evan Cloutier. All rights reserved.
//

import Foundation
import UIKit

class WalletTableViewController: UITableViewController {

    var cellDescriptors = [NSMutableDictionary]()
    var visibleRows = [Int]()
    var utilitySource = WalletUtilities()
    
    var backgroundColorPicker: [String] = ["#9575E1", "#8ADED7", "#F0A5CD", "#CDE575", "#F4D03F"]
    var backgroundColorIncrementor: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = UIApplication.shared.statusBarFrame.height
        
        initCellDescriptors(utility: utilitySource)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellDescriptor["cellIdentifier"] as! String, for: indexPath) as! WalletTableViewCell
        
        
        // Creating a foreground view with only the top two corners rounded
        let foregroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height))
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: foregroundView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        foregroundView.layer.mask = maskLayer
        foregroundView.backgroundColor = hexStringToUIColor(hex: backgroundColorPicker[backgroundColorIncrementor % backgroundColorPicker.count])
        
        cell.insertSubview(foregroundView, at: 0)
        
        // Creating a background that has the color of the previous card to produce the wallet-like effect
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height))
        
        // Take modulo to repeat over the backgroundColorPicker (unless it is the first card)
        backgroundView.backgroundColor = (backgroundColorIncrementor == 0) ? UIColor.white :
            hexStringToUIColor(hex: backgroundColorPicker[(backgroundColorIncrementor - 1) % backgroundColorPicker.count])
        
        // Increment the counter for the next cell
        backgroundColorIncrementor += 1

        cell.insertSubview(backgroundView, at: 0)
        
        let accountName = formatAccountName(name: cellDescriptor["accountName"]! as! String, row: indexPath.row)
        let accountBalance = formatAccountBalance(balance: String(describing: cellDescriptor["accountBalance"]!))
        let accountDates = formatAccountDates(start: cellDescriptor["accountStartDate"]! as! String, end: cellDescriptor["accountEndDate"]! as! String)
        
        cell.textAccount.text = accountName
        cell.textBalanceValue.text = accountBalance
        cell.textEffectiveDate.text = accountDates
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // MARK: - Custom Methods
    
    /*
        This method calls on the WalletUtility to retrieve the wallet information
        from the provided RAW data. Note that there is a default value passed in,
        as this method is stubbed for unit testing.
    */
    
    func initCellDescriptors(utility: WalletUtilities = WalletUtilities()) {
        utility.getWalletDetails { (data, error) in
            if (error == nil) {
                if (data?["info"] != nil) {
                    let dataInfo = data!["info"] as? NSDictionary
                    
                    if (dataInfo?.value(forKey: "message_type") as! String == "wallet") {
                        let cardDetails = dataInfo?["cards"] as? NSArray
                        
                        // Taking all of the cards within the response and formatting into cell descriptors
                        for card in cardDetails as! [AnyObject] {
                            
                            // Default values prevent act as a catch for any misformatted data
                            let accountName = card.value(forKey: "type") ?? "account_\(card.value(forKey: "id")!)"
                            let accountBalance = card.value(forKey: "amount") ?? 0.00
                            let accountCurrency = card.value(forKey: "currency") ?? "CAD"
                            let accountStartDate = card.value(forKey: "policy_start_date") ?? "2017-01-01T04:00:00Z"
                            let accountEndDate = card.value(forKey: "policy_end_date") ?? "2018-01-01-T04:00:00Z"
                            
                            let cellDescriptor = [
                                "cellIdentifier": "walletCell",
                                "isVisible": true,
                                "accountName": accountName,
                                "accountBalance": accountBalance,
                                "accountCurrency": accountCurrency,
                                "accountStartDate": accountStartDate,
                                "accountEndDate": accountEndDate,
                            ] as NSMutableDictionary
                            
                            self.cellDescriptors.append(cellDescriptor)
                        }
                    }
                    
                    // Use the main thread to update the tableView
                    DispatchQueue.main.async {
                        self.getIndiciesOfVisibleRows()
                        self.tableView.reloadData()
                    }
                    
                }
            } else {
                print("Error: \(error)")
            }
        }
    }
    
    /* 
        This method renders all 'visible' rows, which at the moment are all true.
        Potential for cell insertion/deletion if the didSelectRowAtIndexPath delegate
        method were to be used.
     */
    
    func getIndiciesOfVisibleRows() -> Void {
        visibleRows.removeAll()
        
        for cellIndex in 0..<cellDescriptors.count {
            if (cellDescriptors[cellIndex]["isVisible"] as! Bool) == true {
                visibleRows.append(cellIndex)
            }
        }
    }
    
    /*
        Similar to the above getIndiciesOfVisibleRows() method, this method would be
        utilized if there were to be any interaction with the rendered virtual wallet.
        This returns a cell descriptor, so its key for visibility can be set to true/false.
    */
    
    func getCellDescriptorForIndexPath(indexPath: IndexPath) -> NSDictionary {
        return cellDescriptors[visibleRows[indexPath.row]]
    }
    
    /*
        This method takes in a standard hexidecimal string that represents a color
        and returns the UIColor equivalent.
    */
    
    func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /*
        This method formats the account name from the RAW data input into
        something more readable.
    */
    
    func formatAccountName(name: String, row: Int) -> String {
        if (name.isEmpty) {
            return "ACCOUNT NAME \(row)"
        }
        
        var words = name.components(separatedBy: "_")
        var result: String = ""
        
        for wordIndex in 0..<words.count {
            if (wordIndex == 0) {
                result = words[wordIndex].uppercased()
            } else {
                result += " \(words[wordIndex].uppercased())"
            }
        }
        
        return result
    }
    
    /* 
        This method formats the account balance, and handles the rounding if the
        string contains any decimals.
    */
    
    func formatAccountBalance(balance: String) -> String {
        return balance.contains(".") ? "$\(Float(round(Float(balance)! * 100) / 100))" : "$\(balance)"
    }
    
    /*
        This method handles the formatting of the datetime passed from the RAW data,
        and returns a String that represents the effective range of the account.
    */
    
    func formatAccountDates(start: String, end: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        let startIndex = start.index(start.startIndex, offsetBy: 10)
        let endIndex = end.index(end.startIndex, offsetBy: 10)
        
        let startDate = dateFormatter.date(from: start.substring(to: startIndex))
        let endDate = dateFormatter.date(from: end.substring(to: endIndex))
        
        let stringFormatter = DateFormatter()
        stringFormatter.dateStyle = .medium
        let startDateString = stringFormatter.string(from: startDate!)
        let endDateString = stringFormatter.string(from: endDate!)
        
        return "Effective: \(startDateString) - \(endDateString)"
    }
}
