
//
//  AppointmentLocationSetViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/24.
//  Copyright (c) 2015年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

// 预约地点设置
class AppointmentLocationSetViewController: UIViewController,QNInterceptorProtocol,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var dataArray = NSMutableArray()
    var pageNo : Int = 1
    var haveNextData = true
    var usedIndex = 0  //常用地址下标
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "预约地点设置"// 保存按钮
        let addItem = UIBarButtonItem(title: "新建", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        addItem.tintColor = appThemeColor
        addItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                let vc = AddAppointmentLocationViewController()
                vc.addFinished = {()->Void in
                    self!.pageNo = 1
                    self!.usedIndex = 0
                    self!.fetchData()
                }
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = addItem
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = defaultBackgroundGrayColor
        
        self.pageNo = 1
        self.fetchData()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
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
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tmp = self.dataArray[indexPath.section] as! NSDictionary
        let address = tmp["address"] as? String
        let size = address?.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: screenWidth - 32)
        return CGFloat(size!.height + 44 + 24)
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "addressCell"
        var cell: AddressTableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId) as? AddressTableViewCell
        if cell == nil {
            cell = AddressTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = .None
        }
        cell.selectionStyle = .None
        let tmp = self.dataArray[indexPath.section] as! NSDictionary
        _ = tmp["id"] as? String
        let address = tmp["address"] as? String
        _ = tmp["commonUsed"] as? String  //常用
        
        cell.addressLbl.text =  address
        let imgN = /*commonUsed == "1"*/ self.usedIndex == indexPath.section ? "userCenter_appointment_addressused" : "userCenter_appointment_unaddressused"
        cell.selectBtn.setImage(UIImage(named: imgN), forState: UIControlState.Normal)
        
        cell.selectBtn.tag = indexPath.section
        cell.selectBtn.addTarget(self, action: Selector("selectBtnCli:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.editBtn.tag = indexPath.section
        cell.editBtn.addTarget(self, action: Selector("editBtnCli:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.deleteBtn.tag = indexPath.section
        cell.deleteBtn.addTarget(self, action: Selector("deleteBtnCli:"), forControlEvents: UIControlEvents.TouchUpInside)

        QNTool.configTableViewCellDefault(cell)
        if indexPath.section == self.dataArray.count - 1 && self.haveNextData {
            self.fetchData()
        }
        return cell
    }
    //MARK: private method
    func fetchData(){
        QNNetworkTool.fetchConsultAddressList("\(self.pageNo)", pageSize: "10") { (array, error, string) -> Void in
            if array != nil {
                if self.pageNo == 1 {
                    self.dataArray.removeAllObjects()
                    if array?.count == 0 {
                        QNTool.showPromptView("未设置预约地点，请新建地点")
                    }
                }
                self.dataArray.addObjectsFromArray(array as! [AnyObject])
                self.tableView.reloadData()
                self.pageNo++
                self.haveNextData =  array?.count == 0 ? false : true
            } else {
                QNTool.showErrorPromptView(nil, error: error, errorMsg: string)
            }
        }
    }
    func editBtnCli(btn : UIButton) {
        let tmp = self.dataArray[btn.tag] as! NSMutableDictionary
        let id = tmp["id"] as? String
        let address = tmp["address"] as? String
        _ = tmp["commonUsed"] as? String  //常用
        let vc = AddAppointmentLocationViewController()
        vc.id = id
        vc.editFinished = {(str)->Void in
            tmp["address"] = str
            self.dataArray.replaceObjectAtIndex(btn.tag, withObject: tmp)
            self.tableView.reloadData()
        }
        vc.place = address
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func deleteBtnCli(btn : UIButton) {
        let tmp = self.dataArray[btn.tag] as! NSDictionary
        let id = tmp["id"] as? String
        _ = tmp["address"] as? String
        _ = tmp["commonUsed"] as? String  //常用
        let alert = UIAlertView(title: "删除地点", message: "确认要删除该地点？", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.rac_buttonClickedSignal().subscribeNext({ (indexNumber) -> Void in
            if (indexNumber as! Int) == 1 {
                //删除
                QNNetworkTool.deleteConsultAddress(id!, completion: { (succeed, error, string) -> Void in
                    if (succeed != nil) && succeed! {
                        QNTool.showPromptView("删除成功")
                        if btn.tag == self.usedIndex {
                            self.pageNo = 1
                            self.fetchData()
                        } else {
                            self.dataArray.removeObjectAtIndex(btn.tag)
                            self.tableView.reloadData()
                        }
                    } else {
                        QNTool.showErrorPromptView(nil, error: error, errorMsg: string)
                    }
                })
            }
        })
        alert.show()
    }
    func selectBtnCli(btn : UIButton) {
        if self.usedIndex == btn.tag {
            return
        }
        let tmp = self.dataArray[btn.tag] as! NSDictionary
        let id = tmp["id"] as? String
        _ = tmp["address"] as? String
        _ = tmp["commonUsed"] as? String  //常用
        QNNetworkTool.setCommonUsed(id!, completion: { (succeed, error, string) -> Void in
            if (succeed != nil) && succeed! {
                QNTool.showPromptView("设置成功")
                self.usedIndex = btn.tag
                self.tableView.reloadData()
            } else {
                QNTool.showErrorPromptView(nil, error: error, errorMsg: string)
            }
        })
    }
}

