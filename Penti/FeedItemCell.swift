//
//  FeedItemCell.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import UIKit

class FeedItemCell: UITableViewCell {
  @IBOutlet var titleLabel:UILabel!
  @IBOutlet var authorLabel:UILabel!
  @IBOutlet var dateLabel:UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func setContent(_ item: FeedItem) {
    let title = item.title ?? ""
    let author = item.author ?? ""
    let dateStr: String
    if let date = item.date {
      dateStr = FeedItem.dateFormatter.string(from: date)
    }else {
      dateStr = ""
    }
    let attributeString = NSMutableAttributedString(string: title)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    paragraphStyle.lineSpacing = 6.0
    attributeString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: (title as NSString).length))
    titleLabel.attributedText = attributeString
    let color = FeedItem.isVisited(item.id) ? UIColor.gray : UIColor.black
    titleLabel.textColor = color
    authorLabel.textColor = color
    dateLabel.textColor = color
    authorLabel.text = author
    dateLabel.text = dateStr
  }

}
