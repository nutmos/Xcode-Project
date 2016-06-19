//
//  ArticleViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 11/1/58.
//  Copyright (c) พ.ศ. 2558 Nattapong Mos. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, NSXMLParserDelegate {
    
    private var foundEntry = false
    @IBOutlet private weak var textView: UITextView!
    var articleLink: NSURL?
    private var parser: NSXMLParser?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = ""
        if let link = self.articleLink {
            var contentStr = (NSString(contentsOfURL: link, encoding: NSUTF8StringEncoding, error: nil)!).stringByReplacingOccurrencesOfString("<!DOCTYPE html>", withString: "")
            var cnt = "<content>\(contentStr)</content>"
            //println(cnt)
            if let data = cnt.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                self.parser = NSXMLParser(data: data)
            }
            self.parser?.delegate = self
            self.parser?.shouldResolveExternalEntities = false
            self.parser?.parse()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*if let link = self.articleLink {
            var cnt = "<content>\(NSString(contentsOfURL: link, encoding: NSUTF8StringEncoding, error: nil)!)</content>"
            println(cnt)
            self.parser = NSXMLParser(data: cnt.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true))
            self.parser?.delegate = self
            self.parser?.shouldResolveExternalEntities = false
            self.parser?.parse()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - XML Parser Delegate
    
    func parserDidStartDocument(parser: NSXMLParser) {
        println("start parse")
    }

    func parserDidEndDocument(parser: NSXMLParser) {
        //println("end parse")
    }

    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        //println("paser error \(parseError)")
    }

    internal func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        //println("parser \(elementName)")
        if elementName == "div" {
            if attributeDict["class"] as? String == "entry" {
                foundEntry = true
            }
        }
        else if elementName == "p" && foundEntry {
            self.textView.text? += "\n\n"
        }
        /*else if elementName == "img" && foundEntry {
            if let url = NSURL(string: attributeDict["src"] as String) {
                if let data = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: data) {
                        var imageView = UIImageView(image: image)
                        imageView.frame = CGRectMake(0, 0, 745, 422)
                        self.textView.addSubview(imageView)
                    }
                }
            }
        }*/
    }
    
    internal func parser(parser: NSXMLParser, foundCharacters string: String?) {
        //println("found character \(string)")
        if let string = string {
            if foundEntry {
                self.textView.text? += string
            }
        }
    }

}
