//
//  ReserveBalanceViewController.swift
//  QooccHealth
//
//  Created by GuJinyou on 15/4/13.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa
/**
*  @author LiuYu, 15-04-13
*
*  余额
*/
class ReserveBalanceViewController: UIViewController, QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    private enum ReserveBalanceCellType {
        case AllBalance         // 总余额
        case AvailableBalance   // 可用金额
        case LockedBalance      // 锁定金额
        case Transfer           // 转账(提现)
        
        var title : String {
            switch self{
            case AllBalance:
                return "总余额"
            case AvailableBalance:
                return "可用金额"
            case LockedBalance:
                return "锁定金额"
            case Transfer:
                return "转账(提现)"
            }
        }
        
        
        func cellStyle(cell: UITableViewCell!, balance:String!){
            let tagWithLable = 10086
            let balanceLabel :UILabel
            if let balanceLbl = cell.accessoryView as? UILabel{
                balanceLabel = balanceLbl
            }
            else {
                balanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                balanceLabel.tag = tagWithLable
                balanceLabel.textAlignment = NSTextAlignment.Right
                balanceLabel.textColor = UIColor.grayColor()
                cell.accessoryView = balanceLabel
            }
            balanceLabel.text = balance
            switch self{
            case AllBalance,AvailableBalance:
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            case LockedBalance:
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
            case Transfer:
                cell.accessoryView = nil
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
            }
        }
    }
    
    
    var tableView: UITableView!
    private var reserveBalanceData: [[ReserveBalanceCellType]]!
    var balances = ["0","0","0","0","0","300"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reserveBalanceData = [[ReserveBalanceCellType.AllBalance, ReserveBalanceCellType.AvailableBalance, ReserveBalanceCellType.LockedBalance], [ReserveBalanceCellType.Transfer]]
        self.setupUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.reserveBalanceData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reserveBalanceData[section].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewCellDefaultHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ReserveBalanceCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
            QNTool.configTableViewCellDefault(cell!)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            //line
            let lineBottom = UIView(frame: CGRectMake(0, tableViewCellDefaultHeight, screenWidth,1))
            lineBottom.backgroundColor = defaultLineColor
            cell.addSubview(lineBottom)
        }
        if indexPath.row == 0  {
            if let _ = cell.viewWithTag(10002) as? UILabel {
            } else {
                let lineTop = UIView(frame: CGRectMake(0, 0, screenWidth,1))
                lineTop.backgroundColor = defaultLineColor
                cell.addSubview(lineTop)
            }
        }
        let type = self.reserveBalanceData[indexPath.section][indexPath.row]
        let balance = self.balances[indexPath.row]
        
        cell.textLabel?.text = type.title
        
        //
        switch type {
        case .AllBalance, .AvailableBalance, .LockedBalance:
            cell.accessoryType = UITableViewCellAccessoryType.None
            var balanceLabel: UILabel! = cell.accessoryView as? UILabel
            if balanceLabel == nil {
                balanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
                balanceLabel.textColor = UIColor.grayColor()
                balanceLabel.textAlignment = NSTextAlignment.Right
                cell.accessoryView = balanceLabel
            }
            balanceLabel.text = balance
        case .Transfer:
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        //
        cell.selectionStyle = { () -> UITableViewCellSelectionStyle in
            switch type {
            case .AllBalance, .AvailableBalance:
                return .None
            case .LockedBalance:
                return .Default
            case .Transfer:
                return .Default
            }
        }()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let type = self.reserveBalanceData[indexPath.section][indexPath.row]
        switch type {
        case .AllBalance, .AvailableBalance:
            break
        case .LockedBalance: // 锁定金额
            let alertView = UIAlertView(title: "锁定金额", message: "锁定金额是指您有一定的金额正在转账(提现),该金额暂不能使用", delegate: nil, cancelButtonTitle: "好的")
            alertView.show()
        case .Transfer: // 转账
            QNStatistical.statistical(QNStatisticalName.ZZTX)
            if fabs((self.balances[1] as NSString).floatValue) < 1E-6 {
                let alertView = UIAlertView(title: nil, message: "可用余额为零，暂时不能转账", delegate: nil, cancelButtonTitle: "好的")
                alertView.show()
                break
            }
//            let viewController = TransferViewController()
//            viewController.totalBalance = self.balances[0]
//            viewController.enableBalance = self.balances[1]
//            viewController.lockBalance = self.balances[2]
//            viewController.minTransferMoney = self.balances[3]
//            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    //MARK: private method
    private func setupUI() {
        self.title = "我的收入"
        self.view.autoresizesSubviews = true
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.autoresizingMask = [.FlexibleWidth,UIViewAutoresizing.FlexibleHeight]
        self.tableView.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        
        // 账单按钮 Modify by LiuYu on 2015-7-29
        repeat {
            let billingItem = UIBarButtonItem(title: "账单", style: .Done, target: nil, action: nil)
            billingItem.tintColor = appThemeColor
            billingItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                if let strongSelf = self {
                    let viewController = BillingViewController()
                    strongSelf.navigationController?.pushViewController(viewController, animated: true)
                }
                return RACSignal.empty()
                });
            self.navigationItem.rightBarButtonItem = billingItem
        } while (false)
    }
    
    private func fetchData() {
        QNTool.showActivityView(nil, inView: self.view)
        QNNetworkTool.doctorBalanceInfo({ [weak self](dict, error,errorMsg) -> Void in
            QNTool.hiddenActivityView()
            if let strongSelf = self {
                if dict != nil, let errorCode = dict!["errorCode"]?.integerValue where errorCode == 0{
                    strongSelf.balances = [dict!["totalMoney"] as! String,dict!["availableMoney"]as! String,dict!["lockMoney"]as! String,dict!["minTransferMoney"]as! String]
                    strongSelf.tableView.reloadData()
                }
                else {
                    QNTool.showErrorPromptView(dict, error: error, errorMsg: nil)
                }
            }
            })
    }

    
}
