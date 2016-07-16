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
  
  func setContent(item: FeedItem) {
    let title = item.title ?? ""
    let author = item.author ?? ""
    let dateStr: String
    if let date = item.date {
      dateStr = FeedItem.dateFormatter.stringFromDate(date)
    }else {
      dateStr = ""
    }
    let attributeString = NSMutableAttributedString(string: title)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .ByWordWrapping
    paragraphStyle.lineSpacing = 6.0
    attributeString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: (title as NSString).length))
    titleLabel.attributedText = attributeString
    titleLabel.font = FeedItem.isVisited(item.id) ? UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
      : UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
    authorLabel.text = author
    dateLabel.text = dateStr
  }

}
