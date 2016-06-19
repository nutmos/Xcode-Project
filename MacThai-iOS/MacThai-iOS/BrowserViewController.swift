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
    var link: URLRequest?
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    //@IBOutlet private weak var activityItem: UIBarButtonItem!
    //private var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
    private var userDefault = UserDefaults()

    override internal func loadView() {
        super.loadView()
        if objc_getClass("WKWebView") != nil {
            self.newWebView = WKWebView(frame: self.webView.frame, configuration: WKWebViewConfiguration())
            self.newWebView?.navigationDelegate = self
            self.newWebView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
            //self.newWebView?.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.newWebView?.translatesAutoresizingMaskIntoConstraints = false
            //println("view subviews = \(self.view.subviews)")
            //println()
            //println("view constraint = \(self.view.constraints())")
            self.webView.removeFromSuperview()
            self.view.addSubview(self.newWebView!)
            self.view.sendSubview(toBack: self.newWebView!)
            let layout1 = NSLayoutConstraint(item: self.newWebView!, attribute: .leading, relatedBy: .equal, toItem: self.newWebView?.superview, attribute: .leading, multiplier: 1, constant: 0)
            let layout2 = NSLayoutConstraint(item: self.newWebView!, attribute: .top, relatedBy: .equal, toItem: self.newWebView?.superview, attribute: .top, multiplier: 1, constant: 0)
            let layout3 = NSLayoutConstraint(item: self.newWebView!.superview!, attribute: .trailing, relatedBy: .equal, toItem: self.newWebView, attribute: .trailing, multiplier: 1, constant: 0)
            let layout4 = NSLayoutConstraint(item: self.newWebView!, attribute: .bottom, relatedBy: .equal, toItem: self.newWebView?.superview, attribute: .bottom, multiplier: 1, constant: 0)
            self.view.addConstraints([layout1, layout2, layout3, layout4])
        }
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.shareButton
        if let webView = self.newWebView {
            webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            webView.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        }
        else {
            self.webView.scalesPageToFit = true
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 44, 0)
            self.webView.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        }
        //self.activityIndicator.activityIndicatorViewStyle = .Gray
        //self.activityItem.customView = self.activityIndicator
        if self.userDefault.object(forKey: "readability") == nil {
            self.userDefault.set(false, forKey: "readability")
        }
        if let readabilityIsOn = self.userDefault.object(forKey: "readability") as? Bool, link = self.link {
            self.title = link.url?.absoluteString
            if readabilityIsOn {
                if let linkURL = link.url {
                    if let url = URL(string: "http://www.readability.com/m?url=\(linkURL)") {
                        if let webView = self.newWebView {
                            webView.load(URLRequest(url: url))
                        }
                        else {
                            self.webView.loadRequest(URLRequest(url: url))
                        }
                    }
                }
            }
            else {
                if let webView = self.newWebView {
                    webView.load(link)
                }
                else {
                    self.webView.loadRequest(link)
                }
            }
        }
    }
    
    internal func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.host == "www.macthai.com" {
            var pathCompo = request.url?.pathComponents
            if let pathCompo1String = pathCompo?[1] as String! {
                if pathCompo1String == "category" {
                    if let url = try! request.url?.appendingPathComponent("feed") {
                        let sendData = url
                        performSegue(withIdentifier: "ToSubFeed", sender: sendData)
                    }
                    return false
                }
                else if pathCompo1String == "tag" {
                    if let url = try! request.url?.appendingPathComponent("feed") {
                        let sendData = url
                        performSegue(withIdentifier: "ToSubFeed", sender: sendData)
                    }
                    return false
                }
                else if pathCompo1String == "author" {
                    if let url = try! request.url?.appendingPathComponent("feed") {
                        let sendData = url
                        performSegue(withIdentifier: "ToSubFeed", sender: sendData)
                    }
                    return false
                }
            }
        }
        return true
    }

    // MARK: - Web View Delegate

    internal func webViewDidStartLoad(_ webView: UIWebView) {
        //self.activityIndicator.startAnimating()
        UIApplication.shared().isNetworkActivityIndicatorVisible = true
    }

    internal func webViewDidFinishLoad(_ webView: UIWebView) {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: "enableButton", userInfo: nil, repeats: false)
        //self.activityIndicator.stopAnimating()
        UIApplication.shared().isNetworkActivityIndicatorVisible = false
        self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
    }
    
    internal func webView(_ webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIApplication.shared().isNetworkActivityIndicatorVisible = false
        //self.activityIndicator.stopAnimating()
    }
    
    // MARK: - User Interactions
    
    @IBAction internal func didShareButtonPressed (_ sender: UIBarButtonItem!) {
        var data = [AnyObject]()
        if let webView = self.newWebView {
            if let url = self.newWebView?.url {
                data.append(url)
            }
            webView.evaluateJavaScript("document.title", completionHandler: { (result, error) -> Void in
                if error == nil {
                    if var resultString = result as? String {
                        resultString = resultString.replacingOccurrences(of: " | Macthai.com", with: " @macthainews")
                        data.append(resultString)
                        let activity = UIActivityViewController(activityItems: data, applicationActivities: [OpenInSafariActivity()])
                        self.present(activity, animated: true, completion: nil)
                    }
                }
            })
        }
        else {
            if let url = self.webView.stringByEvaluatingJavaScript(from: "window.location") {
                data.append(url)
            }
            if let title = self.webView.stringByEvaluatingJavaScript(from: "document.title")?.replacingOccurrences(of: " | Macthai.com", with: " @macthainews") {
                data.append(title)
            }
            let activity = UIActivityViewController(activityItems: data, applicationActivities: [OpenInSafariActivity()])
            present(activity, animated: true, completion: nil)
        }
    }

    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueID = segue.identifier
        if segueID == "ToSubFeed" {
            let vc = segue.destinationViewController as! SubFeedViewController
            vc.url = sender as? URL
        }
        else if segueID == "ToBrowser" {
            let vc = segue.destinationViewController as! BrowserViewController
            if let sender = sender as? URLRequest {
                vc.link = sender
            }
        }
    }

    // MARK: - WebKit Navigation Delegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared().isNetworkActivityIndicatorVisible = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared().isNetworkActivityIndicatorVisible = false
        self.title = webView.title
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        if webView.url?.host == "www.macthai.com" {
            var pathCompo = webView.url?.pathComponents
            if pathCompo?[1] as String! == "category" {
                decisionHandler(.cancel)
                if let url = try! webView.url?.appendingPathComponent("feed") {
                    let sendData = url
                    performSegue(withIdentifier: "ToSubFeed", sender: sendData)
                }
            }
            else if pathCompo?[1] as String! == "tag" {
                decisionHandler(.cancel)
                if let url = try! webView.url?.appendingPathComponent("feed") {
                    let sendData = url
                    performSegue(withIdentifier: "ToSubFeed", sender: sendData)
                }
            }
            else if pathCompo?[1] as String! == "author" {
                decisionHandler(.cancel)
                if let url = try! webView.url?.appendingPathComponent("feed") {
                    let sendData = url
                    performSegue(withIdentifier: "ToSubFeed", sender: sendData)
                }
            }
        }
        decisionHandler(.allow)
    }

}
