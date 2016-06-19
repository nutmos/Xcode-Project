//
//  OpenInSafariActivity.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 16/1/58.
//  Copyright (c) พ.ศ. 2558 Nattapong Mos. All rights reserved.
//

import UIKit

class OpenInSafariActivity: UIActivity {
    override func activityType() -> String? {
        return "Safari.OpenInSafari.App"
    }
    override func activityTitle() -> String? {
        return "Open in Safari"
    }
    override func activityImage() -> UIImage? {
        return UIImage(named: "flatsafari")
    }
    override func canPerform(withActivityItems activityItems: [AnyObject]) -> Bool {
        for activity in activityItems {
            if activity is URL {
                return true
            }
        }
        return false
    }
    override func prepare(withActivityItems activityItems: [AnyObject]) {
        for activity in activityItems {
            if let activity = activity as? URL {
                UIApplication.shared().openURL(activity)
                break
            }
        }
    }
    override func activityViewController() -> UIViewController? {
        return nil
    }
    override func perform() {
        UIApplication.shared().openURL(URL(string: "")!)
        activityDidFinish(true)
    }
    override class func activityCategory() -> UIActivityCategory {
        return .action
    }
}
