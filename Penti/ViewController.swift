//
//  ViewController.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/29.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import UIKit
import SVPullToRefresh
import MBProgressHUD

class ViewController: UIViewController {
  
  let cellIdentifier = "FeedItemCell"
  
  @IBOutlet weak var tableView:UITableView!
  
  var currentPage = 1
  var items = [FeedItem]()
  var selectedRow: Int = -1
  var dataInitialized = false
  
  override func viewDidDisappear(animated: Bool) {
    FeedsPreference.saveVisitedIds(FeedItem.visited)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpTableView()
    setUpRecognizers()
    fetchFeedCache()
    
    FeedsPreference.handleFirstLaunch()
    FeedItem.loadVisitedIds()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(storeDidChange(_:)), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: [NSUbiquitousKeyValueStore.defaultStore()])
  }
  
  func storeDidChange(notification:NSNotification){
    NSLog("storeDidChange \(notification)")
    FeedsPreference.mergeStoreVisitedIds()
  }
  
  func setUpTableView(){
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorStyle = .None
    
    self.tableView.addPullToRefreshWithActionHandler {
      NSLog("refresh")
      self.fetchPages(1)
      self.tableView.pullToRefreshView.stopAnimating()
    }
    self.tableView.addInfiniteScrollingWithActionHandler {
      NSLog("load more")
      self.fetchPages(self.currentPage+1)
      self.tableView.infiniteScrollingView.stopAnimating()
    }
  }
  
  func setUpRecognizers(){
//    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigationBarTap(_:)))
//    self.navigationController?.navigationBar.addGestureRecognizer(tapRecognizer)
  }
  
  func navigationBarTap(recognizer:UIGestureRecognizer){
    self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
  }
  
  func fetchFeedCache(){
    PentiApi.sharedInstance().getFeedCache { (newItems) in
      NSLog("getFeedCache received \(newItems?.first?.id)")
      if !self.dataInitialized {
        self.dataInitialized = true
        if let newItems = newItems {
          FeedItem.loadVisitedIds()
          self.items = newItems
          self.tableView.reloadData()
        }
        self.fetchPages(1)
      }
    }
  }
  
  func fetchPages(page: Int){
    if !dataInitialized {
      self.tableView.hidden = true
      let hud =  MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      hud.color = Colors.mainColor
      hud.animationType = .Fade
    }
    NSLog("fetchPages page=\(page)")
    self.currentPage = page
    PentiApi.sharedInstance().getPage(page) {[unowned self] (newItems) in
      NSLog("fetchPages received \(newItems?.first?.id)")
      if !self.dataInitialized {
        self.dataInitialized = true
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.tableView.hidden = false
      }
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
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedItemCell
    cell.setContent(items[indexPath.row])
    return cell
  }

}

extension ViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.selectedRow = indexPath.row
    NSLog("didSelectRowAtIndexPath \(indexPath.row)")
    FeedItem.addVisitedId( items[indexPath.row].id)
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    self.performSegueWithIdentifier("showDetail", sender: nil)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
}

