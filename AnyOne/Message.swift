//
//  Message.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 13/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var message: String?
    var imageURL: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoURL: String?
    
    func chatPartnerId() -> String? {
        
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}

