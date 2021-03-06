//
//  HomeViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 26/10/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//
//  <div>Icons made by <a href="http://www.flaticon.com/authors/picol" title="Picol">Picol</a>, <a href="http://www.flaticon.com/authors/ocha" title="OCHA">OCHA</a>, <a href="http://www.flaticon.com/authors/bogdan-rosu" title="Bogdan Rosu">Bogdan Rosu</a>, <a href="http://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a>, <a href="http://www.flaticon.com/authors/plainicon" title="Plainicon">Plainicon</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>

import UIKit

class HomeViewController: UITableViewController, NSXMLParserDelegate {

    private var feeds = [[NSObject: AnyObject]]()
    @IBOutlet private weak var activityItem: UIBarButtonItem!
    private var url = NSURL(string: "http://www.macthai.com/feed/")!
    private var page = 1
    private var parser: NSXMLParser?
    private var items: [NSObject: AnyObject]?
    private var itemTitle: String?
    private var itemLink: String?
    private var itemElement: String?
    private var itemDescription: String?
    private var itemContent: String?
    private var itemAuthor: String?
    private var itemPublishDate: String?
    private var itemCategory: [String]?
    private var itemImageLink: NSURL?
    private var presented = false
    private var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
    var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.activityIndicatorViewStyle = .Gray
        self.activityItem.customView = self.activityIndicator
        self.activityIndicator.startAnimating()
        var refresh = UIRefreshControl()
        refresh.tintColor = UIColor.grayColor()
        refresh.addTarget(self, action: "refreshTable:", forControlEvents: .ValueChanged)
        self.refreshControl = refresh
        
        if tableView.respondsToSelector("layoutMargins") {
            tableView.estimatedRowHeight = 88
            tableView.rowHeight = UITableViewAutomaticDimension
        }
        
        // Set custom indicator
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        // Add infinite scroll handler
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            let scrollView = scrollView as! UITableView
            self.fetchData({
                scrollView.finishInfiniteScroll()
            })
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !self.presented {
            self.feeds = [[NSObject: AnyObject]]()
            self.activityIndicator.startAnimating()
            self.presented = true
            /*if let data = NSData(contentsOfURL: self.url) {
                var string = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("data = \(string)")
            }*/
            networkActivity(true)
            self.parser = NSXMLParser(contentsOfURL: self.url)
            networkActivity(false)
            self.parser?.delegate = self
            self.parser?.shouldResolveExternalEntities = false
            self.parser?.parse()
            self.tableView.reloadData()
        }
    }
    
    internal func refreshTable(refresh: UIRefreshControl!) {
        self.activityIndicator.startAnimating()
        self.page = 1
        self.feeds = [[NSObject: AnyObject]]()
        networkActivity(true)
        self.parser = NSXMLParser(contentsOfURL: self.url)
        networkActivity(false)
        self.parser?.delegate = self
        self.parser?.shouldResolveExternalEntities = false
        self.parser?.parse()
        tableView.reloadData()
        refresh.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func networkActivity(onoff: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = onoff
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as! ArticleCell
        var article = self.feeds[indexPath.row] as [NSObject: AnyObject]
        cell.setDataWithArticle(article)
        /*
        if var articleContent = article["content"] as? String {
            var start = articleContent.startIndex
            var end = advance(start, 500)
            articleContent = articleContent.substringWithRange(Range<String.Index>(start: start, end: end))
        }
        */
        
        var q = dispatch_queue_create("q", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(q, { () -> Void in
            if let image = self.imageCache.objectForKey(article["link"]!) as? UIImage {
                cell.setImageViewWithImage(image)
            }
            else {
                if let content = article["content"] as? String {
                    var contentStr = "<content>\(content)</content>"
                    if let data = contentStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                        self.itemImageLink = NSURL(string: "waiting")
                        self.parser = NSXMLParser(data: data)
                        self.parser?.delegate = self
                        self.parser?.shouldResolveExternalEntities = false
                        self.parser?.parse()
                        //println("row = \(indexPath.row) imageLink = \(self.itemImageLink)")
                        if let itemImageLink = self.itemImageLink {
                            if itemImageLink != NSURL(string: "waiting") {
                                //println("if \(itemImageLink)")
                                self.networkActivity(true)
                                if let imageData = NSData(contentsOfURL: itemImageLink) {
                                    if let image = UIImage(data: imageData) {
                                        self.imageCache.setObject(image, forKey: article["link"]!)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            //println("row = \(indexPath.row)")
                                            if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? ArticleCell {
                                                updateCell.setImageViewWithImage(image)
                                            }
                                        })
                                    }
                                }
                                self.networkActivity(false)
                            }
                            else {
                                cell.setWhiteImage()
                            }
                        }
                    }
                }
            }
        })
        
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
    
    //MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ToBrowser", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: XML Parser Delegate

    internal func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if let string = string {
            if self.itemElement == "title" {
                if var itemTitle = self.itemTitle {
                    itemTitle += string
                    self.itemTitle = itemTitle
                }
            }
            else if self.itemElement == "link" {
                if var itemLink = self.itemLink {
                    itemLink += string
                    self.itemLink = itemLink
                }
            }
            else if self.itemElement == "description" {
                if var itemDes = self.itemDescription {
                    itemDes += string
                    self.itemDescription = itemDes
                }
            }
            else if self.itemElement == "content:encoded" {
                if var itemContent = self.itemContent {
                    itemContent += string
                    self.itemContent = itemContent
                }
            }
            else if self.itemElement == "pubDate" {
                if var itemPublishDate = self.itemPublishDate {
                    itemPublishDate += string
                    self.itemPublishDate = itemPublishDate
                }
            }
            else if self.itemElement == "dc:creator" {
                if var itemAuthor = self.itemAuthor {
                    itemAuthor += string
                    self.itemAuthor = itemAuthor
                }
            }
            else if self.itemElement == "category" {
                if var itemCategory = self.itemCategory {
                    itemCategory.append(string)
                    self.itemCategory = itemCategory
                }
            }
        }
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let items = self.items {
                self.items = [String: AnyObject]()
                if var itemDes = self.itemDescription {
                    var descriptionLength: Int
                    if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                        descriptionLength = 100
                    }
                    else {
                        descriptionLength = 300
                    }
                    if itemDes.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > descriptionLength {
                        var start = itemDes.startIndex
                        var end = advance(start, descriptionLength)
                        itemDes = itemDes.substringWithRange(Range<String.Index>(start: start, end: end)).stringByAppendingString("...")
                    }
                    self.itemDescription = itemDes.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                    println("des = \(self.itemDescription)")
                }
                if var itms = self.items {
                    if let link = self.itemLink {
                        itms["link"] = link.stringByReplacingOccurrencesOfString("\n\t\t", withString: "", options: .RegularExpressionSearch, range: Range<String.Index>(start: link.startIndex, end: link.endIndex))
                    }
                    if let title = self.itemTitle {
                        itms["title"] = title.stringByReplacingOccurrencesOfString("\n\t\t", withString: "", options: .RegularExpressionSearch, range: Range<String.Index>(start: title.startIndex, end: title.endIndex))
                        println("title = \(title)")
                    }
                    if let description = self.itemDescription {
                        itms["description"] = description
                    }
                    if let content = self.itemContent {
                        itms["content"] = content
                    }
                    if let author = self.itemAuthor {
                        itms["author"] = author
                    }
                    if let imageLink = self.itemImageLink {
                        itms["imageLink"] = imageLink
                    }
                    self.feeds.append(itms)
                }
                self.itemTitle = nil
                self.itemLink = nil
                self.items = nil
                self.itemDescription = nil
                self.itemContent = nil
                self.itemAuthor = nil
                self.itemPublishDate = nil
                self.itemCategory = nil
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        //println("didStartElement")
        self.itemElement = elementName
        if self.itemElement == "item" {
            self.items = [NSObject: AnyObject]()
            self.itemCategory = [String]()
            self.itemTitle = ""
            self.itemDescription = ""
            self.itemLink = ""
            self.itemContent = ""
            self.itemPublishDate = ""
            self.itemAuthor = ""
        }
        if self.itemElement == "content:encoded" {
            self.itemImageLink = NSURL(string: "waiting")
        }
        if self.itemElement == "img" && self.itemImageLink == NSURL(string: "waiting") {
            self.itemImageLink = NSURL(string: attributeDict["src"] as! String)
            parser.abortParsing()
        }
        /*if self.itemElement == "section" {
            var style = attributeDict["style"]
            println("\(style)")
        }*/
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        activityIndicator.stopAnimating()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var identifier = segue.identifier
        if identifier == "ToBrowser" {
            var vc = segue.destinationViewController as! BrowserViewController
            if let sender = sender as? NSIndexPath {
                let data: [NSObject: AnyObject] = self.feeds[sender.row]
                if let linkStr = data["link"] as? String {
                    if let link = NSURL(string: linkStr) {
                        vc.link = NSURLRequest(URL: link)
                    }
                }
            }
            //vc.hidesBottomBarWhenPushed = true
        }
        else if identifier == "ToArticle" {
            var vc = segue.destinationViewController as! ArticleViewController
            if let sender = sender as? NSIndexPath {
                let data: [NSObject: AnyObject] = self.feeds[sender.row]
                if let linkStr = data["link"] as? String {
                    vc.articleLink = NSURL(string: linkStr)
                }
            }
        }
    }
    
    // MARK: - Fetch Data
    
    private func fetchData(handler: ((Void) -> Void)?) {
        //println("fetchData")
        let hits: Int = Int(CGRectGetHeight(tableView.bounds)) / 44
        //let requestURL = apiURL(hits, page: currentPage)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleResponse(error)
                
                //self.activityIndicator.stopAnimating()
                //UIApplication.sharedApplication().stopNetworkActivity()
                
                handler?()
            })
        })
        
        //UIApplication.sharedApplication().startNetworkActivity()
        self.activityIndicator.startAnimating()
        
        // I run task.resume() with delay because my network is too fast
        var time = dispatch_time(DISPATCH_TIME_NOW, 0)
        dispatch_after(time, dispatch_get_main_queue(), {
            task.resume()
        })
    }
    
    private func handleResponse(error: NSError!) {
        
        var lastPaged = self.feeds.count-1
        if let path = self.url.absoluteString?.stringByAppendingPathComponent("?paged=\(++self.page)") {
            if let url = NSURL(string: path) {
                if let data = NSData(contentsOfURL: url) {
                    networkActivity(true)
                    self.parser = NSXMLParser(data: data)
                    networkActivity(false)
                    self.parser?.delegate = self
                    self.parser?.shouldResolveExternalEntities = false
                    self.parser?.parse()
                    tableView.reloadData()
                }
                else {
                    
                }
            }
        }
    }
}
