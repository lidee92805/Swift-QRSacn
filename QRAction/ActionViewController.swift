//
//  ActionViewController.swift
//  QRAction
//
//  Created by lidehua on 15/6/25.
//  Copyright (c) 2015年 李德华. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as! String) {
                    // You _HAVE_ to call loadItemForTypeIdentifier in order to get the JS injected
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as! String, options: nil, completionHandler: {
                        (list, error) in
                        if let results = list as? NSDictionary {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // We don't actually care about this...
                                let string: AnyObject? = results[NSExtensionJavaScriptPreprocessingResultsKey]
                                if let dict = string as? NSDictionary {
                                    let url = dict["baseURI"] as! String
                                    let codeImage = QRCodeGenerator.qrImageForString(url, imageSize: 200)
                                    self.imageView.image = codeImage
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    @IBAction func save(sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, Selector("done"), nil)
    }
}
