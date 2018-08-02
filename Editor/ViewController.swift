//
//  ViewController.swift
//  Editor
//
//  Created by poisson florent on 30/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var sourceTextView: NSTextView!
    @IBOutlet weak var logTextView: NSTextView!
    @IBOutlet weak var runButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customize()
        
        if let initialScript = UserDefaults.standard.string(forKey: "edited-script") {
            sourceTextView.string = initialScript
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func customize() {
        sourceTextView.textColor = NSColor(calibratedWhite: 1, alpha: 1)
        sourceTextView.font = NSFont(name: "Arial", size: 16)
        sourceTextView.isGrammarCheckingEnabled = false
        sourceTextView.isAutomaticTextCompletionEnabled = false
        sourceTextView.isAutomaticSpellingCorrectionEnabled = false
        sourceTextView.isAutomaticQuoteSubstitutionEnabled = false

        logTextView.textColor = NSColor(calibratedWhite: 0.8, alpha: 1)
        logTextView.font = NSFont(name: "Arial", size: 16)
    }
    
    // MARK: - State managemenr
    
    private func runScript(_ script: String) {
        // Auto save the current script
        saveScript(script)
        
        runButton.isEnabled = false
        logTextView.string = ""
        
        // Setup stdout callback
        let messenger = Messenger()
        messenger.subscribe(to: .stdout) { [weak self] (message) in
            if let message = message.data as? String {
                self?.displayLog(message: message)
            }
        }
        
        // Setup runtime session
        let session = Session(isDebug: true,
                              messenger: messenger,
                              getScriptForModule: nil)
        
        do {
            // Run script
            try session.run(script: script)
            
        } catch let error {
            displayLog(message: "Error: \(error)")
        }
        
        runButton.isEnabled = true
    }
    
    private func displayLog(message: String) {
        let text = logTextView.string + "\n" + message
        logTextView.string = text
    }
    
    private func saveScript(_ script: String) {
        UserDefaults.standard.setValue(script, forKey: "edited-script")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(sender: NSButton) {
        saveScript(sourceTextView.string)
    }
    
    @IBAction func runButtonTapped(sender: NSButton) {
        runScript(sourceTextView.string + "\n")
    }

}

