//
//  BrowserViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 5/11/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

import WebKit
import UIKit

class BrowserViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {

    @IBOutlet private var webView: UIWebView!
    var newWebView: WKWebView?
    var link: NSURLRequest?
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    //@IBOutlet private weak var activityItem: UIBarButtonItem!
    //private var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
    private var userDefault = NSUserDefaults()

    override internal func loadView() {
        super.loadView()
        if objc_getClass("WKWebView") != nil {
            self.newWebView = WKWebView(frame: self.webView.frame, configuration: WKWebViewConfiguration())
            self.newWebView?.navigationDelegate = self
            self.newWebView?.autoresizingMask = .FlexibleRightMargin | .FlexibleBottomMargin
            self.newWebView?.setTranslatesAutoresizingMaskIntoConstraints(false)
            //println("view subviews = \(self.view.subviews)")
            //println()
            //println("view constraint = \(self.view.constraints())")
            self.webView.removeFromSuperview()
            self.view.addSubview(self.newWebView!)
            self.view.sendSubviewToBack(self.newWebView!)
            var layout1 = NSLayoutConstraint(item: self.newWebView!, attribute: .Leading, relatedBy: .Equal, toItem: self.newWebView?.superview, attribute: .Leading, multiplier: 1, constant: 0)
            var layout2 = NSLayoutConstraint(item: self.newWebView!, attribute: .Top, relatedBy: .Equal, toItem: self.newWebView?.superview, attribute: .Top, multiplier: 1, constant: 0)
            var layout3 = NSLayoutConstraint(item: self.newWebView!.superview!, attribute: .Trailing, relatedBy: .Equal, toItem: self.newWebView, attribute: .Trailing, multiplier: 1, constant: 0)
            var layout4 = NSLayoutConstraint(item: self.newWebView!, attribute: .Bottom, relatedBy: .Equal, toItem: self.newWebView?.superview, attribute: .Bottom, multiplier: 1, constant: 0)
            self.view.addConstraints([layout1, layout2, layout3, layout4])
        }
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.shareButton
        if let webView = self.newWebView {
            webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            webView.scrollView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        }
        else {
            self.webView.scalesPageToFit = true
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 44, 0)
            self.webView.scrollView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        }
        //self.activityIndicator.activityIndicatorViewStyle = .Gray
        //self.activityItem.customView = self.activityIndicator
        if self.userDefault.objectForKey("readability") == nil {
            self.userDefault.setBool(false, forKey: "readability")
        }
        if let readabilityIsOn = self.userDefault.objectForKey("readability") as? Bool, link = self.link {
            self.title = link.URL?.absoluteString
            if readabilityIsOn {
                if let linkURL = link.URL {
                    if let url = NSURL(string: "http://www.readability.com/m?url=\(linkURL)") {
                        if let webView = self.newWebView {
                            webView.loadRequest(NSURLRequest(URL: url))
                        }
                        else {
                            self.webView.loadRequest(NSURLRequest(URL: url))
                        }
                    }
                }
            }
            else {
                if let webView = self.newWebView {
                    webView.loadRequest(link)
                }
                else {
                    self.webView.loadRequest(link)
                }
            }
        }
    }
    
    internal func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL?.host == "www.macthai.com" {
            var pathCompo = request.URL?.pathComponents
            if pathCompo?[1] as? String == "category" {
                if let urlString = request.URL?.absoluteString?.stringByAppendingPathComponent("feed") {
                    var sendData = NSURL(string: urlString)
                    performSegueWithIdentifier("ToSubFeed", sender: sendData)
                }
                return false
            }
            else if pathCompo?[1] as? String == "tag" {
                if let urlString = request.URL?.absoluteString?.stringByAppendingPathComponent("feed") {
                    var sendData = NSURL(string: urlString)
                    performSegueWithIdentifier("ToSubFeed", sender: sendData)
                }
                return false
            }
            else if pathCompo?[1] as? String == "author" {
                if let urlString = request.URL?.absoluteString?.stringByAppendingPathComponent("feed") {
                    var sendData = NSURL(string: urlString)
                    performSegueWithIdentifier("ToSubFeed", sender: sendData)
                }
                return false
            }
        }
        return true
    }

    // MARK: - Web View Delegate

    internal func webViewDidStartLoad(webView: UIWebView) {
        //self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    internal func webViewDidFinishLoad(webView: UIWebView) {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "enableButton", userInfo: nil, repeats: false)
        //self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
    }
    
    internal func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        //self.activityIndicator.stopAnimating()
    }
    
    // MARK: - User Interactions
    
    @IBAction internal func didShareButtonPressed (sender: UIBarButtonItem!) {
        var data = [AnyObject]()
        if let webView = self.newWebView {
            if let url = self.newWebView?.URL {
                data.append(url)
            }
            webView.evaluateJavaScript("document.title", completionHandler: { (result, error) -> Void in
                if error == nil {
                    if var resultString = result as? String {
                        resultString = resultString.stringByReplacingOccurrencesOfString(" | Macthai.com", withString: " @macthainews")
                        data.append(resultString)
                        var activity = UIActivityViewController(activityItems: data, applicationActivities: [OpenInSafariActivity()])
                        self.presentViewController(activity, animated: true, completion: nil)
                    }
                }
            })
        }
        else {
            if let url = self.webView.stringByEvaluatingJavaScriptFromString("window.location") {
                data.append(url)
            }
            if let title = self.webView.stringByEvaluatingJavaScriptFromString("document.title")?.stringByReplacingOccurrencesOfString(" | Macthai.com", withString: " @macthainews") {
                data.append(title)
            }
            var activity = UIActivityViewController(activityItems: data, applicationActivities: [OpenInSafariActivity()])
            presentViewController(activity, animated: true, completion: nil)
        }
    }

    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueID = segue.identifier
        if segueID == "ToSubFeed" {
            let vc = segue.destinationViewController as! SubFeedViewController
            vc.url = sender as? NSURL
        }
        else if segueID == "ToBrowser" {
            let vc = segue.destinationViewController as! BrowserViewController
            if let sender = sender as? NSURLRequest {
                vc.link = sender
            }
        }
    }

    // MARK: - WebKit Navigation Delegate
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.title = webView.title
    }

    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationAction: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        if webView.URL?.host == "www.macthai.com" {
            var pathCompo = webView.URL?.pathComponents
            if pathCompo?[1] as? String == "category" {
                decisionHandler(.Cancel)
                if let urlString = webView.URL?.absoluteString?.stringByAppendingPathComponent("feed") {
                    var sendData = NSURL(string: urlString)
                    performSegueWithIdentifier("ToSubFeed", sender: sendData)
                }
            }
            else if pathCompo?[1] as? String == "tag" {
                decisionHandler(.Cancel)
                if let urlString = webView.URL?.absoluteString?.stringByAppendingPathComponent("feed") {
                    var sendData = NSURL(string: urlString)
                    performSegueWithIdentifier("ToSubFeed", sender: sendData)
                }
            }
            else if pathCompo?[1] as? String == "author" {
                decisionHandler(.Cancel)
                if let urlString = webView.URL?.absoluteString?.stringByAppendingPathComponent("feed") {
                    var sendData = NSURL(string: urlString)
                    performSegueWithIdentifier("ToSubFeed", sender: sendData)
                }
            }
        }
        decisionHandler(.Allow)
    }

}
