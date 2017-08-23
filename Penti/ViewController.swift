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
  
  override func viewDidDisappear(_ animated: Bool) {
    FeedsPreference.saveVisitedIds(FeedItem.visited)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    FeedsPreference.handleFirstLaunch()
    FeedItem.loadVisitedIds()
    NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: [NSUbiquitousKeyValueStore.default()])
    setupNavigationBar()
    setUpTableView()
    setUpRecognizers()
    fetchFeedCache()
  }
  
  func storeDidChange(_ notification:Notification){
    NSLog("storeDidChange \(notification)")
    FeedsPreference.mergeStoreVisitedIds()
  }
    
    func setupNavigationBar() {
        let image = UIImage.init(named: "ic_list")
        let settings = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(showSettings))
        self.navigationItem.rightBarButtonItem = settings
    }
    
    func showSettings() {
       self.navigationController?.performSegue(withIdentifier: "showSettings", sender: self)
    }
  
  func setUpTableView(){
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorStyle = .none
    
    self.tableView.addPullToRefresh {
      NSLog("refresh")
      self.fetchPages(1)
      self.tableView.pullToRefreshView.stopAnimating()
    }
    self.tableView.addInfiniteScrolling {
      NSLog("load more")
      self.fetchPages(self.currentPage+1)
      self.tableView.infiniteScrollingView.stopAnimating()
    }
  }
  
  func setUpRecognizers(){
//    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigationBarTap(_:)))
//    self.navigationController?.navigationBar.addGestureRecognizer(tapRecognizer)
  }
  
  func navigationBarTap(_ recognizer:UIGestureRecognizer){
    self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
  }
  
  func fetchFeedCache(){
    PentiApi.sharedInstance().getFeedCache { (newItems) in
      NSLog("getFeedCache received \(String(describing: newItems?.first?.id))")
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
  
  func fetchPages(_ page: Int){
    if !dataInitialized {
      self.tableView.isHidden = true
      let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
      hud.bezelView.color = Colors.mainColor
      hud.animationType = .fade
    }
    NSLog("fetchPages page=\(page)")
    self.currentPage = page
    PentiApi.sharedInstance().getPage(page) {[unowned self] (newItems) in
      NSLog("fetchPages received \(String(describing: newItems?.first?.id))")
      if !self.dataInitialized {
        self.dataInitialized = true
        MBProgressHUD.hide(for: self.view, animated: true)
        self.tableView.isHidden = false
      }
      self.tableView.separatorStyle = .singleLine
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
        let controller = segue.destination as! DetailViewController
        controller.item = items[selectedRow]
    } else if segue.identifier == "showSettings" {
        let controller = segue.destination as! SettingsViewController
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
//        }
    }
  }
  
  

}

extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FeedItemCell
    cell.setContent(items[indexPath.row])
    return cell
  }

}

extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedRow = indexPath.row
    NSLog("didSelectRowAtIndexPath \(indexPath.row)")
    FeedItem.addVisitedId( items[indexPath.row].id)
    tableView.reloadRows(at: [indexPath], with: .none)
    self.performSegue(withIdentifier: "showDetail", sender: nil)
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
}

