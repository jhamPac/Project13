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

}
