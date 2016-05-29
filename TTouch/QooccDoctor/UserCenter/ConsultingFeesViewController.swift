//
//  ConsultingFeesViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/9/7.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//
//咨询费设置
import UIKit
import ReactiveCocoa

class ConsultingFeesViewController: UIViewController,QNInterceptorProtocol,QNInterceptorKeyboardProtocol, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {
    var tableView: UITableView!
    var phone: UITextField!
    var money: UITextField!
    var vidio: UITextField!
    
    var tips : UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.title = "咨询费设置"
        self.view.autoresizesSubviews = true
       
        let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        saveItem.tintColor = appThemeColor
        saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                if strongSelf.phone.text?.characters.count == 0 || strongSelf.money.text?.characters.count == 0 || strongSelf.vidio.text?.characters.count == 0 {
                    QNTool.showPromptView("请设置金额")
                    return RACSignal.empty()
                } else if (NSString(string: strongSelf.phone.text!).doubleValue >= 1000000) {
                    QNTool.showPromptView("咨询费设置不能超过6位数，请修改！")
                    return RACSignal.empty()
                } else if (NSString(string: strongSelf.money.text!).doubleValue >= 1000000)  {
                    QNTool.showPromptView("咨询费设置不能超过6位数，请修改！")
                    return RACSignal.empty()
                } else if (NSString(string: strongSelf.vidio.text!).doubleValue >= 1000000) {
                    QNTool.showPromptView("咨询费设置不能超过6位数，请修改！")
                    return RACSignal.empty()
                }
                //两位数裁剪
                let check = { (string :String) -> String in
                    let  futureString = NSMutableString(string: string)
                    let arr = NSArray(array: futureString.componentsSeparatedByString("."))//检测小数
                    if arr.count == 2 {
                        let moneyT = arr[1] as! NSString
                        if moneyT.length > 2 {
                            let newMoneyT = moneyT.substringToIndex(2)
                            let new = "\(arr[0]).\(newMoneyT)"
                            return new
                        }
                    } else if arr.count > 2 {
                        QNTool.showPromptView("请正确输入咨询费！")
                        return "-1"
                    }
                    return string
                }
                let phone = check(strongSelf.phone.text!)
                let money = check(strongSelf.money.text!)
                let vidio = check(strongSelf.vidio.text!)
                if phone != "-1" && money != "-1" &&  vidio != "-1"  {
                    let array = [["consultWay":"1","price":phone],["consultWay":"2","price":money],["consultWay":"3","price":vidio]]
                    QNNetworkTool.modifyCosultFee(array, completion: {(dictionary, error, errorMsg) -> Void in
                        if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                            QNTool.showPromptView("设置金额成功！")
                            strongSelf.navigationController?.popViewControllerAnimated(true)
                        }
                        else {
                            QNTool.showPromptView(errorMsg!)
                        }
                        })
                }
                
            }
            return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = saveItem
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.tableView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .OnDrag
        self.view.addSubview(self.tableView)
        // 提交预约
        let footView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 200))
        tips = UITextView(frame: CGRectMake(15, 0, footView.bounds.width-30, 200))
        tips.backgroundColor = UIColor.clearColor()
        tips.textColor = UIColor(white: 150/255, alpha: 1)
        tips.font = UIFont.systemFontOfSize(13)
        tips.editable = false
        tips.text = "注：\n1、收取每次咨询费的平台服务费及个人所得税。 \n2、用户\"确认咨询结束\"，您才会收到款项，请保证服务质量。"
        footView.addSubview(tips)
        self.tableView.tableFooterView = footView
        //
        self.fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01*COEFFICIENT_OF_HEIGHT_ZOOM
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "cell"
            var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell.selectionStyle = .None
                if indexPath.row == 1 {
                    if self.phone == nil {
                        self.phone = UITextField(frame: CGRectMake(15, 0, cell.contentView.bounds.width-30, cell.contentView.bounds.height))
                        phone.backgroundColor = UIColor.clearColor()
                        //                self.phone.delegate = self
                        self.phone.tag = 1000
                        phone.font = UIFont.systemFontOfSize(15)
                        phone.keyboardType = UIKeyboardType.DecimalPad
                        phone.placeholder = "请设置您的单次咨询金额"
                        phone.delegate = self
                        cell.addSubview(phone)
                        
                        let lineLabel = UILabel(frame: CGRectMake(0, 47, tableView.frame.size.width , 1))
                        lineLabel.backgroundColor = defaultLineColor
                        cell?.addSubview(lineLabel)
                    }
                }else{
                    cell.imageView?.image = UIImage(named: "btn_advisory_phone")
                    let lineLabel = UILabel(frame: CGRectMake(0, 47, tableView.frame.size.width , 1))
                    lineLabel.backgroundColor = defaultLineColor
                    cell?.addSubview(lineLabel)
                    let  topLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width , 1))
                    topLabel.backgroundColor = defaultLineColor
                    cell?.addSubview(topLabel)
                    cell.textLabel?.text = "语音咨费（元/次）"
                }
                
            }
            return cell
        } else if indexPath.section == 1 {
            let cellId = "cell"
            var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell.selectionStyle = .None
                if indexPath.row == 1 {
                    if self.money == nil {
                        self.money = UITextField(frame: CGRectMake(15, 0, cell.contentView.bounds.width-30, cell.contentView.bounds.height))
                        money.backgroundColor = UIColor.clearColor()
                        //                self.phone.delegate = self
                        self.money.tag = 1001
                        money.font = UIFont.systemFontOfSize(15)
                        money.keyboardType = UIKeyboardType.DecimalPad
                        money.placeholder = "请设置您的单次咨询金额"
                        money.delegate = self
                        cell.addSubview(money)
                        let lineLabel = UILabel(frame: CGRectMake(0, 47, tableView.frame.size.width , 1))
                        lineLabel.backgroundColor = defaultLineColor
                        cell?.addSubview(lineLabel)
                    }
                }else{
                    cell.imageView?.image = UIImage(named: "btn_advisory_FaceToFace")
                    let lineLabel = UILabel(frame: CGRectMake(0, 47, tableView.frame.size.width , 1))
                    lineLabel.backgroundColor = defaultLineColor
                    cell?.addSubview(lineLabel)
                    let  topLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width , 1))
                    topLabel.backgroundColor = defaultLineColor
                    cell?.addSubview(topLabel)
                    cell.textLabel?.text = "面对面咨费（元/次）"
                }
            }
            return cell
        } else {
            let cellId = "cell"
            var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell.selectionStyle = .None
                if indexPath.row == 1 {
                    if self.vidio == nil {
                        self.vidio = UITextField(frame: CGRectMake(15, 0, cell.contentView.bounds.width-30, cell.contentView.bounds.height))
                        money.backgroundColor = UIColor.clearColor()
                        self.vidio.tag = 1001
                        vidio.font = UIFont.systemFontOfSize(15)
                        vidio.keyboardType = UIKeyboardType.DecimalPad
                        vidio.placeholder = "请设置您的单次咨询金额"
                        vidio.delegate = self
                        cell.addSubview(vidio)
                        let lineLabel = UILabel(frame: CGRectMake(0, 47, tableView.frame.size.width , 1))
                        lineLabel.backgroundColor = defaultLineColor
                        cell?.addSubview(lineLabel)
                    }
                }else{
                    cell.imageView?.image = UIImage(named: "btn_advisory_video")

                    let lineLabel = UILabel(frame: CGRectMake(0, 47, tableView.frame.size.width , 1))
                    lineLabel.backgroundColor = defaultLineColor
                    cell?.addSubview(lineLabel)
                    let  topLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width , 1))
                    topLabel.backgroundColor = defaultLineColor
                    cell?.addSubview(topLabel)
                    cell.textLabel?.text = "视频咨费（元/次）"
                }
            }
            return cell
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let arr = NSArray(array: string.componentsSeparatedByString("."))
        var isN = true
        for str in arr {
            let count = (str as! NSString).length
            isN = (str as! String).checkStingIsNumber(count)
            if !isN {
                return isN
            }
        }
        return true
    }
    //MARK: private method
    func fetchData(){
        QNNetworkTool.cosultFee("1", pageSize: "-1", completion: { [weak self](dictionary, error, errorMsg) -> Void in
            if let storngSelf = self {
                if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                    let array = dictionary!["consult"] as! NSArray
                    if let fee =  dictionary!["fee"] as? String {
                        self!.tips.text = "注：\n1、收取每次咨询费的\(fee)作为平台服务费及个人所得税 \n2、用户\"确认咨询结束\"，您才会收到款项，请保证服务质量。"
                    }
                    for dic in array {
                        if dic["consultWay"] as! String == "1" {
                            storngSelf.phone.text = dic["price"] as? String
                        } else if dic["consultWay"] as! String == "2" {
                            storngSelf.money.text = dic["price"] as? String
                        } else {
                            storngSelf.vidio.text = dic["price"] as? String
                        }
                    }
                }
                else {
                    QNTool.showPromptView(errorMsg!)
                }
            }
        })
    }
}
