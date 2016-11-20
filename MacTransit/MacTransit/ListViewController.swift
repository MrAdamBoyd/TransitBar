//
//  ViewController.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-10-11.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa
import SwiftBus

class ListViewController: NSViewController, NewStopDelegate {

    @IBOutlet weak var createNewLineButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //Interrupt segue and set this view controller as the delegate
        guard let identifier = segue.identifier, identifier == "showNewLine" else {
            return
        }
        
        guard let windowController = segue.destinationController as? NSWindowController, let viewController = windowController.contentViewController as? NewLineViewController else {
            return
        }
        
        viewController.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func createNewLineAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showNewLine", sender: self)
    }
    
    // MARK: - NewStopDelegate
    func newStopControllerDidAdd(newStop: TransitStop) {
        print("Did select new stop")
    }

}

