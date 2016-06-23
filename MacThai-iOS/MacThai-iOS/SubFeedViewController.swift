//
//  SubFeedViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 26/12/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

import UIKit
import SafariServices

class SubFeedViewController: UITableViewController, XMLParserDelegate {

    private var feeds = [[NSObject: AnyObject]]()
    private var page = 1
    private var presented = false
    private var feedTitle: String?
    var url: URL?
    @IBOutlet private weak var activityItem: UIBarButtonItem!
    private var parser: XMLParser?
    private var items: [NSObject: AnyObject]?
    private var itemTitle: String?
    private var itemLink: String?
    private var itemElement: String?
    private var itemDescription: String?
    private var itemContent: String?
    private var itemAuthor: String?
    private var itemPublishDate: String?
    private var itemCategory: [String]?
    private var itemImageLink: URL?
    private var foundTitle = false
    private var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    private var imageCache = Cache<AnyObject, AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.activityIndicator.activityIndicatorViewStyle = .gray
        self.activityItem.customView = self.activityIndicator
        self.activityIndicator.startAnimating()
        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor.gray()
        refresh.addTarget(self, action: #selector(SubFeedViewController.refreshTable(_:)), for: .valueChanged)
        self.refreshControl = refresh
        
        /*if tableView.respondsToSelector("layoutMargins") {
            tableView.estimatedRowHeight = 88
            tableView.rowHeight = UITableViewAutomaticDimension
        }*/
        
        // Set custom indicator
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        // Add infinite scroll handler
        tableView.addInfiniteScroll { (scrollView) -> Void in
            let scrollView = scrollView as! UITableView
            self.fetchData({
                scrollView.finishInfiniteScroll()
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presented {
            feeds = [[NSObject: AnyObject]]()
            activityIndicator.startAnimating()
            presented = true
            if let url = self.url {
                networkActivity(true)
                parser = XMLParser(contentsOf: url)
                networkActivity(false)
                parser?.delegate = self
                parser?.shouldResolveExternalEntities = false
                parser?.parse()
                tableView.reloadData()
            }
            else {
                print("url error")
            }
        }
    }
    
    internal func refreshTable(_ refresh: UIRefreshControl!) {
        activityIndicator.startAnimating()
        feeds = [[NSObject: AnyObject]]()
        page = 1
        networkActivity(true)
        parser = XMLParser(contentsOf: self.url!)
        networkActivity(false)
        parser?.delegate = self
        parser?.shouldResolveExternalEntities = false
        parser?.parse()
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func networkActivity(_ onoff: Bool) {
        UIApplication.shared().isNetworkActivityIndicatorVisible = onoff
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        var article = self.feeds[(indexPath as NSIndexPath).row] as [NSObject: AnyObject]
        cell.setDataWithArticle(article)
        let q = DispatchQueue(label: "q", attributes: DispatchQueueAttributes.concurrent)
        q.async(execute: { () -> Void in
            if let image = self.imageCache.object(forKey: article["link"]!) as? UIImage {
                cell.setImageViewWithImage(image)
            }
            else {
                if let content = article["content"] as? String {
                    let contentStr = "<content>\(content)</content>"
                    if let data = contentStr.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                        self.itemImageLink = URL(string: "waiting")
                        self.parser = XMLParser(data: data)
                        self.parser?.delegate = self
                        self.parser?.shouldResolveExternalEntities = false
                        self.parser?.parse()
                        if self.itemImageLink != URL(string: "waiting") {
                            if let imageLink = self.itemImageLink {
                                self.networkActivity(true)
                                if let imageData = try? Data(contentsOf: imageLink) {
                                    if let image = UIImage(data: imageData) {
                                        self.imageCache.setObject(image, forKey: article["link"]!)
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            if let updateCell = tableView.cellForRow(at: indexPath) as? ArticleCell {
                                                updateCell.setImageViewWithImage(image)
                                            }
                                        })
                                    }
                                }
                                self.networkActivity(false)
                            }
                        }
                    }
                }
            }
        })
        
        return cell
    }
    
    /*override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ArticleCell.calculateCellHeigthWithArticle(feeds[indexPath.row] as [NSObject: AnyObject])
    }*/
    
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
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaults().object(forKey: "readability") as? Bool == true {
            performSegue(withIdentifier: "ToBrowser", sender: indexPath)
        }
        else {
            let data: [NSObject: AnyObject] = self.feeds[(indexPath as NSIndexPath).row]
            if let linkStr = data["link"] as? String {
                if let link = URL(string: linkStr) {
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(url: link, entersReaderIfAvailable: false)
                        present(vc, animated: true, completion: nil)
                    } else {
                        performSegue(withIdentifier: "ToBrowser", sender: indexPath)
                    }
                }
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - XML Parser Delegate

    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.itemElement == "title" {
            if self.foundTitle {
                if var itemTitle = self.itemTitle {
                    itemTitle += string
                    self.itemTitle = itemTitle
                }
            }
            else {
                self.feedTitle? += string
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

    func parserDidEndDocument(_ parser: XMLParser) {
        if let titleComponents = self.feedTitle?.components(separatedBy: " ") {
            if titleComponents.count >= 3 {
                self.navigationItem.title = titleComponents[2]
                for i in 3..<titleComponents.count {
                    self.navigationItem.title? += " \(titleComponents[i])"
                }
            }
        }
        activityIndicator.stopAnimating()
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let _ = self.items {
                var descriptionLength: Int
                if (UIDevice.current().userInterfaceIdiom == .phone) {
                    descriptionLength = 100
                }
                else {
                    descriptionLength = 300
                }
                if self.itemDescription?.lengthOfBytes(using: String.Encoding.utf8) > descriptionLength {
                    let start = self.itemDescription?.startIndex
                    let end = self.itemDescription?.index((self.itemDescription?.startIndex)!, offsetBy: descriptionLength)
                    self.itemDescription = (self.itemDescription?.substring(with: (start! ..< end!)))! + "..."
                }
                self.itemDescription = self.itemDescription?.removingPercentEncoding
                self.items = [String: AnyObject]()
                if var itms = self.items {
                    if let link = self.itemLink {
                        itms["link"] = link.replacingOccurrences(of: "\n\t\t", with: "", options: .regularExpressionSearch, range: link.range(of: link))
                    }
                    if let title = self.itemTitle {
                        //itms["title"] = title.replacingOccurrences(of: "\n\t\t", with: "", options: .regularExpressionSearch, range: (title.characters.indices))
                        itms["title"] = title.replacingOccurrences(of: "\n\t\t", with: "", options: .regularExpressionSearch, range: title.range(of: title))
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
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        else if elementName == "title" {
            self.foundTitle = true
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
            self.itemImageLink = URL(string: "waiting")
        }
        else if self.itemElement == "title" && !self.foundTitle {
            self.feedTitle = ""
        }
        if self.itemElement == "img" && self.itemImageLink == URL(string: "waiting") {
            self.itemImageLink = URL(string: attributeDict["src"] as String!)
            parser.abortParsing()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier
        if identifier == "ToBrowser" {
            let vc = segue.destinationViewController as! BrowserViewController
            if sender is NSIndexPath {
                let sen = sender as! IndexPath
                let data: [NSObject: AnyObject] = self.feeds[(sen as NSIndexPath).row]
                if let linkStr = data["link"] as? String {
                    if let link = URL(string: linkStr) {
                        vc.link = URLRequest(url: link)
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch Data
    
    private func fetchData(_ handler: ((Void) -> Void)?) {
        //let hits: Int = Int(CGRectGetHeight(tableView.bounds)) / 44
        //let requestURL = apiURL(hits, page: currentPage)
        let task = URLSession.shared().dataTask(with: url!) { (data, response, error) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.handleResponse(error)
                
                self.activityIndicator.stopAnimating()
                //UIApplication.sharedApplication().stopNetworkActivity()
                
                handler?()
            })
        }
        
        //UIApplication.sharedApplication().startNetworkActivity()
        self.activityIndicator.startAnimating()
        
        let time = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
        DispatchQueue.main.after(when: time) { 
            task.resume()
        }
    }
    
    private func handleResponse(_ error: NSError!) {
        self.page += 1
        do {
            if let path = try URL(string: (self.url?.appendingPathComponent("?paged=\(self.page)").absoluteString?.removingPercentEncoding)!) {
                if let data = try? Data(contentsOf: path) {
                    networkActivity(true)
                    self.parser = XMLParser(data: data)
                    networkActivity(false)
                    self.parser?.delegate = self
                    self.parser?.shouldResolveExternalEntities = false
                    self.parser?.parse()
                    tableView.reloadData()
                    print(feeds)
                }
            }
        } catch {
            
        }
    }

}
