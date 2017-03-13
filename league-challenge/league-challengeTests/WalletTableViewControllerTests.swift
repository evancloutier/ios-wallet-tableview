//
//  WalletTableViewControllerTests.swift
//  league-challenge
//
//  Created by Evan Cloutier on 2017-03-09.
//  Copyright © 2017 Evan Cloutier. All rights reserved.
//

import XCTest
import CoreData
@testable import league_challenge

class WalletTableViewControllerTests: XCTestCase {
    
    var viewController: WalletTableViewController!
    
    class TestWalletUtilities: WalletUtilities {
        var getWalletDetailsWasCalled = false
        var result: NSDictionary = [
            "info": [
                "message_type": "wallet",
                "cards": [
                    [
                        "id": "1",
                        "type": "test_account_1",
                        "amount": 310.45,
                        "currency": "CAD",
                        "policy_end_date": "2017-01-01T05:00:00Z",
                        "policy_start_date": "2016-04-21T04:00:00Z"
                    ] as NSObject,
                    [
                        "id": "2",
                        "type": "test_account_2",
                        "amount": 2,
                        "currency": "CAD",
                        "policy_end_date": "2017-01-01T05:00:00Z",
                        "policy_start_date": "2016-04-21T04:00:00Z"
                    ] as NSObject,
                    [
                        "id": "3",
                        "type": "test_account_3",
                        "amount": 100,
                        "currency": "CAD",
                        "policy_end_date": "2017-01-01T05:00:00Z",
                        "policy_start_date": "2016-04-21T04:00:00Z"
                    ] as NSObject,
                    [
                        "id": "4",
                        "type": "test_account_4",
                        "amount": 299.99,
                        "currency": "CAD",
                        "policy_end_date": "2017-01-01T05:00:00Z",
                        "policy_start_date": "2016-10-21T04:00:00Z"
                    ] as NSObject,
                    [
                        "id": "5",
                        "type": "test_account_5",
                        "amount": 1002.13,
                        "currency": "CAD",
                        "policy_end_date": "2017-01-01T05:00:00Z",
                        "policy_start_date": "2016-10-21T04:00:00Z"
                    ] as NSObject,
                    [
                        "id": "6",
                        "type": "test_account_6",
                        "amount": 444,
                        "currency": "CAD",
                        "policy_end_date": "2018-11-22T04:00:00Z",
                        "policy_start_date": "2017-11-22T04:00:00Z"
                    ] as NSObject
                ] as NSArray
            ] as NSDictionary
        ]
        
        override func getWalletDetails(completion: @escaping (NSDictionary?, NSError?) -> Void) {
            getWalletDetailsWasCalled = true
            completion(result, nil)
        }
    }
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateInitialViewController() as! WalletTableViewController
        viewController.utilitySource = TestWalletUtilities()

        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        XCTAssertNotNil(viewController.view)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTableViewOutlet() {
        XCTAssertNotNil(viewController.tableView)
    }
    
    func testTestWalletUtilitiesCallback() {
        let callbackExpectation = expectation(description: "TestWalletUtilties completes callback without error")
        
        TestWalletUtilities().getWalletDetails { (data, error) in
            XCTAssertTrue((data != nil))
            XCTAssertNil(error)
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }
    }
    
    func testCellDescriptorsCount() {
        // Note that the initCellDescriptors() method is called within viewDidLoad()
        // This is why the utility source is changed in setUp()
        if let infoObject = TestWalletUtilities().result.value(forKey: "info") as? NSDictionary {
            if let cardSize = (infoObject.value(forKey: "cards") as? NSArray)?.count {
                XCTAssertNotNil(viewController.cellDescriptors)
                XCTAssertEqual(viewController.cellDescriptors.count, cardSize)
            }
        }
    }
    
    func testCellDescriptorData() {
        
        if let cardArray = (TestWalletUtilities().result.value(forKey: "info") as! NSDictionary).value(forKey: "cards") as? NSArray {
            
            for cardIndex in 0..<cardArray.count {
                let cellDescriptor = viewController.cellDescriptors[cardIndex]
                let currentCard = cardArray[cardIndex] as! NSDictionary
                
                XCTAssertEqual(String(describing: cellDescriptor.value(forKey: "accountBalance")), String(describing: currentCard.value(forKey: "amount")))
                XCTAssertEqual(cellDescriptor.value(forKey: "accountCurrency") as! String, currentCard.value(forKey: "currency") as! String)
                XCTAssertEqual(cellDescriptor.value(forKey: "accountEndDate") as! String, currentCard.value(forKey: "policy_end_date") as! String)
                XCTAssertEqual(cellDescriptor.value(forKey: "accountName") as! String, currentCard.value(forKey: "type") as! String)
                XCTAssertEqual(cellDescriptor.value(forKey: "accountStartDate") as! String, currentCard.value(forKey: "policy_start_date") as! String)
            }
        }
    }
    
    func testFormattingBalance() {
        let testBalanceDecimal = "44.55"
        let testBalanceLongDecimal = "12.44444"
        let testBalanceInteger = "104"
        
        let formattedTestBalanceDecimal = viewController.formatAccountBalance(balance: testBalanceDecimal)
        let formattedTestBalanceLongDecimal = viewController.formatAccountBalance(balance: testBalanceLongDecimal)
        let formattedTestBalanceInteger = viewController.formatAccountBalance(balance: testBalanceInteger)
        
        XCTAssertEqual(formattedTestBalanceDecimal, "$44.55")
        XCTAssertEqual(formattedTestBalanceLongDecimal, "$12.44")
        XCTAssertEqual(formattedTestBalanceInteger, "$104")
    }
    
    func testFormattingAccountName() {
        let testAccountOne = "test_account_1"
        let testAccountTwo = "TEST_ACCOUNT_2"
        let testAccountThree = ""
        
        let formattedTestAccountOne = viewController.formatAccountName(name: testAccountOne, row: 1)
        let formattedTestAccountTwo = viewController.formatAccountName(name: testAccountTwo, row: 2)
        let formattedTestAccountThree = viewController.formatAccountName(name: testAccountThree, row: 3)
        
        XCTAssertEqual(formattedTestAccountOne, "TEST ACCOUNT 1")
        XCTAssertEqual(formattedTestAccountTwo, "TEST ACCOUNT 2")
        XCTAssertEqual(formattedTestAccountThree, "ACCOUNT NAME 3")
    }
    
    func testFormattingAccountDates() {
        let testStartDate = "2017-01-01T07:44:44Z"
        let testEndDate = "2018-01-21T04:00:00Z"
        
        let formattedTestEffectiveDate = viewController.formatAccountDates(start: testStartDate, end: testEndDate)
        
        XCTAssertEqual(formattedTestEffectiveDate, "Effective: Jan 1, 2017 - Jan 21, 2018")
    }
    
}
