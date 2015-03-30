//
//  Fan.swift
//  DuranDuranFans
//
//  Created by Chris Adamson on 3/27/15.
//  Copyright (c) 2015 Subsequently & Furthermore, Inc. All rights reserved.
//

import Cocoa

let FAN_UTI = "com.subfurther.cocoaconf.80s.fan"

// needs NSPasteboardWriting, NSPasteboardReading

class Fan : NSObject, NSCoding, NSPasteboardWriting, NSPasteboardReading {
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
    
    // MARK - NSPasteboardWriting
    func writableTypesForPasteboard(pasteboard: NSPasteboard!) -> [AnyObject]! {
        return [FAN_UTI, NSPasteboardTypeString]
    }
    
    func pasteboardPropertyListForType(type: String!) -> AnyObject! {
        switch type {
        case NSPasteboardTypeString:
            return fullName()
        case FAN_UTI:
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(firstName, forKey: "firstName")
            archiver.encodeObject(lastName, forKey: "lastName")
            archiver.encodeObject(favoriteSong, forKey: "favoriteSong")
            archiver.finishEncoding()
            return data
        default:
            return nil
        }
    }
    
    // MARK - NSPasteboardReading
    class func readableTypesForPasteboard(pasteboard: NSPasteboard!) -> [AnyObject]! {
        return [FAN_UTI]
    }
    
    required init?(pasteboardPropertyList propertyList: AnyObject!, ofType type: String!) {
        super.init() // fixes "all stored properties of a class instance must be initialized before returning nil from an initializer"
        switch type {
        case NSPasteboardTypeString:
            return nil
        case FAN_UTI:
            if let data = propertyList as? NSData {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                self.firstName = unarchiver.decodeObjectForKey("firstName") as String?
                self.lastName = unarchiver.decodeObjectForKey("lastName") as String?
                self.favoriteSong = unarchiver.decodeObjectForKey("favoriteSong") as String?
            }
        default:
            return nil // die
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
