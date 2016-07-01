//
//  ViewController.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/29.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import UIKit
import SVPullToRefresh

class ViewController: UIViewController {
  
  let cellIdentifier = "FeedItemCell"
  
  @IBOutlet weak var tableView:UITableView!
  
  var currentPage = 1
  var items: [FeedItem] = []
  var selectedRow: Int = -1

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpTableView()
    fetchPages(1)
  }
  
  func setUpTableView(){
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorStyle = .None
    
    self.tableView.addPullToRefreshWithActionHandler {
      print("refresh")
      self.fetchPages(1)
      self.tableView.pullToRefreshView.stopAnimating()
    }
    self.tableView.addInfiniteScrollingWithActionHandler {
      print("load more")
      self.fetchPages(self.currentPage+1)
      self.tableView.infiniteScrollingView.stopAnimating()
    }
    
  }
  
  func fetchPages(page: Int){
    print("fetchPages page=\(page)")
    self.currentPage = page
    PentiApi.sharedInstance().getPage(page) { (newItems) in
      print("fetchPages received \(newItems?.first?.title)")
      self.tableView.separatorStyle = .SingleLine
      if let newItems = newItems {
        if page == 1 {
          self.items = newItems
        }else {
          self.items += newItems
        }
        self.tableView.reloadData()
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      print("prepareForSegue \(self.tableView.indexPathForSelectedRow)")
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
    let title = item.title ?? ""
    let author = item.author ?? ""
    let date = item.date!
    let dateStr = FeedItem.dateFormatter.stringFromDate(date)
    cell.titleLabel?.text = title
    cell.subtitleLabel?.text = "\(author) \(dateStr)"
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

