//
//  UserManagerViewController.swift
//  QooccDoctor
//
//  Created by LiuYu on 15/7/9.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

private let kKeyYear = "year"
private let kKeyList = "list"

private let kKeyMonthListTime = "addTime"
private let kKeyMonthListNum = "num"
private let kKeyMonthListMonth = "month"    // 自己加的，不属于服务器返回

/**
*  @author LiuYu, 15-07-09
*
*  // MARK: - 用户管理
*/
class UserManagerViewController: UIViewController, QNInterceptorNavigationBarShowProtocol, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!
    private var data: NSDictionary? // 用户数据
    private var yearList = [NSMutableDictionary]() // 用户数据 [{kKeyYear : year, kKeyList : 这里根据服务器返回}]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "管理用户"

        let tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        tableView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 10))
        tableView.tableHeaderView?.backgroundColor = defaultBackgroundGrayColor
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0.1))
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(tableView)
        self.tableView = tableView
        
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 从服务器抓取数据
    private func fetchData() {
        QNTool.showActivityView(nil, inView: self.view)
        QNNetworkTool.fetchUserManger(g_doctor!.doctorId, completion: { [weak self](dictionary, error) -> Void in
            if let strongSelf = self {
                QNTool.hiddenActivityView()
                if let errorCode = Int((dictionary?["errorCode"] as! String)) where errorCode == 0 {
                    strongSelf.data = dictionary
                    
                    // 对 monthList 先按年份分组， 在按年份和月份的倒序排序
                    if let monthList = dictionary!["recordList"] as? NSArray {
                        // 1. 分组
                        for monthData in monthList {
                            if let monthDictionary = monthData as? NSDictionary, let time = monthDictionary[kKeyMonthListTime] as? NSString {
                                let yearAndMonth = time.componentsSeparatedByString("-")
                                if yearAndMonth.count >= 2, let year = yearAndMonth[0] as? String, month = Int((yearAndMonth[1] ))?.description {
                                    var yearDictionary: NSMutableDictionary? = nil
                                    for dictionary in strongSelf.yearList {
                                        if dictionary[kKeyYear] as! String == year {
                                            yearDictionary = dictionary
                                            break
                                        }
                                    }
                                    
                                    // 月份没有记录过
                                    if yearDictionary == nil {
                                        yearDictionary = NSMutableDictionary(objects: [year, NSMutableArray()], forKeys: [kKeyYear,kKeyList])
                                        strongSelf.yearList.append(yearDictionary!)
                                    }
                                    
                                    // 修正数据，增加月份
                                    let trimedMonthData = NSMutableDictionary(dictionary: monthData as! [NSObject : AnyObject])
                                    trimedMonthData[kKeyMonthListMonth] = month
                                    (yearDictionary![kKeyList] as! NSMutableArray).addObject(trimedMonthData)
                                }
                            }
                        }
                        
                        // 2. 排序
                        strongSelf.yearList.sortInPlace({ (a1, a2) -> Bool in
                            return (a1[kKeyYear] as! String > a2[kKeyYear] as! String)
                        })
                        
                        for yearDictionary in strongSelf.yearList {
                            (yearDictionary[kKeyList] as! NSMutableArray).sortUsingComparator { (a1, a2) -> NSComparisonResult in
                                if let s1 = a1[kKeyMonthListMonth] as? String, s2 = a2[kKeyMonthListMonth] as? String {
                                    return s2.compare(s1, options: NSStringCompareOptions(), range: nil, locale: nil)
                                }
                                return NSComparisonResult.OrderedSame
                            }
                        }
                    }
                    
                    strongSelf.tableView?.reloadData()
                    // Added by LiuYu on 2015-7-17 (增加无用户的提示)
                    if strongSelf.tableView(strongSelf.tableView, numberOfRowsInSection: 1) == 0 {
                        if let isAvaliableString = dictionary?["isAvaliable"] as? String where isAvaliableString == "2" {
                            QNTool.showEmptyView("信息提交成功，请耐心等待审核", inView: strongSelf.tableView)
                        }
                        else {
                            QNTool.showEmptyView("没有可管理的用户，请稍后！", inView: strongSelf.tableView)
                        }
                    }
                    else {
                        QNTool.hiddenEmptyView(strongSelf.tableView)
                    }
                }
                else {
                    QNTool.showErrorPromptView(dictionary, error: error)
                }
            }
        })
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.data == nil ? 0 : 1 + self.yearList.count)    // 0：用户总数， 1...： 用户量变化
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) { return 1 }
        if section - 1 < self.yearList.count, let count = (self.yearList[section - 1][kKeyList] as? NSMutableArray)?.count {
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 && section - 1 < self.yearList.count {
            let currentYear = NSCalendar.currentCalendar().components(.Year, fromDate: NSDate()).year
            let year = Int((self.yearList[section - 1][kKeyYear] as! String)) ?? 0
            let view = UIView(frame: CGRectMake(0, 0, screenWidth, 30))
            let label = UILabel(frame: CGRectMake(0, 0, screenWidth, 30))
            label.text = "   " + ((currentYear == year) ? "今年" : "\(year)")
            label.textColor = tableViewCellDefaultTextColor
            label.backgroundColor = UIColor.whiteColor()
            label.font = UIFont.systemFontOfSize(14)
            
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            lineView.backgroundColor = defaultLineColor
            view.addSubview(label)
            view.addSubview(lineView)

            return view
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.1 : 30
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "   用户量变化" : ""
        label.textColor = defaultGrayColor
        label.backgroundColor = defaultBackgroundGrayColor
        label.font = UIFont.systemFontOfSize(14)
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 0 ? 30 : 10)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 82 : 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 用户总数
        if indexPath.section == 0 {
            let cellId = "UserManagerViewController_0"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell!.backgroundColor = UIColor.whiteColor()
                cell!.contentView.backgroundColor = UIColor.whiteColor()
                cell!.selectionStyle = .None
                
                let label1 = UILabel(frame: CGRect(x: 16, y: 18, width: cell!.contentView.bounds.width/2 - 16, height: 20))
                label1.autoresizingMask = [.FlexibleWidth , .FlexibleRightMargin]
                label1.tag = 1001
                label1.textAlignment = .Left
                label1.backgroundColor = UIColor.clearColor()
                cell!.contentView.addSubview(label1)
                
                let label2 = UILabel(frame: CGRect(x: 16, y: 48, width: cell!.contentView.bounds.width/2 - 16, height: 20))
                label2.autoresizingMask = [.FlexibleWidth , .FlexibleRightMargin]
                label2.tag = 1002
                label2.textAlignment = .Left
                label2.backgroundColor = UIColor.clearColor()
                cell!.contentView.addSubview(label2)
                
                let label3 = UILabel(frame: CGRect(x: cell!.contentView.bounds.width/2, y: 48, width: cell!.contentView.bounds.width/2, height: 20))
                label3.autoresizingMask = [.FlexibleWidth , .FlexibleLeftMargin]
                label3.tag = 1003
                label3.textAlignment = .Left
                label3.backgroundColor = UIColor.clearColor()
                cell!.contentView.addSubview(label3)
                let lineView = UIView(frame: CGRect(x: 0, y: 81, width: screenWidth, height: 1))
                lineView.backgroundColor = defaultLineColor
                cell!.contentView.addSubview(lineView)
            }
            if indexPath.row == 0 {
                let lineView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
                lineView.backgroundColor = defaultLineColor
                cell!.contentView.addSubview(lineView)
            }
            let attributedString = { (prefix: String, key: String, suffix: String) -> NSMutableAttributedString in
                let string = (self.data?[key] as? String ?? "0")
                let result = NSMutableAttributedString(string: prefix + string + suffix, attributes: [
                    NSFontAttributeName : UIFont.systemFontOfSize(16),
                    NSForegroundColorAttributeName : defaultGrayColor
                    ])
                result.setAttributes([
                    NSFontAttributeName : UIFont.systemFontOfSize(20),
                    NSForegroundColorAttributeName : UIColor.blackColor()
                    ], range: NSMakeRange(prefix.characters.count, string.characters.count))
                return result
            }
            
            (cell!.contentView.viewWithTag(1001) as? UILabel)?.attributedText = attributedString("总用户量 ", "userCount", " 人")
            (cell!.contentView.viewWithTag(1002) as? UILabel)?.attributedText = attributedString("VIP 用户 ", "vipCount", " 人")
            (cell!.contentView.viewWithTag(1003) as? UILabel)?.attributedText = attributedString("备注用户 ", "starCount", " 人")
            
            return cell!
        }
        // 新增用户
        else {
            let cellId = "UserManagerViewController_1"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                QNTool.configTableViewCellDefault(cell!)
                cell!.backgroundColor = UIColor.whiteColor()
                cell!.contentView.backgroundColor = UIColor.whiteColor()
                cell!.selectionStyle = .None

                let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
                countLabel.font = tableViewCellDefaultTextFont
                countLabel.textColor = UIColor.blackColor()
                countLabel.backgroundColor = UIColor.clearColor()
                countLabel.textAlignment = .Right
                cell!.accessoryView = countLabel
                
                if let _ = cell!.viewWithTag(100001) {
                } else {
                    let lineView = UIView(frame: CGRect(x: 0, y: 39, width: screenWidth, height: 1))
                    lineView.backgroundColor = defaultLineColor
                    lineView.tag = 100001
                    cell!.contentView.addSubview(lineView)
                }
            }
            if indexPath.row == 0 {
                let lineView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
                lineView.backgroundColor = defaultLineColor
                cell!.contentView.addSubview(lineView)
            }
            if indexPath.section - 1 < self.yearList.count, let dataList = self.yearList[indexPath.section - 1][kKeyList] as? NSMutableArray {
                if indexPath.row < dataList.count, let data = dataList[indexPath.row] as? NSDictionary {
                    if let month = data[kKeyMonthListMonth] as? String {
                        cell!.textLabel?.text = month + "月份"
                    }
                    if let countLabel = cell!.accessoryView as? UILabel {
                        
                        
                        if let num = Int((data[kKeyMonthListNum] as! String)) where num != 0 {
                            countLabel.text = (num > 0 ? "+" : "") + "\(num)"
                        }
                        else {
                            countLabel.text = ""
                        }
                    }
                }
            }
            
            return cell!
        }
    }
    
    
}
