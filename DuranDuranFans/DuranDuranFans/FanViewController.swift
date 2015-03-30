//
//  FanViewController.swift
//  DuranDuranFans
//
//  Created by Chris Adamson on 2/22/15.
//  Copyright (c) 2015 Subsequently & Furthermore, Inc. All rights reserved.
//

import Cocoa

class FanViewController: NSViewController {

    var fan : Fan?
    
    @IBOutlet weak var fanNameField: NSTextField!
    @IBOutlet weak var favoriteSongField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        if let trueFan = fan {
            fanNameField.stringValue = trueFan.fullName()
            favoriteSongField.stringValue = trueFan.favoriteSong ?? "none"
        }
    }
    
    
}
