//
//  DetailViewController.swift
//  MCHammerFans
//
//  Created by Chris Adamson on 3/27/15.
//  Copyright (c) 2015 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var fanNameLabel: UILabel!
    @IBOutlet weak var favoriteSongLabel: UILabel!
    
    var fan : Fan?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        if fan != nil {
            fanNameLabel.text = fan!.fullName()
            favoriteSongLabel.text = fan!.favoriteSong ?? "none"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
