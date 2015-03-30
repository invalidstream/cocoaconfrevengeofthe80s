//
//  Fan.swift
//  DuranDuranFans
//
//  Created by Chris Adamson on 3/27/15.
//  Copyright (c) 2015 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit
import MobileCoreServices

let FAN_UTI = "com.subfurther.cocoaconf.80s.fan"

// needs NSPasteboardWriting, NSPasteboardReading

// no pasteboardreading?

class Fan : NSObject, NSCoding {
    var firstName: String?
    var lastName: String?
    var favoriteSong: String?
    
    init (firstName: String?, lastName: String?, favoriteSong: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.favoriteSong = favoriteSong
    }
    
    func fullName() -> String {
        let first = firstName != nil ? firstName! : ""
        let last = lastName != nil ? lastName! : ""
        return "\(first) \(last)"
    }
    
    // MARK - NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(firstName, forKey: "firstName")
        aCoder.encodeObject(lastName, forKey: "lastName")
        aCoder.encodeObject(favoriteSong, forKey: "favoriteSong")
    }
    
    required init(coder aDecoder: NSCoder) {
        firstName = aDecoder.decodeObjectForKey("firstName") as String?
        lastName = aDecoder.decodeObjectForKey("lastName") as String?
        favoriteSong = aDecoder.decodeObjectForKey("favoriteSong") as String?
    }
        
    func dictionaryForPasteboard() -> [NSString : AnyObject] {
        var dictionary : [NSString : AnyObject] = [:]
        // public.text
        dictionary [kUTTypeText] = self.fullName()
        // FAN_UTI
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(firstName, forKey: "firstName")
        archiver.encodeObject(lastName, forKey: "lastName")
        archiver.encodeObject(favoriteSong, forKey: "favoriteSong")
        archiver.finishEncoding()
        dictionary [FAN_UTI] = data
        return dictionary
    }
    
    init? (pasteboardData: NSData) {
        super.init()
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: pasteboardData)
        self.firstName = unarchiver.decodeObjectForKey("firstName") as String?
        self.lastName = unarchiver.decodeObjectForKey("lastName") as String?
        self.favoriteSong = unarchiver.decodeObjectForKey("favoriteSong") as String?
        if self.firstName == nil || self.lastName == nil {
            return nil
        }
    }
    
    // MARK - helpers
    func description() -> String {
        if firstName != nil && lastName != nil && favoriteSong != nil {
            return "\(firstName!) \(lastName!), likes \(favoriteSong!)"
        } else {
            return "\(firstName) \(lastName), \(favoriteSong)"
        }
        
    }
}
