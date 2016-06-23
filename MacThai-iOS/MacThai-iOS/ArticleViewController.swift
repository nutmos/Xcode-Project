//
//  ArticleViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 11/1/58.
//  Copyright (c) พ.ศ. 2558 Nattapong Mos. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, XMLParserDelegate {
    
    private var foundEntry = false
    @IBOutlet private weak var textView: UITextView!
    var articleLink: URL?
    private var parser: XMLParser?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = ""
        if let link = self.articleLink {
            //var contentStr = (NSString(contentsOfURL: link, encoding: NSUTF8StringEncoding, error: nil)!).stringByReplacingOccurrencesOfString("<!DOCTYPE html>", withString: "")
            //var contentStr = NSString(contentsOfURL: link, encoding: NSUTF8StringEncoding, error: nil)
            let contentStr = String(contentsOfURL: link, encoding:  String.Encoding.utf8).replacingOccurrences(of: "<!DOCTYPE html>", with: "")
            /*do {
                try contentStr = String(contentsOfURL: link, encoding:  String.Encoding.utf8).replacingOccurrences(of: "<!DOCTYPE html>", with: "")
            } catch {
                print("error")
            }*/
            let cnt = "<content>\(contentStr)</content>"
            //println(cnt)
            if let data = cnt.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                self.parser = XMLParser(data: data)
            }
            self.parser?.delegate = self
            self.parser?.shouldResolveExternalEntities = false
            self.parser?.parse()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("start parse")
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        //println("end parse")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: NSError) {
        //println("paser error \(parseError)")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //println("parser \(elementName)")
        if elementName == "div" {
            if attributeDict["class"] as String! == "entry" {
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
    
    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
        //println("found character \(string)")
        if foundEntry {
            self.textView.text? += string
        }
    }

}
