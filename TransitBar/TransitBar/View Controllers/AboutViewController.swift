//
//  AboutViewController.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-11-27.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    
    @IBOutlet weak var versionTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionTextField.stringValue = "Version \(version)"
        }
    }
    
    @IBAction func goToWebsiteButton(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://github.com/MrAdamBoyd/TransitBar")!)
    }
}
