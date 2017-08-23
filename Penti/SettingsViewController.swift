//
//  SettingsViewController.swift
//  Penti
//
//  Created by Xiaoke Zhang on 2017/8/22.
//  Copyright © 2017年 mcxiaoke. All rights reserved.
//

import UIKit

class SettingsItemCell: UITableViewCell {
    @IBInspectable var key: String = ""
}

class SettingsViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SettingsItemCell {
            print("didSelectRowAt \(indexPath) key=\(cell.key)")
            switch cell.key {
            case "ItemProject":
                let url = URL(string: "https://github.com/mcxiaoke/Dapenti-iOS")!
                safariOpen(url)
            case "ItemWebSite":
                let url = URL(string: "http://www.dapenti.com/")!
                safariOpen(url)
            case "ItemStore":
                let url = URL(string: "https://itunes.apple.com/us/app/id1132824499?mt=8")!
                UIApplication.shared.openURL(url)
            default:
                break
            }
        }
    }
    
    
}
