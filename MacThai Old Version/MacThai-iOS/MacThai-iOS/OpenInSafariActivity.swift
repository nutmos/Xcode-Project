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
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for activity in activityItems {
            if activity is NSURL {
                return true
            }
        }
        return false
    }
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activity in activityItems {
            if let activity = activity as? NSURL {
                UIApplication.sharedApplication().openURL(activity)
                break
            }
        }
    }
    override func activityViewController() -> UIViewController? {
        return nil
    }
    override func performActivity() {
        UIApplication.sharedApplication().openURL(NSURL(string: "")!)
        activityDidFinish(true)
    }
    override class func activityCategory() -> UIActivityCategory {
        return .Action
    }
}
