//
//  ReadabilityViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 8/2/58.
//  Copyright (c) พ.ศ. 2558 Nattapong Mos. All rights reserved.
//

import UIKit

class ReadabilityViewController: UIViewController {

    var articleURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("articleURL = \(self.articleURL)")
        var request = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        request.URL = NSURL(string: "http://www.readability.com/api/content/v1/parser?url=\(self.articleURL)/&token=3fab834f48fbd23114f8db2270927d787022bce4")
        if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil) {
            var dataSerialized = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: nil)
            println("data = \(dataSerialized)")
        }
    }

}
