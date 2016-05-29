//
//  SelectBankViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/9/9.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

class SelectBankViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    var searchBar : UISearchBar!
    var tableView: UITableView!
    var dataArray : NSArray!
    var finished: ((bankInfoDict: NSDictionary) -> Void)? // 完成的回掉
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "UserCenter_"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            QNTool.configTableViewCellDefault(cell)
            cell.backgroundColor = UIColor.whiteColor()
            cell.contentView.backgroundColor = UIColor.whiteColor()
        }
        let dic = self.dataArray[indexPath.row] as! NSDictionary
        cell.textLabel!.text = dic["bankName"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
        self.finished!(bankInfoDict: self.dataArray[indexPath.row] as! NSDictionary)
    }
    
    // MARK: Private Method
    func subViewInit() {
        self.title = "选择开户银行"
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.view.backgroundColor = defaultBackgroundGrayColor

        self.tableView = UITableView(frame: CGRectMake(0, 0, screenWidth , screenHeight))
        self.tableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , .FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
    }
}
