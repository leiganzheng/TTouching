//
//  UserCenterViewController.swift
//  QooccDoctor
//
//  Created by LiuYu on 15/7/9.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

/**
*  @author 
*
*  // MARK: - 用户中心首页
*/
class UserCenterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var titles: NSArray!
    var icons: NSArray!
    var moneyLbl : UILabel!
    @IBOutlet weak var customTableView: UITableView!
    var usrName : UILabel!
    var imgV : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titles = [[""],["我的收入"],["咨询费"],["预约时间"],["预约地点"],["资格认证"],["管理用户"],["设置"]]
        self.icons = [[""],["user_list_income"],["user_list_SetCost"],["user_list_SetTime"],["userCenter_place"],["user_list_ExpertAuthenticate"],["user_list_ManagingUser"],["user_list_setting"]]
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // 配置医生信息
        QNNetworkTool.updateCurrentDoctorInfo { [weak self](succeed) -> Void in
            if succeed, let _ = self {
            }
        }
        self.customTableView.reloadData()
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
        return self.titles.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 112
        }else {
            return 48
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
            let nameTmp  = g_doctor?.doctorName ?? "未备注"
            let size = (nameTmp as String).sizeWithFont(UIFont.systemFontOfSize(16), maxWidth: 120)
            if self.usrName == nil {
                self.usrName = UILabel(frame: CGRectMake(87, 23, size.width + 16, 21))
                usrName.font = UIFont.systemFontOfSize(16)
                usrName.textColor = UIColor.blackColor()
                cell.addSubview(usrName)
            }
            if self.imgV == nil {
                self.imgV = UIImageView(frame: CGRectMake(CGRectGetMaxX(usrName.frame) + 8, 22, 56, 22))
                cell.addSubview(imgV)
            }
            let imageView = cell.viewWithTag(100) as! UIImageView
            let ID = cell.viewWithTag(103) as! UILabel
            let commentDetail = cell.viewWithTag(104) as! UILabel
            let title = g_doctor?.certification == 1 ? "user_authenticate" : "user_unauthenticated"
            imgV.image = UIImage(named: title)
            
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            let headPic = g_doctor!.headPic ?? ""
            imageView.sd_setImageWithURL(NSURL(string: headPic), placeholderImage: UIImage(named: "user_HeadPortrait"))

            usrName.text = nameTmp
            
            let id = g_doctor!.proxyId ?? ""
            ID.text = "ID:" + id
            let belongHospital = g_doctor!.belongHospital ?? ""
            let department_hospital = g_doctor!.department_hospital ?? ""
            let jobTitle = g_doctor!.jobTitle ?? ""
            commentDetail.text = String(format: "%@ %@ %@", belongHospital,department_hospital,jobTitle)
            return cell
        }else {
            let cellId = "cell1"
            var cell: UITableViewCell! = self.customTableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell.accessoryType = .DisclosureIndicator
            }
            let titleArray = self.titles[indexPath.section] as! NSArray
            let iconsArray = self.icons[indexPath.section] as! NSArray
            cell.textLabel?.text = titleArray[indexPath.row] as? String
            cell.imageView?.image = UIImage(named: (iconsArray[indexPath.row] as? String)!)
            if indexPath.section == 1 {
                if self.moneyLbl == nil {
                    self.moneyLbl = UILabel(frame: CGRectMake(screenWidth - 160, 0, 120, 48))
                    self.moneyLbl.font = UIFont.systemFontOfSize(14)
                    self.moneyLbl.textAlignment = NSTextAlignment.Right
                    self.moneyLbl.textColor = UIColor(white: 66/255, alpha: 1)
                }
                cell.addSubview(self.moneyLbl)
                self.fetchDoctorBalanceInfo()
            }
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK: private method
    private func qualificationing(){
        let iphoneAlertView = UIAlertView(title: "等待审核" , message: "认证信息已经上传，请等待审核!", delegate: nil, cancelButtonTitle: "好")
        iphoneAlertView.show()
    }

    private func qualification(){
        
    }
    //获取金额
    private func fetchDoctorBalanceInfo() {
        QNNetworkTool.doctorBalanceInfo({ [weak self](dict, error,errorMsg) -> Void in
            QNTool.hiddenActivityView()
            if let strongSelf = self {
                if dict != nil, let errorCode = dict!["errorCode"]?.integerValue where errorCode == 0{
                    if strongSelf.moneyLbl != nil {
                        strongSelf.moneyLbl.text = dict!["totalMoney"] as? String
                    }
                }
                else {
                    QNTool.showErrorPromptView(dict, error: error, errorMsg: nil)
                }
            }
            })
    }
}
