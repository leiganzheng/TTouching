//
//  AboutViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/7.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("版本", tableName: "Localization",comment:"jj")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = .None
        }

        cell.textLabel?.text = NSLocalizedString("版本号", tableName: "Localization",comment:"jj")
        let lb = UILabel(frame:CGRectMake(0,0, 80, 54) )
        lb.text = "1.0"
        cell.accessoryView = lb
        return cell
    }



}
