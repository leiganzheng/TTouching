//
//  DoctorIDShowViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/9/8.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

class DoctorIDShowViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var customTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.title = "ID"
        self.view.autoresizesSubviews = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 288
        }else {
            return 88
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cellId = "cell0"
            var cell: UITableViewCell! = self.customTableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            cell.selectionStyle = .None
            return cell
        }else {
            let cellId = "cell1"
            var cell: UITableViewCell! = self.customTableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            cell.selectionStyle = .None
            (cell.viewWithTag(100) as! UILabel).text = "医生ID：\(g_doctor!.proxyId!)"
            return cell
        }
        
    }
}
