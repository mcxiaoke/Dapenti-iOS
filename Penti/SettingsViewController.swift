//
//  SettingsViewController.swift
//  Penti
//
//  Created by Xiaoke Zhang on 2017/8/22.
//  Copyright © 2017年 mcxiaoke. All rights reserved.
//

import UIKit
import MessageUI

internal let ReuseIdentifier = "SettingsItemCell"

extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

// https://stackoverflow.com/questions/28254377/get-app-name-in-swift
extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    var buildNumber: String {
        return infoDictionary?[kCFBundleVersionKey as String] as? String ?? "0"
    }
    
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }
    
    var bundleName: String {
        return infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
}

class SettingsItem: AnyObject {
    let title:String
    let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
    
}

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var items: [SettingsItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupItems()
    }
    
    func setupHeader() {
        let b = Bundle.main
        self.headerTitle.text = "\(b.displayName) v\(b.versionNumber)"
    }
    
    func setupItems() {
        let author = SettingsItem(title: "作者主页") {
            let url = URL(string: "https://github.com/mcxiaoke")!
            self.safariOpen(url)
        }
        let project = SettingsItem(title: "开源项目") {
            let url = URL(string: "https://github.com/mcxiaoke/Dapenti-iOS")!
            self.safariOpen(url)
        }
        let appStore = SettingsItem(title: "应用评分") {
            let url = URL(string: "https://itunes.apple.com/us/app/id1132824499?mt=8")!
            UIApplication.shared.openURL(url)
        }
        let email = SettingsItem(title: "意见反馈") {
            self.sendEmail()
        }
        let website = SettingsItem(title: "喷嚏网") {
            let url = URL(string: "http://www.dapenti.com/")!
            self.safariOpen(url)
        }
        self.items += [author, project, appStore, email, website]
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier)!
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.action != nil ? .disclosureIndicator : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        item.action?()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func sendEmail() {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        let dateStr = df.string(from: Date())
        vc.setSubject("喷嚏图卦App意见反馈 - \(dateStr)")
        vc.setMessageBody("\n\n\n\n\n\ndddd", isHTML: false)
        vc.setToRecipients(["penti-app@mcxiaoke.com"])
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        NSLog("mail didFinishWith \(result.rawValue) \(String(describing: error))")
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
}
