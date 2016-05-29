//
//  GoodAtViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/9/8.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import ReactiveCocoa

class GoodAtViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate{
    var tableView: UITableView!
    var qustions: UITextView!
    var countLB: UILabel!
    var deletBtn: UIButton!
    var pickerView: UIPickerView!
    var footView: UIView!
    var scheduleData: NSMutableArray! = NSMutableArray()
    var disArray =  NSMutableArray()
    var disSelect : QN_Disease!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.title = "擅长病症"
        self.view.autoresizesSubviews = true
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.tableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth ,UIViewAutoresizing.FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.scrollEnabled = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)

        // 保存按钮
        let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        saveItem.tintColor = appThemeColor
        saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                self!.view.endEditing(true)
                strongSelf.saveGoodDescribe(strongSelf.qustions.text)
            }
            return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = saveItem
        
        // 取消按钮
        let cancelItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        cancelItem.tintColor = defaultGrayColor
        cancelItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self!.view.endEditing(true)
            self?.navigationController?.popViewControllerAnimated(true)
            return RACSignal.empty()
            })
        self.navigationItem.leftBarButtonItem = cancelItem
        
        // 键盘消失
        let tap = UITapGestureRecognizer(target: self, action: nil)
        tap.delegate = self
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
        //获取病症
        self.scheduleData = QN_Disease.getIllData()
        //获取擅长病症
        if g_doctor?.illList?.count != 0 {
            for var i = 0 ; i < g_doctor?.illList?.count; i++ {
                if let tmpIll = g_doctor!.illList?.objectAtIndex(i) as? NSDictionary {
                    self.fetchData(tmpIll["illName"] as! String)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.disArray.count
        }else {
            return section == 2 ? 2: 1
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return indexPath.row == 0 ? 28 : 90
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
            let cellId = "disCell"
            var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                QNTool.configTableViewCellDefault(cell)
                cell.selectionStyle = .None
        
                let tmpBtn = UIButton(type:.Custom)
                tmpBtn.frame = CGRectMake(tableView.bounds.size.width - 48, 0, 48, 48)
                tmpBtn.backgroundColor = UIColor.clearColor()
                tmpBtn.setImage(UIImage(named: "user_delete"), forState: .Normal)
                tmpBtn.tag = 10001
                cell.contentView.addSubview(tmpBtn)
                
                let line = UIView(frame: CGRectMake(tableView.bounds.size.width - 40, 10, 1, 28))
                line.backgroundColor = defaultLineColor
                cell.contentView.addSubview(line)
                cell.textLabel?.textColor = UIColor.blackColor()
              
            }
            let tmpDis = self.disArray[indexPath.row] as! QN_Disease
            cell.textLabel?.text = tmpDis.name
            (cell.viewWithTag(10001) as! UIButton).rac_command = RACCommand(signalBlock: { [weak self](sender) -> RACSignal! in
                if let strongSelf = self {
                    if strongSelf.view.viewWithTag(10010) != nil {
                       return RACSignal.empty()
                    }
                    strongSelf.disArray.removeObjectAtIndex(indexPath.row)
                    strongSelf.scheduleData.addObject(tmpDis)
                    strongSelf.tableView.reloadData()
                }
                return RACSignal.empty()
                })
            return cell
        } else if indexPath.section == 1 {
            let cellId = "addCell"
            var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                QNTool.configTableViewCellDefault(cell)
                cell.selectionStyle = .None
                
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.textLabel?.text = "新增"
                cell.textLabel?.textColor = appThemeColor
            }
            return cell
        } else {
            let cellId = "addCell"
            var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                QNTool.configTableViewCellDefault(cell)
                cell.selectionStyle = .None

                if indexPath.row != 0 {
                    if self.qustions == nil {
                        self.qustions = UITextView(frame: CGRectMake(10, 0, tableView.bounds.width-20, 70))
                        qustions.backgroundColor = UIColor.clearColor()
                        self.qustions.delegate = self
                        qustions.tag = 2000
                        qustions.font = UIFont.systemFontOfSize(15)
                        qustions.delegate = self
                        qustions.text = g_doctor?.goodDescribe ?? "输入您的自我描述"
                        cell.addSubview(qustions)
                    }
                    if self.countLB == nil {
                        self.countLB = UILabel(frame: CGRectMake(tableView.bounds.width - 70,self.qustions.frame.origin.y+70,60, 15))
                        countLB.backgroundColor = UIColor.clearColor()
                        countLB.textColor = tableViewCellDefaultTextColor
                        countLB.textAlignment = NSTextAlignment.Right
                        countLB.font = UIFont.systemFontOfSize(13)
                        let str = g_doctor?.goodDescribe ?? "输入您的自我描述"
                        let count = 200 - str.characters.count
                        countLB.text = "\(count)"
                        cell.addSubview(countLB)
                    }
                }else {
                    cell.textLabel?.text = "更多描述"
                }
            }
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            self.showPickerView()
        }
    }
    //MARK: -UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        let mulStr = NSMutableString(string: textView.text)
        self.countLB.text = (200 - mulStr.length).description
        self.countLB.textColor = UIColor.grayColor()
        if  200 - mulStr.length < 0 {
            self.countLB.textColor = UIColor.redColor()
        }
    }
    //MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView" {
            return false
        }else {
            return true
        }
    }
    
    //MARK: Private method
    func fetchData(illName : String ) {
        var index : Int = 0
        for tmpDisChild in self.scheduleData {
            if (tmpDisChild as! QN_Disease).name == illName {
                self.disArray.addObject(tmpDisChild)
                self.scheduleData.removeObjectAtIndex(index)
                self.tableView.reloadData()
            }
            index++
        }
    }
    func showPickerView(){
        let tmpData = NSMutableArray()
        for tmpDis in self.scheduleData {
            tmpData.addObject((tmpDis as! QN_Disease).name)
        }
        if tmpData.count == 0 {
            QNTool.showPromptView("已无可选的病症")
            return
        }
        let pickView = CustomPickView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        pickView.dataArray = tmpData
        pickView.showAsPop()
        pickView.finished = { (index) -> Void in
            self.disSelect = self.scheduleData[index] as! QN_Disease
            if index < self.scheduleData.count {
                self.disArray.addObject(self.disSelect)
                self.scheduleData.removeObjectAtIndex(index)
                self.tableView.reloadData()
            }
        }
    }
    func saveGoodDescribe(describe : String) {
        if self.disArray.count == 0 {
            QNTool.showPromptView("请选择病症")
            return
        }
        if  NSString(string:describe).length > 200 {
            QNTool.showPromptView("描述超过200字")
            return
        }
        let disStr : NSMutableString = NSMutableString()
        for tmp in self.disArray {
            disStr.appendString((tmp as! QN_Disease).id)
            disStr.appendString(",")
        }
        QNNetworkTool.saveGoodDescribe(g_doctor!.doctorId, good_describe: describe ?? "", illness_id: disStr as String) { [weak self](dictionary, error, string) -> Void in
            if let strongSelf = self {
                if dictionary?["errorCode"] as? String == "0"  {
                    QNTool.showPromptView("保存成功", nil)
                    g_doctor!.goodDescribe = describe
                    let illnessArray = NSMutableArray()
                    for tmp in strongSelf.disArray {
                        let tmpDic = NSMutableDictionary()
                        tmpDic.setValue((tmp as! QN_Disease).name, forKey: "illName")
                        illnessArray.addObject(tmpDic)
                    }
                    g_doctor?.illList = illnessArray
                    strongSelf.navigationController?.popViewControllerAnimated(true)
                }else {
                    QNTool.showErrorPromptView(nil, error: error, errorMsg: dictionary?["errorMsg"] as? String)
                }
            }
        }
    }
}
