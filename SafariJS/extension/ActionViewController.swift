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
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
                    print(javaScriptValues)
                }
            }
        }
    }

    @IBAction func done()
    {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
