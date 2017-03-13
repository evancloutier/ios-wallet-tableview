//
//  WalletUtilities.swift
//  league-challenge
//
//  Created by Evan Cloutier on 2017-03-08.
//  Copyright © 2017 Evan Cloutier. All rights reserved.
//

import Foundation

class WalletUtilities {
    
    func getWalletDetails(completion: @escaping (NSDictionary?, NSError?) -> Void) {
       
        let walletEndpoint: String = "https://gist.githubusercontent.com/Shanjeef/3562ebc5ea794a945f723de71de1c3ed/raw/25da03b403ffa860dd68a9bfc84f562262ee5ca5/walletEndpoint"
        
        guard let url = URL(string: walletEndpoint) else {
            completion(nil, NSError(domain: "Unable to convert String to URL", code: 100, userInfo: nil))
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                completion(nil, error as NSError?)
                return
            }
            
            guard let responseData = data else {
                completion(nil, error as NSError?)
                return
            }
            
            var jsonResult: NSDictionary!
            
            do {
                jsonResult = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! NSDictionary
            } catch let jsonError as NSError {
                completion(nil, jsonError)
                return
            }
            
            completion(jsonResult, nil)
        }
        task.resume()
    }
}
