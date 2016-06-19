//
//  CategoryViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 2/11/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

import UIKit

class CategoryViewController: UITableViewController, NSXMLParserDelegate {

    private var categories = ["News": "news", "Featured Review": "featured-review", "Apple": "news/apple", "iPhone": "news/iphone", "iPad": "news/ipad", "iPod": "news/ipod-news", "iOS": "news/ios-news", "OS X": "news/os-x-news", "iCloud": "news/icloud-news", "Apple Watch": "news/apple-watch", "Apple TV": "news/apple-tv-news", "Beats": "news/beats-news", "Steve Jobs": "news/steve-jobs-2"]
    private var categoriesKey = ["News", "Featured Review", "Apple", "iPhone", "iPad", "iPod", "iOS", "OS X", "iCloud", "Apple Watch", "Apple TV", "Beats", "Steve Jobs"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryID", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.categoriesKey[indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
            if let cat = self.categories[text] {
                performSegueWithIdentifier("ToSubFeed", sender: cat)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueID = segue.identifier
        if segueID == "ToSubFeed" {
            let vc = segue.destinationViewController as! SubFeedViewController
            if let subString = sender as? String {
                if let url = NSURL(string: "http://www.macthai.com/category/\(subString)/feed") {
                    vc.url = url
                }
            }
        }
    }
    

    // MARK: - XML Parser Delegate
/*
    func parserDidStartDocument(parser: NSXMLParser) {
        println("parser start")
    }

    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        println("error occured")
        println("\(parseError.localizedDescription)")
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        println("didStartElement = \(elementName)")
        self.elementName = elementName
        if elementName == "option" {
            self.catName = ""
            self.catValue = attributeDict["value"] as? String
        }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if self.elementName == "option" {
            if let string = string {
                self.catName? += string
            }
        }
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.elementName == "option" {
            if let value = self.catValue, name = self.catName {
                self.categories.append([name: value])
                //println(self.categories)
            }
        }
    }
*/
}
