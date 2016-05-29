
//
//  QualificationViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/9/8.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import ReactiveCocoa
import OpenUDID
/**
订单进度

- NewType: 新订单
- HandleType:     进行中
- FinishType:   已完成
*/
private enum CertificationType : Int {
    case WorkType = 0 // 工作证
    case IDType = 1   // 身份证
    case ProfileType = 2   // 头像
}

//// 资格认证
class QualificationViewController: UIViewController,QNInterceptorProtocol , UITableViewDataSource, UITableViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var tableView: UITableView!
    
    private var CerType: CertificationType!
    
    var caseImage: UIButton!
    var caseLbl : UILabel!
    var idcardImage: UIButton!
    var idcardLbl : UILabel!
    var profileImage: UIButton!
    var profileLbl : UILabel!
    var picker: UIImagePickerController?
    
    var idcardImageExample: UIButton!
    var profileImageExample: UIButton!
    var caseImageExample: UIButton!
    
    var work_card : String!
    var identity : String!
    var head_pic : String!
    var work_cardUrl : String!
    var identityUrl : String!
    var head_picUrl : String!
    var photos : NSMutableArray = NSMutableArray()
    var actionSheet : UIActionSheet!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.title = "资格认证"
        self.view.autoresizesSubviews = true
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.tableView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.scrollEnabled = true
        self.tableView.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        
        // 保存按钮   //认证状态(0:未认证;1:已认证；2：认证中)
        if g_doctor?.certification != 1 {
            let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
            saveItem.tintColor = appThemeColor
            saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                if let strongSelf = self {
                    strongSelf.saveCredential()
                }
                return RACSignal.empty()
                })
            self.navigationItem.rightBarButtonItem = saveItem
        }
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
        return indexPath.row == 0 ? 40 : 134
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        return 10.0*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 50))
            footerView.backgroundColor = defaultBackgroundGrayColor
            let footerLabel = UILabel(frame: CGRect(x: 16, y: 10, width: 200, height: 30))
            footerLabel.center = footerView.center
            footerLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleHeight]
            footerLabel.font = UIFont.systemFontOfSize(12)
            footerLabel.textAlignment = NSTextAlignment.Center
            footerLabel.textColor = UIColor.grayColor()
            footerLabel.backgroundColor = UIColor.clearColor()
            footerView.addSubview(footerLabel)
            if g_doctor?.isAvaliable == 1 {
                footerLabel.text = "审核通过,已认证"
            }else{
                footerLabel.text = "上传认证信息后，可加快审核！"
            }
           
            return footerView
        }
        return nil
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = .None
        }
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel!.text = "工作证认证"
                cell.imageView?.image = UIImage(named:"user_ExpertAuthenticate_WorkPermit")
                
                let lineLabel = UILabel(frame: CGRectMake(0, 39, tableView.frame.size.width , 1))
                lineLabel.backgroundColor = defaultLineColor
                cell.addSubview(lineLabel)
                
                let topLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width , 1))
                topLabel.backgroundColor = defaultLineColor
                cell.addSubview(topLabel)
            }else {
                let lineLabel = UILabel(frame: CGRectMake(0, 133, tableView.frame.size.width , 1))
                lineLabel.backgroundColor = defaultLineColor
                cell.addSubview(lineLabel)
                if self.caseImageExample == nil {
                    self.caseImageExample = UIButton(type: .Custom)
                    caseImageExample.backgroundColor = UIColor.clearColor()
                    caseImageExample.frame =  CGRectMake(45, 22, 90 , 90)
                    caseImageExample.titleEdgeInsets = UIEdgeInsetsMake(80, -90, 0, 0)
                    caseImageExample.imageEdgeInsets = UIEdgeInsetsMake(-32, 0, 0, 0)
                    caseImageExample.setTitle("示例", forState: .Normal)
                    caseImageExample.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    caseImageExample.titleLabel?.font = UIFont.systemFontOfSize(14)
                    caseImageExample.setImage(UIImage(named: "user_ExpertAuthenticate_example1"), forState: .Normal)
                    cell.contentView.addSubview(caseImageExample)
                }
                if self.caseImage == nil {
                    self.caseLbl = UILabel(frame: CGRectMake(tableView.bounds.width - 130, 98, 90, 14))
                    self.caseLbl.textColor = UIColor.lightGrayColor()
                    self.caseLbl.textAlignment = NSTextAlignment.Center
                    self.caseLbl.font = UIFont.systemFontOfSize(14)
                    cell.addSubview(self.caseLbl)
                    self.caseImage = UIButton(type: .Custom)
                    caseImage.backgroundColor = UIColor.clearColor()
                    caseImage.frame =  CGRectMake(tableView.bounds.width - 130, 6, 90 , 90)
                    caseImage.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    if g_doctor?.workCard != nil  && g_doctor?.workCard != "" {
                        self.work_cardUrl = g_doctor?.workCard
                        if self.work_cardUrl.characters.count > 36 {
                            self.work_card = (self.work_cardUrl as NSString).substringFromIndex(36)
                        }
                        self.caseLbl.text = "我的工作证"
                        caseImage.sd_setImageWithURL(NSURL(string: self.work_cardUrl), forState: .Normal, placeholderImage: UIImage(named: "user_ExpertAuthenticate_Photo"))
                    } else {
                        caseImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                        self.caseLbl.text = "上传工作证"
                    }
                    
                    if g_doctor?.certification != 1 {
                        caseImage.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                            if let strongSelf = self {
                                if strongSelf.work_card != nil  {
                                    let vc = ImageSingleZoomViewController()
                                    vc.imageUrl = strongSelf.work_cardUrl
                                    vc.deleteImages = { () -> Void in
                                        strongSelf.work_card = nil
                                        strongSelf.caseImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                                        strongSelf.caseLbl.text = "上传工作证"
                                    }
                                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                                }else {
                                    strongSelf.CerType = CertificationType.WorkType
                                    let actionSheet = strongSelf.getActionSheet()
                                    actionSheet.showInView(strongSelf.view)
                                }
                            }
                        }
                    }  else {
                        caseImage.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                            if let strongSelf = self {
                                if strongSelf.work_card != nil  {
                                    let vc = ImageSingleZoomViewController()
                                    vc.imageUrl = strongSelf.work_cardUrl
                                    vc.isDelete = true
                                    vc.deleteImages = { () -> Void in
                                        strongSelf.work_card = nil
                                        strongSelf.caseImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                                        strongSelf.caseLbl.text = "上传工作证"
                                    }
                                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                    cell.contentView.addSubview(caseImage)
                }
            }
        case 1:
            if indexPath.row == 0 {
                cell.textLabel!.text = "身份证认证"
                cell.imageView?.image = UIImage(named: "user_ExpertAuthenticate_IDcard")
                let lineLabel = UILabel(frame: CGRectMake(0, 39, tableView.frame.size.width , 1))
                lineLabel.backgroundColor = defaultLineColor
                cell.addSubview(lineLabel)
                let topLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width , 1))
                topLabel.backgroundColor = defaultLineColor
                cell.addSubview(topLabel)
            }else {
                let lineLabel = UILabel(frame: CGRectMake(0, 133, tableView.frame.size.width , 1))
                lineLabel.backgroundColor = defaultLineColor
                cell.addSubview(lineLabel)
                if self.idcardImageExample == nil {
                    self.idcardImageExample = UIButton(type: .Custom)
                    idcardImageExample.backgroundColor = UIColor.clearColor()
                    idcardImageExample.frame =  CGRectMake(45, 22, 90 , 90)
                    idcardImageExample.titleEdgeInsets = UIEdgeInsetsMake(80, -90, 0, 0)
                    idcardImageExample.imageEdgeInsets = UIEdgeInsetsMake(-32, 0, 0, 0)
                    idcardImageExample.setTitle("示例", forState: .Normal)
                    idcardImageExample.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    idcardImageExample.titleLabel?.font = UIFont.systemFontOfSize(14)
                    idcardImageExample.setImage(UIImage(named: "user_ExpertAuthenticate_example2"), forState: .Normal)
                    cell.contentView.addSubview(idcardImageExample)
                }
                if self.idcardImage == nil {
                    self.idcardLbl = UILabel(frame: CGRectMake(tableView.bounds.width - 130, 98, 90, 14))
                    self.idcardLbl.textColor = UIColor.lightGrayColor()
                      self.idcardLbl.textAlignment = NSTextAlignment.Center
                    self.idcardLbl.font = UIFont.systemFontOfSize(14)
                    cell.addSubview(self.idcardLbl)
                    self.idcardImage = UIButton(type: .Custom)
                    idcardImage.backgroundColor = UIColor.clearColor()
                    idcardImage.frame =  CGRectMake(tableView.bounds.width - 130, 6, 90 , 90)
                    if g_doctor?.identity != nil && g_doctor?.identity != ""{
                        self.identityUrl = g_doctor?.identity
                        if self.identityUrl.characters.count > 36 {
                            self.identity = (self.identityUrl as NSString).substringFromIndex(36)
                        }
                        idcardImage.sd_setImageWithURL(NSURL(string: self.identityUrl), forState: .Normal, placeholderImage: UIImage(named: ""))
                        idcardLbl.text = "我的身份证"
                    }else {
                        idcardImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                        idcardLbl.text = "上传身份证"
                    }
                    idcardImage.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    
                    if g_doctor?.certification != 1 {
                        idcardImage.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                            if let strongSelf = self {
                                if strongSelf.identity != nil  {
                                    let vc = ImageSingleZoomViewController()
                                    vc.imageUrl = strongSelf.identityUrl
                                    vc.deleteImages = { (array) -> Void in
                                        strongSelf.identity = nil
                                        strongSelf.idcardImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                                        strongSelf.idcardLbl.text = "上传身份证"
                                    }
                                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                                }else {
                                    strongSelf.CerType = CertificationType.IDType
                                    let actionSheet = strongSelf.getActionSheet()
                                    actionSheet.showInView(strongSelf.view)
                                }
                            }
                            
                        }
                    } else {
                        idcardImage.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                            if let strongSelf = self {
                                if strongSelf.identity != nil  {
                                    let vc = ImageSingleZoomViewController()
                                    vc.imageUrl = strongSelf.identityUrl
                                    vc.isDelete = true
                                    vc.deleteImages = { (array) -> Void in
                                        strongSelf.identity = nil
                                        strongSelf.idcardImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                                        strongSelf.idcardLbl.text = "上传身份证"
                                    }
                                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }

                    }
                        cell.contentView.addSubview(idcardImage)
                }

            }
        case 2:
            if indexPath.row == 0 {
                cell.textLabel!.text = "头像认证"
                cell.imageView?.image = UIImage(named: "user_ExpertAuthenticate_HeadPortrait")
                let lineLabel = UILabel(frame: CGRectMake(0, 39, tableView.frame.size.width , 1))
                lineLabel.backgroundColor = defaultLineColor
                cell.addSubview(lineLabel)
                let topLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width , 1))
                topLabel.backgroundColor = defaultLineColor
                cell.addSubview(topLabel)
            }else {
                let lineLabel = UILabel(frame: CGRectMake(0, 133, tableView.frame.size.width , 1))
                lineLabel.backgroundColor = defaultLineColor
                cell.addSubview(lineLabel)
                if self.profileImageExample == nil {
                    self.profileImageExample = UIButton(type: .Custom)
                    profileImageExample.backgroundColor = UIColor.clearColor()
                    profileImageExample.frame =  CGRectMake(45, 22, 90 , 90)
                    profileImageExample.titleEdgeInsets = UIEdgeInsetsMake(80, -90, 0, 0)
                    profileImageExample.imageEdgeInsets = UIEdgeInsetsMake(-32, 0, 0, 0)
                    profileImageExample.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    profileImageExample.titleLabel?.font = UIFont.systemFontOfSize(14)
                    profileImageExample.setTitle("示例", forState: .Normal)
                    profileImageExample.setImage(UIImage(named: "user_ExpertAuthenticate_example3"), forState: .Normal)
                    cell.contentView.addSubview(profileImageExample)
                }

                if self.profileImage == nil {
                    self.profileLbl = UILabel(frame: CGRectMake(tableView.bounds.width - 130, 98, 90, 14))
                    self.profileLbl.textColor = UIColor.lightGrayColor()
                    self.profileLbl.font = UIFont.systemFontOfSize(14)
                    self.profileLbl.textAlignment = NSTextAlignment.Center
                    cell.addSubview(self.profileLbl)

                    self.profileImage = UIButton(type:.Custom)
                    profileImage.backgroundColor = UIColor.clearColor()
                    profileImage.frame =  CGRectMake(tableView.bounds.width - 130, 6, 90 , 90)
                    if g_doctor?.headPic != nil && g_doctor?.headPic != ""{
                        self.head_picUrl = g_doctor?.headPic
                        profileImage.sd_setImageWithURL(NSURL(string: self.head_picUrl), forState: .Normal, placeholderImage: UIImage(named: ""))
                        if self.head_picUrl.characters.count > 36 {
                            self.head_pic = (self.head_picUrl as NSString).substringFromIndex(36)
                        }
                        self.profileLbl.text = "我的头像"
                    } else {
                        profileImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                        self.profileLbl.text = "上传头像"
                    }
                    if g_doctor?.certification != 1 {
                        profileImage.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                            if let strongSelf = self {
                                if strongSelf.head_pic != nil {
                                    let vc = ImageSingleZoomViewController()
                                    vc.imageUrl = strongSelf.head_picUrl
                                    vc.deleteImages = { (array) -> Void in
                                        strongSelf.head_pic = nil
                                        strongSelf.profileImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                                        strongSelf.profileLbl.text = "上传头像"
                                    }
                                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                                }else {
                                    strongSelf.CerType = CertificationType.ProfileType
                                    let actionSheet = strongSelf.getActionSheet()
                                    actionSheet.showInView(strongSelf.view)
                                }
                            }
                        }
                    } else {
                        profileImage.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                            if let strongSelf = self {
                                if strongSelf.head_pic != nil {
                                    let vc = ImageSingleZoomViewController()
                                    vc.imageUrl = strongSelf.head_picUrl
                                    vc.isDelete = true
                                    vc.deleteImages = { (array) -> Void in
                                        strongSelf.head_pic = nil
                                        strongSelf.profileImage.setImage(UIImage(named: "user_ExpertAuthenticate_addPhoto1"), forState: .Normal)
                                        strongSelf.profileLbl.text = "上传头像"
                                    }
                                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                    cell.contentView.addSubview(profileImage)
                }
                
            }
        default:
            assert(false, "")
        }
        QNTool.configTableViewCellDefault(cell)
        return cell
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // 存储图片
        let headImage = self.imageWithImageSimple(image, scaledSize: CGSizeMake(image.size.width, image.size.height))
        let headImageData = UIImageJPEGRepresentation(headImage, 0.125)
        self.uploadImg(headImageData)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }

    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    // 上传头像
    private func uploadImg(imageData: NSData!) {
        let type = self.CerType == CertificationType.ProfileType ? "doctorFace" :"doctorImg"
        if imageData == nil {
            QNTool.showPromptView("上传图片数据损坏", nil)
            return
        }
        QNTool.showActivityView("正在上传...", inView: self.view, nil)
        var tmpUUid = OpenUDID.value() as NSString
        if tmpUUid.length > 32 {
            tmpUUid = tmpUUid.substringToIndex(32)
        }
    
        QNNetworkTool.uploadDoctorImage(imageData, fileName: (tmpUUid as String) + ".jpg", type: type) { (dictionary, error) -> Void in
            QNTool.hiddenActivityView()
            if dictionary != nil, let errorCode = dictionary?["errorCode"] as? String where errorCode == "0" {
                let data = dictionary?["data"] as? NSDictionary
                let fileName = data?.valueForKey("fileName") as? String
                let url = data?.valueForKey("url") as? String
                if self.CerType == CertificationType.WorkType{
                    self.caseLbl.text = "我的工作证"
                    self.work_card = fileName
                    self.work_cardUrl = url
                    self.caseImage.sd_setImageWithURL(NSURL(string: url!), forState: .Normal, placeholderImage: UIImage(named: ""))
                }else if(self.CerType == CertificationType.IDType){
                    self.idcardLbl.text = "我的身份证"
                    self.identity = fileName
                    self.identityUrl = url
                    self.idcardImage.sd_setImageWithURL(NSURL(string: url!), forState: .Normal, placeholderImage: UIImage(named: ""))
                }else{
                    self.profileLbl.text  = "我的头像"
                    self.head_pic = fileName
                    self.head_picUrl = url
                    self.profileImage.sd_setImageWithURL(NSURL(string: url!), forState: .Normal, placeholderImage: UIImage(named: ""))
                }
                QNTool.showPromptView("上传成功", nil)
                self.tableView.reloadData()
            }else {
                QNTool.showPromptView("上传失败,点击重试或者重新选择图片", nil)
            }
        }
    }
    //保存医生资格认证信息
    func saveCredential() {
        if self.checkData() {
            return
        }
        
        QNNetworkTool.saveCredential(g_doctor!.doctorId!, work_card: self.work_card, identity: self.identity, head_pic: self.head_pic) { (succeed, error, string) -> Void in
            if succeed! {
                QNTool.showPromptView("保存成功", nil)
                g_doctor!.certification! = 2
                g_doctor?.workCard = self.work_cardUrl
                g_doctor?.identity = self.identityUrl
                g_doctor?.headPic = self.head_picUrl
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                QNTool.showErrorPromptView(nil, error: error, errorMsg: string)
            }
        }
    }
    func checkData() -> Bool{
        if self.work_card == nil  {
           QNTool.showPromptView("请上传工作证", nil)
            return true
        } else if self.identity == nil {
            QNTool.showPromptView("请上传身份证", nil)
            return true
        } else if self.head_pic == nil  {
            QNTool.showPromptView("请上传头像", nil)
            return true
        } else {
            if (self.work_card as NSString).length > 36 {
                let range01 = NSMakeRange((self.work_card as NSString).length - 36, 36)
                self.work_card = (self.work_card as NSString).substringWithRange(range01)
            }
            if (self.identity as NSString).length > 36 {
                let range02 = NSMakeRange((self.identity as NSString).length - 36, 36)
                self.identity = (self.identity as NSString).substringWithRange(range02)
            }
            if (self.head_pic as NSString).length > 36 {
                let range03 = NSMakeRange((self.head_pic as NSString).length - 36, 36)
                self.head_pic = (self.head_pic as NSString).substringWithRange(range03)
            }
            return false
        }
    }
    func getActionSheet() -> UIActionSheet{
        if self.actionSheet == nil {
            let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
            actionSheet.addButtonWithTitle("从手机相册选择")
            actionSheet.addButtonWithTitle("拍照")
            actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                if let indexInt = index as? Int {
                    switch indexInt {
                    case 1, 2:
                        if self.picker == nil {
                            self.picker = UIImagePickerController()
                            self.picker!.delegate = self
                        }
                        self.picker!.sourceType = (indexInt == 1) ? .SavedPhotosAlbum : .Camera
                        self.picker!.allowsEditing = false
                        self.presentViewController(self.picker!, animated: true, completion: nil)
                    default: break
                    }
                }
            })
            self.actionSheet = actionSheet
        }
        return self.actionSheet
    }
}
