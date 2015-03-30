//
//  ViewController.swift
//  MCHammerFans
//
//  Created by Chris Adamson on 3/27/15.
//  Copyright (c) 2015 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    class var nuSansFont : UIFont? { return UIFont(name: "Nu Sans Demo", size: 14.0) }
    
    var fans :[Fan] = [Fan]()
    @IBOutlet weak var fansTable: UITableView!
    @IBOutlet weak var undoButton: UIView!
    @IBOutlet weak var redoButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        fans.append (Fan(firstName: "Jason", lastName: "Seaver", favoriteSong: "U Can't Touch This"))
        fans.append (Fan(firstName: "Maggie", lastName: "Seaver", favoriteSong: "U Can't Touch This"))
        fans.append (Fan(firstName: "Mike", lastName: "Seaver", favoriteSong: "U Can't Touch This"))
        fans.append (Fan(firstName: "Carol", lastName: "Seaver", favoriteSong: "U Can't Touch This"))
        fans.append (Fan(firstName: "Ben", lastName: "Seaver", favoriteSong: nil))
        fansTable.backgroundView = nil
        fansTable.backgroundColor = UIColor.clearColor()
        fansTable.separatorColor = UIColor.blackColor()

    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: cut/copy/paste helpers
    func writeSelectedFanToPasteboard () {
        let selection = selectedFanAndIndex()
        if selection != nil {
            UIPasteboard.generalPasteboard().items = [selection!.fan.dictionaryForPasteboard()]
        }
    }
    
    func deleteSelectedFan() {
        let selection = selectedFanAndIndex()
        if selection != nil {
            let undoInfo = ["fan" : selection!.fan , "index" : selection!.index]
            undoManager?.registerUndoWithTarget(self, selector: "undoDeleteFan:", object: undoInfo)
            deleteAtIndex(selection!.index)
        }
    }
    
    func selectedFanAndIndex() -> (fan: Fan, index: Int)? {
        let indexPath = fansTable.indexPathForSelectedRow()
        if indexPath == nil {
            return nil
        }
        let index = indexPath!.row
        return (fans[index], index)
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
        // auto-select last one
        fansTable.selectRowAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), animated: true, scrollPosition: .Middle)
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
        NSLog ("deleteAtIndex")
        fans.removeAtIndex(index)
        fansTable.reloadData()
    }

    
    // MARK - table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let fan = fans[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("FanCell") as UITableViewCell
        cell.textLabel?.text = fan.fullName()
        if  ViewController.nuSansFont != nil {
            cell.textLabel?.font = ViewController.nuSansFont!
        }
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.blackColor()
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.blackColor()
        cell?.backgroundColor = UIColor.blackColor()
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.tintColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.clearColor()
        cell?.backgroundColor = UIColor.clearColor()
        cell?.textLabel?.textColor = UIColor.blackColor()
        cell?.tintColor = UIColor.blackColor()
    }
    
    // MARK - undo/redo buttons
    @IBAction func undoButtonTapped(sender: AnyObject) {
        if undoManager != nil && undoManager!.canUndo {
            undoManager?.undo()
        }
    }
    
    @IBAction func redoButtonTapped(sender: AnyObject) {
        if undoManager != nil && undoManager!.canRedo {
            undoManager?.redo()
        }
    }
    
    // MARK - UIMenuController
    @IBAction func handleTableLongPress(sender: AnyObject) {
        var targetRect = CGRect (x: self.view.bounds.width/2.0, y: self.view.bounds.height/2.0, width: 0, height: 0)
        if let recognizer = sender as? UIGestureRecognizer {
            let touchPoint = recognizer.locationInView(fansTable)
            targetRect = CGRect(origin: touchPoint, size: CGSizeZero)
            // also auto-select row, if possible
            let indexPath = fansTable.indexPathForRowAtPoint (touchPoint)
            if indexPath != nil {
                fansTable.selectRowAtIndexPath(indexPath!, animated: false, scrollPosition: .None)
            }
        }
        UIMenuController.sharedMenuController().setTargetRect(targetRect, inView: fansTable)
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
         switch action {
        case "copy:","cut:","paste:","delete:":
            return true
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
   
    override func copy (sender: AnyObject!) {
        NSLog ("copy")
        writeSelectedFanToPasteboard()
    }
    override func cut (sender: AnyObject!) {
        NSLog ("cut")
        writeSelectedFanToPasteboard()
        deleteSelectedFan()
    }
    override func paste (sender: AnyObject!) {
        NSLog ("paste")
        let pasteboard = UIPasteboard.generalPasteboard()
        if let pasteData = pasteboard.dataForPasteboardType(FAN_UTI) {
            if let fan = Fan (pasteboardData: pasteData) {
                addFan(fan, atIndex: fans.count)
            }
        }
    }
    override func delete (sender: AnyObject!) {
        NSLog ("delete")
        deleteSelectedFan()
    }

    
    // MARK segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog ("prepareForSegue.")
        if let obj = sender as? NSObject {
            NSLog ("sender is \(String(UTF8String:object_getClassName(sender)))")
        }
        if let detailVC = segue.destinationViewController as? DetailViewController {
            if let accessoryCell = sender as? UITableViewCell {
                let indexPath = fansTable.indexPathForCell(accessoryCell)
                if indexPath != nil {
                    detailVC.fan = fans[indexPath!.row]
                }
            }
        }
    }
    
    @IBAction func unwindToRootViewController (segue: UIStoryboardSegue!) {
    }
    
}

