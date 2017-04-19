//
//  RootRequestHelper.swift
//  Yona
//
//  Created by Angel Vasa on 14/03/17.
//  Copyright © 2017 Yona. All rights reserved.
//

import Foundation

class RootRequestHelper {
    func handleMobileconfigRootRequest (request :RouteRequest,  response :RouteResponse ) {
        let url = NSBundle.mainBundle().URLForResource("style", withExtension:"css")
        guard let urlValue = url else { return }
        var cssFile = ""
        do {
            cssFile = try String(contentsOfURL: urlValue)
        } catch let error {
            return
            // Nothing for now :)
        }
        
        let htmString = NSLocalizedString("yona-certificate", comment: "base64 image")
        let final = htmString.stringByReplacingOccurrencesOfString("{cssFile}", withString: cssFile)
        
        
        response.respondWithString(final)
    }
}
