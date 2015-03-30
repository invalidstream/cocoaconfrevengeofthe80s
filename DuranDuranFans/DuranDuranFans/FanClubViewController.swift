//
//  FanClubViewController.swift
//  DuranDuranFans
//
//  Created by Chris Adamson on 2/22/15.
//  Copyright (c) 2015 Subsequently & Furthermore, Inc. All rights reserved.
//

import Cocoa

class FanClubViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var fansTable: NSTableView!
    
    var subWindowController : NSWindowController?
    var fans :[Fan] = [Fan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fansTable.doubleAction = "handleFanTableRowDoubleClick:"
        
        // Do any additional setup after loading the view.
        
        // temporary data
        fans.append (Fan(firstName: "Patty", lastName: "Greene", favoriteSong: "Hungry Like The Wolf"))
        fans.append (Fan(firstName: "Lauren", lastName: "Hutchinson", favoriteSong: "Rio"))
        fans.append (Fan(firstName: "Marshall", lastName: "Blechtman", favoriteSong: nil))
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    
    @IBAction func handleFanTableRowDoubleClick(sender: AnyObject) {
        NSLog ("handleFanTableRowDoubleClick")
        if let fanWC = self.storyboard?.instantiateControllerWithIdentifier("FanWindowController") as? NSWindowController {
            if let fanVC = fanWC.window?.contentViewController as? FanViewController {
                let index = fansTable.clickedRow
                if index < 0 {
                    return
                }
                let fan = fans[index]
                fanVC.fan = fan
            }
            
            fanWC.showWindow(self)
            fanWC.window?.makeKeyAndOrderFront(self)
            subWindowController = fanWC
        }
    }
    
    // MARK cut/copy/paste/delete
    @IBAction func cut (sender: AnyObject!) {
        NSLog ("cut")
        writeSelectedFanToPasteboard()
        deleteSelectedFan()
    }
    
    @IBAction func copy(sender: AnyObject!) {
        NSLog ("copy")
        writeSelectedFanToPasteboard()
    }
    
    @IBAction func paste (sender: AnyObject!) {
        NSLog ("paste")
        let pasteBoard = NSPasteboard.generalPasteboard()
        let pasteObjects = pasteBoard.readObjectsForClasses([Fan.self], options: nil)
        NSLog ("got paste objects: \(pasteObjects)")
        if pasteObjects == nil {
            return
        }
        for pasteObject in pasteObjects! {
            if let fan = pasteObject as? Fan {
                addFan(fan, atIndex: fans.count)
                fansTable.reloadData()
            }
        }
    }
    
    @IBAction func delete (sender: AnyObject!) {
        NSLog ("delete")
        deleteSelectedFan()
    }
    
    // TODO: how to enable menu item?
    @IBAction override func selectAll(sender: AnyObject?) {
        NSLog ("select all")
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        var tableHasSelection = fansTable.selectedRow >= 0
        let pasteBoard = NSPasteboard.generalPasteboard()
        var pasteBoardHasFan = pasteBoard.canReadItemWithDataConformingToTypes([FAN_UTI])
        let action = menuItem.action
        switch action {
        case "cut:":
            return tableHasSelection
        case "copy:":
            return tableHasSelection
        case "delete:":
            return tableHasSelection
        case "paste:":
            return pasteBoardHasFan
        default:
            return false
        }
    }
    
    // MARK: cut/copy/paste helpers
    func writeSelectedFanToPasteboard () {
        let index = fansTable.selectedRow
        if index < 0 {
            return
        }
        let fan = fans[index]
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([fan])
    }

    func deleteSelectedFan() {
        let index = fansTable.selectedRow
        if index < 0 {
            return
        }
        let deletedFan = fans[index]
        let undoInfo = ["fan" : deletedFan , "index" : index]
        undoManager?.registerUndoWithTarget(self, selector: "undoDeleteFan:", object: undoInfo)
        deleteAtIndex(index)
    }
    
    // MARK: undo/redo
    func undoDeleteFan (userInfo: AnyObject?) {
        NSLog ("undoDeleteFan")
        if let undoInfo = userInfo as? [String : AnyObject] {
            let fan = undoInfo["fan"] as Fan?
            let index = undoInfo["index"] as Int?
            if fan != nil && index != nil {
                addFan (fan!, atIndex: index!)
            }
        }
    }
    
    func addFan (fan: Fan, atIndex: Int) {
        NSLog ("addFan")
        fans.insert(fan, atIndex: atIndex)
        let undoInfo = ["fan" : fan, "index" : atIndex]
        undoManager?.registerUndoWithTarget(self, selector: "undoAddFan:", object: undoInfo)
        fansTable.reloadData()
    }
    
    func undoAddFan (userInfo: AnyObject?) {
        NSLog ("undoAddFan")
        if let undoInfo = userInfo as? [String : AnyObject] {
            if let index = undoInfo["index"] as? Int {
                deleteAtIndex(index)
            }
        }
    }
    
    func deleteAtIndex (index: Int) {
        fans.removeAtIndex(index)
        fansTable.reloadData()
    }
    
    // MARK: table data source
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return fans.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier("FanCell", owner: self) as? NSTableCellView {
            let fan = fans[row]
            cell.textField?.stringValue = fan.fullName()
            return cell
        } else {
            return nil
        }
    }
    
    
}

