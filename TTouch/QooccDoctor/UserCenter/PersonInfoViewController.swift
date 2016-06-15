//
//  PersonInfoViewController.swift
//  QooccHealth
//
//  Created by leiganzheng on 15/8/26.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
//个人信息
class PersonInfoViewController: UIViewController,QNInterceptorProtocol  ,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    private enum Content: Int {
        case HeadImage = 0       // 头像
        case NickName = 1        // 姓名
        case ID = 2         // ID
        case phone = 3         // 注册手机
        case Resume = 4         // 个人简介
        case Zone = 5         // 地区
        case Hospital = 6         // 医院
        case Department = 7         // 科室
        case GoodAt = 8             //擅长
        
        static let count = 9    // 总数
        
        var title: String {
            switch self {
            case .HeadImage: return "头像"
            case .NickName:  return "姓名"
            case .ID:   return "ID"
            case .phone: return "注册手机"
            case .Resume:  return "个人简介"
            case .Zone:   return "地区"
            case .Hospital: return "医院"
            case .Department:  return "科室"
            case .GoodAt: return "擅长"
            }
        }
    }
    private var userCenterData: [[Content]]!
    
    var tableView: UITableView!
    var headerView: UIImageView!
    var picker: UIImagePickerController?
    var user: QN_UserInfo!
    
    var nameLB: UILabel!
    var IdLB: UILabel!
    var phoneLB: UILabel!
    var resumeLB: UILabel!
    var zoneLB: UILabel!
    var hospitalLB: UILabel!
    var departmentLB: UILabel!
    var goodAtLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人信息"
        
        self.userCenterData = [[Content.HeadImage,Content.NickName,Content.ID,Content.phone,Content.Resume], [Content.Zone,Content.Hospital,Content.Department,Content.GoodAt]]
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.tableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.scrollEnabled = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
     
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: UITableViewDataSource & UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.userCenterData[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch self.userCenterData[indexPath.section][indexPath.row] {
        case .HeadImage: return 82
        default: return 50
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellId = "UserInfoViewController_Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell!
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            QNTool.configTableViewCellDefault(cell)
            cell.selectionStyle = .None
        }
        
        let content = self.userCenterData[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = content.title
        switch content {
        case .HeadImage:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if self.headerView == nil {
                self.headerView = UIImageView(frame: CGRectMake(cell.contentView.bounds.size.width - 70, 6, 70, 70))
                self.headerView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
                self.headerView.layer.masksToBounds = true
                self.headerView.layer.cornerRadius = self.headerView.frame.width/2
                self.headerView.sd_setImageWithURL(NSURL(string: g_doctor!.headPic!), placeholderImage: UIImage(named: "user_HeadPortrait"))
            }
            cell.contentView.addSubview(self.headerView)
        case .NickName:
            if self.nameLB == nil {
                self.nameLB = UILabel(frame: CGRectMake(0, 0, 240, 50))
                self.nameLB.font = UIFont.systemFontOfSize(14)
                self.nameLB.textAlignment = NSTextAlignment.Right
                self.nameLB.textColor = UIColor(white: 66/255, alpha: 1)
                cell.accessoryView = self.nameLB
            }
            self.nameLB.text = g_doctor?.doctorName
        case .ID:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if self.IdLB == nil {
                self.IdLB = UILabel(frame: CGRectMake(screenWidth - 175 , 0, 120, 50))
                self.IdLB.font = UIFont.systemFontOfSize(14)
                self.IdLB.textAlignment = NSTextAlignment.Right
                self.IdLB.textColor = UIColor(white: 66/255, alpha: 1)
                
                cell.addSubview(self.IdLB)
                
                let imgV = UIImageView(frame: CGRectMake(screenWidth - 55 , 16, 18, 18))
                imgV.image = UIImage(named: "user_idQR")
                cell.addSubview(imgV)
            }
            self.IdLB.text = g_doctor?.proxyId
        case .phone:
            self.phoneLB = UILabel(frame: CGRectMake(0, 0, 100, 50))
            self.phoneLB.font = UIFont.systemFontOfSize(14)
            self.phoneLB.textAlignment = NSTextAlignment.Right
            self.phoneLB.textColor = UIColor(white: 66/255, alpha: 1)
            cell.accessoryView = self.phoneLB
            self.phoneLB.text = g_doctor?.phone
        case .Resume:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if self.resumeLB == nil {
                self.resumeLB = UILabel(frame: CGRectMake(90, 0, screenWidth - 120, 50))
                self.resumeLB.font = UIFont.systemFontOfSize(14)
                self.resumeLB.textAlignment = NSTextAlignment.Right
                self.resumeLB.textColor = UIColor(white: 66/255, alpha: 1)
                cell.addSubview(self.resumeLB)
            }
            self.resumeLB.text = g_doctor!.introduce
        case .Zone:
            self.zoneLB = UILabel(frame: CGRectMake(0, 0, 240, 50))
            self.zoneLB.font = UIFont.systemFontOfSize(14)
            self.zoneLB.textAlignment = NSTextAlignment.Right
            self.zoneLB.textColor = UIColor(white: 66/255, alpha: 1)
            cell.accessoryView = self.zoneLB
            self.zoneLB.text = g_doctor?.location
        case .Hospital:
            self.hospitalLB = UILabel(frame: CGRectMake(0, 0, 240, 50))
            self.hospitalLB.font = UIFont.systemFontOfSize(14)
            self.hospitalLB.textAlignment = NSTextAlignment.Right
            self.hospitalLB.textColor = UIColor(white: 66/255, alpha: 1)
            cell.accessoryView = self.hospitalLB
            self.hospitalLB.text = g_doctor?.belongHospital
        case .Department:
            self.departmentLB = UILabel(frame: CGRectMake(0, 0, 240, 50))
            self.departmentLB.font = UIFont.systemFontOfSize(14)
            self.departmentLB.textAlignment = NSTextAlignment.Right
            self.departmentLB.textColor = UIColor(white: 66/255, alpha: 1)
            cell.accessoryView = self.departmentLB
            self.departmentLB.text = g_doctor?.department_hospital
        case .GoodAt:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if self.goodAtLB == nil {
                self.goodAtLB = UILabel(frame: CGRectMake(70, 0, screenWidth - 100, 50))
                self.goodAtLB.font = UIFont.systemFontOfSize(14)
                self.goodAtLB.textAlignment = NSTextAlignment.Right
                self.goodAtLB.textColor = UIColor(white: 66/255, alpha: 1)
                cell.addSubview(self.goodAtLB)
            }
            let ills = NSMutableString()
            for var i : Int = 0;i < g_doctor?.illList?.count ;i += 1 {
                let ill  = g_doctor?.illList?.objectAtIndex(i) as! NSDictionary
                ills.appendString(ill["illName"] as! String)
                ills.appendString(" ")
            }
            self.goodAtLB.text = (ills as String) + g_doctor!.goodDescribe!
        }
        
        QNTool.configTableViewCellDefault(cell)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // 存储图片
        let headImage = self.imageWithImageSimple(image, scaledSize: CGSizeMake(image.size.width, image.size.height))
        let headImageData = UIImageJPEGRepresentation(headImage, 0.125)
        self.uploadUserFace(headImageData)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK:-UINavigationControllerDelegate   解决UIImagePickerController没有取消按扭
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let btn = UIButton(frame: CGRectMake(0, 0, 40, 44))
        btn.setTitle("取消", forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(18)
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btn.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { (sender) -> Void in
            viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
        viewController.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: btn), animated: false)
    }
    //MARK:- Private Method
    
    // 上传头像
    private func uploadUserFace(imageData: NSData!) {
        if imageData == nil {
            QNTool.showPromptView("上传图片数据损坏", nil)
            return
        }
        QNTool.showActivityView("正在上传...", inView: self.view, nil)
                QNNetworkTool.uploadDoctorImage(imageData, fileName: g_UDID + ".jpg", type: "doctorFace") { (dictionary, error) -> Void in
                    QNTool.hiddenActivityView()
                    if dictionary != nil, let errorCode = dictionary?["errorCode"] as? String where errorCode == "0" {
                        if let data = dictionary?["data"] as? NSDictionary ,let url = data["url"] as? String{
                            QNNetworkTool.doctorRecolumn("head_pic", columnValue: data["fileName"] as! String) { (dictionry, error, string) -> Void in
                                if dictionry?["errorCode"] as? String == "0"  {
                                    self.headerView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "user_HeadPortrait"))
                                    g_doctor!.headPic = url
                                    QNTool.showPromptView("修改成功", nil)
                                }else {
                                    QNTool.showErrorPromptView(nil, error: error, errorMsg: dictionry?["errorMsg"] as? String)
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }else {
                        QNTool.showPromptView("上传失败,点击重试或者重新选择图片", nil)
                    }
                }
    }
    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
}
