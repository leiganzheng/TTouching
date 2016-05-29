//
//  BillingViewController.swift
//  QooccHealth
//
//  Created by GuJinyou on 15/4/13.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit

class QN_Bill: QN_Base {
    
    var billTime: String!
    var billMonth: String!
    var billDate: String!
    var billTypeString: String!
    var statusType: String!
    var money: String!
    
    
    required init!(_ dictionary: NSDictionary) {
        //长整型日期
        self.billTime = dictionary["billTime"] as! String
        let date = NSDate(timeIntervalSince1970: (self.billTime as NSString).doubleValue/1000)
        let dateFormate = NSDateFormatter()
        //年份月份
        dateFormate.dateFormat = "yyyy-MM"
        self.billMonth = dateFormate.stringFromDate(date)
        //月份日期和时间
        dateFormate.dateFormat = "MM-dd HH:mm"
        self.billDate = dateFormate.stringFromDate(date)
        self.billTypeString = dictionary["billName"] as! String
        self.statusType = dictionary["statusType"] as! String
        self.money = dictionary["money"] as! String
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.billTime, forKey:"billTime")
        dictionary.setValue(self.billTypeString, forKey:"billName")
        dictionary.setValue(self.statusType, forKey:"statusType")
        dictionary.setValue(self.money, forKey:"money")
        return dictionary
    }
    
    
}

class BillingModels: NSObject{
    var billList = [QN_Bill]()
    var billMonth: String!
    var monthBalance = "0"
}

class QN_Billings: QN_Base {
    
    var hasNextPage: Bool = false
    var pageNumber = 1
    // 接口Model，清单
    private var _billList = [QN_Bill]()
    // 年月：返现总额
    private var _monthBalanceList = [String:String]()
    // UIModel 年月:Model
    var uiBillList = [String : BillingModels]()
    
    
    required init!(_ dictionary: NSDictionary) {
        super.init(dictionary)
        self.hasNextPage = (dictionary["hasNextPage"] as! NSString).boolValue
        let billsArray = dictionary["billList"] as! NSArray
        for billDict in billsArray{
            _billList.append(QN_Bill(billDict as! NSDictionary))
        }
        self.formatBills()
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.hasNextPage.description, forKey:"hasNextPage")
        let array = NSMutableArray()
        for bill in _billList {
            array.addObject(bill.dictionary())
        }
        dictionary.setValue(array, forKey:"billList")
        return dictionary
    }
    
    func appendBillings(dictionary: NSDictionary){
        self.hasNextPage = (dictionary["hasNextPage"] as! NSString).boolValue
        var billModels = [QN_Bill]()
        let billsArray = dictionary["billList"] as! NSArray
        for billDict in billsArray{
            billModels.append(QN_Bill(billDict as! NSDictionary))
        }
        self.addBills(billModels)
    }
    
    func mouthsSortedArray() -> [String]{
        let array = Array(self.uiBillList.keys)
        array.sort{ $0 > $1 }
        return array
    }
    
    private func addBills(bills:[QN_Bill]!) {
        let array = NSMutableArray(array: _billList)
        array.addObjectsFromArray(bills)
        _billList = array as [AnyObject] as! [QN_Bill]
        self.formatBills()
    }
    
    private func formatBills() {
        self.uiBillList.removeAll(keepCapacity: false)
        if _billList.count > 0 {
            let bills = (_billList as NSArray)
            let sortDesc = NSArray(object: NSSortDescriptor(key: "billTime", ascending: true))
            let sortArray = bills.sortedArrayUsingDescriptors(sortDesc as! [NSSortDescriptor])
            for bill in sortArray{
                if let values = self.uiBillList[bill.billMonth]{
                    values.billList.append(bill as! QN_Bill)
                }
                else {
                    let bills = BillingModels()
                    bills.billMonth = QN_Billings.formatMonth(bill.billMonth!)
                    bills.billList.append(bill as! QN_Bill)
                    self.uiBillList[bill.billMonth] = bills
                }
            }
        }
    }
    
    private class func formatMonth(yearMonth: String) -> String {
        let curDate = NSDate()
        let dateFormate = NSDateFormatter()
        dateFormate.dateFormat = "yyyy-MM"
        let curMonth = dateFormate.stringFromDate(curDate)
        if yearMonth == curMonth {  // 本年度本月
            return "本月"
        }
        
        let year = (yearMonth as NSString).substringToIndex(4)
        let curYear = (curMonth as NSString).substringToIndex(4)
        let resultYear: String = (year == curYear) ? "" : (year + "年")
        
        let month = (yearMonth as NSString).substringFromIndex((yearMonth as NSString).length-2)
        switch month{
            case "01":
                return resultYear + "1月"
            case "02":
                return resultYear + "2月"
            case "03":
                return resultYear + "3月"
            case "04":
                return resultYear + "4月"
            case "05":
                return resultYear + "5月"
            case "06":
                return resultYear + "6月"
            case "07":
                return resultYear + "7月"
            case "08":
                return resultYear + "8月"
            case "09":
                return resultYear + "9月"
            case "10":
                return resultYear + "10月"
            case "11":
                return resultYear + "11月"
            case "12":
                return resultYear + "12月"
            default:
                return " "
                        
        }
    }
}

class BillingHeaderView: UIView {
    var monthLabel: UILabel!
    var balanceLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1)
        monthLabel = UILabel(frame: CGRectMake(16, 0, (self.frame.size.width)/2.0 - 16 , self.frame.size.height))
        monthLabel.font = UIFont.systemFontOfSize(14.0)
        monthLabel.textColor = UIColor(white: 150.0/255.0, alpha: 1.0)
        monthLabel.autoresizingMask = [.FlexibleRightMargin , .FlexibleHeight , .FlexibleWidth]
        self.addSubview(monthLabel)
        
        balanceLabel = UILabel(frame: CGRectMake(self.frame.size.width/2.0, 0, (self.frame.size.width)/2.0-16, self.frame.size.height))
        balanceLabel.textAlignment = NSTextAlignment.Right
        balanceLabel.font = UIFont.systemFontOfSize(14.0)
        balanceLabel.autoresizingMask = [.FlexibleLeftMargin , .FlexibleHeight , .FlexibleWidth]
        self.addSubview(balanceLabel)
       
        let lineBottom = UILabel(frame: CGRectMake(0, self.frame.size.height - 1, screenWidth,1))
        lineBottom.backgroundColor = defaultLineColor
        lineBottom.tag = 10002
        self.addSubview(lineBottom)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

//账单TableViewCell
class BillingTableViewCell: UITableViewCell {
    
    private(set) var leftLabel:UILabel? //
    private(set) var dateLabel:UILabel? //
    private(set) var moneyLabel:UILabel? //额度
    private(set) var staicLabel:UILabel? //完成状态
    
    private var _billModel:QN_Bill!
    var billModel: QN_Bill! {
        set{
            _billModel = newValue
            self.refreshCell()
        }
        get{
            return _billModel
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.clipsToBounds = true
        self.buildUI()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    //MARK:- Private Method
    private func buildUI(){
        let accessView = UIView(frame: CGRectMake(0, 0, 60, self.bounds.size.height))
        
        self.moneyLabel = UILabel(frame: CGRectMake(0, 0, accessView.bounds.size.width, accessView.bounds.size.height/2.0))
        self.moneyLabel?.font = UIFont.systemFontOfSize(14.0)
        self.moneyLabel?.autoresizingMask = [.FlexibleWidth , .FlexibleBottomMargin]
        self.moneyLabel?.textColor = UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1)
        self.moneyLabel?.textAlignment = NSTextAlignment.Right
        accessView.addSubview(self.moneyLabel!)
        
        self.staicLabel = UILabel(frame: CGRectMake(0, accessView.bounds.size.height/2.0, accessView.bounds.size.width, accessView.bounds.size.height/2.0))
        self.staicLabel?.font = UIFont.systemFontOfSize(12.0)
        self.staicLabel?.textAlignment = NSTextAlignment.Right
        self.staicLabel?.autoresizingMask = [.FlexibleWidth , .FlexibleTopMargin]
        accessView.addSubview(self.staicLabel!)
        
        self.accessoryView = accessView
    }
    
    private func refreshCell() {
        self.textLabel?.text = self.billModel.billTypeString
        self.textLabel?.font = UIFont.systemFontOfSize(14.0)
        self.detailTextLabel?.text = self.billModel.billDate
        self.detailTextLabel?.textColor = UIColor(white: 154/255.0, alpha: 1.0)
        self.moneyLabel?.text = self.billModel.money
        switch self.billModel.statusType{
            case "0":
                self.staicLabel?.text = "已完成"
                self.staicLabel?.textColor = UIColor(red: 65/255.0, green: 171/255.0, blue: 114/255.0, alpha: 1.0)
            case "1":
                self.staicLabel?.text = "进行中"
                self.staicLabel?.textColor = UIColor.redColor()
        default:
            break
        }
    }
    
    
}

/**
*  @author LiuYu, 15-06-05
*
*  //MARK:- 转账
*/
class BillingViewController: UIViewController, QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    private let cellId = "BillingViewController_Cell"
    private let cellIdHeader = "BillingViewController_Header"
    
    var tableView: UITableView!
    
    private var billingData: QN_Billings!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "账单"
        self.view.autoresizesSubviews = true
        
        self.tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        self.tableView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 10))
        self.tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: cellIdHeader)
        self.tableView.registerClass(BillingTableViewCell.self, forCellReuseIdentifier: cellId)
        self.view.addSubview(self.tableView)
        
        self.fetchData()
    }
    
    //MARK:- UITableViewDelegate & UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.billingData?.mouthsSortedArray().count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(cellIdHeader)
        
        var headerSubView = headerView?.contentView.viewWithTag(10086) as! BillingHeaderView!
        if headerSubView == nil {
            headerSubView = BillingHeaderView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 40))
            headerSubView?.tag = 10086
            headerView?.addSubview(headerSubView!)
        }
        
        let monthKey = self.billingData!.mouthsSortedArray()[section]
        if let billingModel = self.billingData!.uiBillList[monthKey] {
            headerSubView.monthLabel.text =  billingModel.billMonth // 月份
            let balance = billingModel.monthBalance
            let text = "+\(balance)"
            let attributedText = NSMutableAttributedString(string: text)
            let balanceRange = (text as NSString).rangeOfString(balance, options:   NSStringCompareOptions())
            attributedText.setAttributes([NSForegroundColorAttributeName:UIColor(red: 65/255.0, green: 171/255.0, blue: 114/255.0, alpha: 1.0)], range: NSMakeRange(0, balanceRange.location+balanceRange.length))
            attributedText.setAttributes([NSForegroundColorAttributeName:UIColor.grayColor()], range: NSMakeRange(balanceRange.location+balanceRange.length, (text as NSString).length - (balanceRange.location + balanceRange.length)))
//            headerSubView?.balanceLabel.attributedText = attributedText // 累计返现（显示富文本）
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let monthKey = self.billingData!.mouthsSortedArray()[section]
        let datas = self.billingData!.uiBillList[monthKey]
        return max(datas!.billList.count, 1) // 至少有1个，为了让他即使没有row，也要显示section header
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // 判断是否是空的,
        let monthKey = self.billingData!.mouthsSortedArray()[indexPath.section]
        let datas = self.billingData!.uiBillList[monthKey]
        if indexPath.row < datas!.billList.count {
            return 60
        }
        return 0.5 // 空行返回0.5来显示分割线
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? BillingTableViewCell
        let monthKey = self.billingData!.mouthsSortedArray()[indexPath.section]
        let datas = self.billingData!.uiBillList[monthKey]
        if datas != nil && indexPath.row < datas!.billList.count {
            cell?.billModel = datas!.billList[datas!.billList.count - 1 - indexPath.row]  //修改 按时间倒叙排列
        }
        let sectionCount = self.billingData!.mouthsSortedArray().count - 1 as Int
        let rowCount = datas!.billList.count - 1 as Int
        
        if ((self.billingData.hasNextPage) && (indexPath.section == sectionCount) && (indexPath.row == rowCount)) {
            self.appendBillingData()
        }
        if let _ = cell!.viewWithTag(10001) as? UILabel {
        } else if indexPath.row < datas!.billList.count {
            let lineBottom = UILabel(frame: CGRectMake(0, 59, screenWidth,1))
            lineBottom.backgroundColor = defaultLineColor
            lineBottom.tag = 10001
            cell!.addSubview(lineBottom)
        }
        return cell!
    }

    //MARK:- Private Method
    private func appendBillingData() {
        self.billingData.pageNumber += 1
        QNNetworkTool.doctorBillList(String(self.billingData.pageNumber), pageSize: "20") { [weak self] (billings, error,errorMsg) -> Void in
            if error == nil && billings != nil{
                self?.billingData.appendBillings(billings!)
                self?.monthBackMoneyLoad()
                self?.tableView.reloadData()
            }
        }
    }
    
    private func monthBackMoneyLoad() {
        if self.billingData != nil{
            QNTool.hiddenActivityView()
            if self.billingData!.uiBillList.count > 0 {
//                for monthMoney in self.monthBackMoney {
//                    let yearMonth = monthMoney["yearMonth"] as! String
//                    let money = monthMoney["money"] as! String
//                    if let billingMonthModel = self.billingData!.uiBillList[yearMonth] {
//                        billingMonthModel.monthBalance = money
//                    }
//                    else {
//                        let billingModels: BillingModels = BillingModels()
//                        billingModels.billMonth = QN_Billings.formatMonth(yearMonth)
//                        billingModels.monthBalance = money
//                        self.billingData!.uiBillList[yearMonth] = billingModels
//                    }
//                }
                QNTool.hiddenEmptyView(self.tableView)
                self.tableView.reloadData()
            }
            else {
                QNTool.showEmptyView("暂无账单记录", inView: self.tableView)
            }
        }
    }
    
    private func fetchData() {
        QNTool.showActivityView(nil, inView: self.view)
        QNNetworkTool.doctorBillList("1", pageSize: "20") { [weak self] (billings, error,errorMsg) -> Void in
            if let strongSelf = self {
                if error == nil && billings != nil, let billingData = QN_Billings(billings!) {
                    strongSelf.billingData = billingData
                    strongSelf.monthBackMoneyLoad()
                }
                else {
                    QNTool.hiddenActivityView()
                    QNTool.showErrorPromptView(billings, error: error)
                }
            }
        }
    }
}
