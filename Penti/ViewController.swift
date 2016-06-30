//
//  ViewController.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/29.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let cellIdentifier = "FeedItemCell"
  
  @IBOutlet weak var tableView:UITableView!
  
  var items: [FeedItem] = []
  var selectedRow: Int = -1

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
    
    PentiApi.sharedInstance().getPage(1, count: 30) { (feeds) in
      if let feeds = feeds {
        self.items = feeds
        self.tableView.reloadData()
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      print("prepareForSegue \(selectedRow)")
      let controller = segue.destinationViewController as! DetailViewController
      controller.item = items[selectedRow]
    }
  }
  
  

}

extension ViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedItemCell
    cell.titleLabel?.text = item.title ?? ""
    cell.subtitleLabel?.text = item.link?.absoluteString ?? ""
    return cell
  }

}

extension ViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.selectedRow = indexPath.row
    print("didSelectRowAtIndexPath \(indexPath.row)")
    self.performSegueWithIdentifier("showDetail", sender: nil)
  }
  
}

