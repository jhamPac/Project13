//
//  ActionViewController.swift
//  extension
//
//  Created by jhampac on 1/29/16.
//  Copyright © 2016 jhampac. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController
{
    var pageTitle = ""
    var pageURL = ""
    @IBOutlet weak var script: UITextView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem
        {
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider
            {
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil) {[unowned self] (dict, error) in
                    
                    // this is what I am looking for; do a check on error; if nill go ahead if not then call else
                    guard error == nil else
                    {   print(error.localizedDescription)
                        return
                    }
                    
                    let itemDictionary = dict as! NSDictionary
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    
                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.title = self.pageTitle
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        beAnObserver()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        stopAnObserver()
    }

    @IBAction func done()
    {
        // return data to the host app
        let item = NSExtensionItem()
        let webDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": script.text]]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        
        // its possible to have other type of NSItemProviders in the attachments array
        item.attachments = [customJavaScript]
        
        extensionContext!.completeRequestReturningItems([item], completionHandler: nil)
    }
    
    func beAnObserver()
    {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func stopAnObserver()
    {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func adjustForKeyboard(notification: NSNotification)
    {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            script.contentInset = UIEdgeInsetsZero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

}
