//
//  ArticleCell.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 26/10/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell, NSXMLParserDelegate {

    /*class func calculateCellHeigthWithArticle(article: [NSObject: AnyObject]!) -> CGFloat {
        //println("article = \(article)")
        var titleLabel = UILabel(frame:CGRectMake(0, 0, 210, 0))
        titleLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        //CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
        titleLabel.text = article["title"] as? String
        titleLabel.lineBreakMode = .ByWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.sizeToFit()
        var descriptionLabel = UILabel(frame:CGRectMake(0, 0, 210, 0))
        descriptionLabel.font = UIFont.systemFontOfSize(14)
        descriptionLabel.text = article["description"] as? String
        descriptionLabel.lineBreakMode = .ByWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        //println(descriptionLabel.text)
        if descriptionLabel.frame.size.height <= 49 {
            //println("cell height = 100")
            return 100
        }
        else {
            //println("cell height = \(28 + titleLabel.frame.size.height + descriptionLabel.frame.size.height)")
            return 28 + titleLabel.frame.size.height + descriptionLabel.frame.size.height
        }
    }*/

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    private var article: [NSObject: AnyObject]?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var articleImage: UIImageView!
    private var articleLink: NSURL?

    func setDataWithArticle(article: [NSObject: AnyObject]!) {
        setWhiteImage()
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
        /*if self.itemDescription?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 100 {
        var start = self.itemDescription?.startIndex
        var end = advance(start!, 100)
        self.itemDescription = self.itemDescription?.substringWithRange(Range<String.Index>(start: start!, end: end)).stringByAppendingString("...")
        }*/
        self.article = article
        self.titleLabel.text = (article["title"] as? String)?.stringByReplacingOccurrencesOfString("\n\t\t", withString: "")
        self.titleLabel.adjustsFontSizeToFitWidth = false
        self.titleLabel.numberOfLines = 0
        if var descriptionText = article["description"] as? String {
            self.descriptionLabel.text = descriptionText
            self.descriptionLabel.adjustsFontSizeToFitWidth = false
            self.descriptionLabel.numberOfLines = 0
            //println("title = \(self.titleLabel.text)")
            //println("des = \(descriptionText)")
        }
    }
    
    internal func setWhiteImage() {
        self.articleImage.image = UIImage(named: "white")
        self.articleImage.contentMode = .ScaleAspectFill
        self.articleImage.clipsToBounds = true
    }
    
    func setImageViewWithImage(image: UIImage) {
        articleImage.image = image
        articleImage.contentMode = .ScaleAspectFill
        articleImage.clipsToBounds = true
    }
}
