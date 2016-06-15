//
//  EditInformationViewController.swift
//  QooccDoctor
//
//  Created by LiuYu on 15/7/7.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

/* 对 area 里的数据做一个说明
    1. 省市区，都有1个 "id" 和 "name"
    2. 文件打开后做Json解析后第1层是省的数据数组
    3. 某省的数据：{"id" : id, "name" : name, "citys" : []/*某省内的市的数据数组*/}
    4. 某市的数据：{"id" : id, "name" : name, "areas" : []/*某市内的区的数据数组*/}
    5. 某区的数据：{"id" : id, "name" : name}
 */

/**
*  @author LiuYu, 15-07-07
*
*  // MARK: - 注册的下一步，填写资料
*/
class EditInformationViewController: UIViewController, QNInterceptorNavigationBarShowProtocol, QNInterceptorKeyboardProtocol, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

//    @IBOutlet weak var textField1: UITextField!  //地区
    @IBOutlet weak var textField2: UITextField!  //所属医院
    @IBOutlet weak var textField3: UITextField!  //科室
    @IBOutlet weak var textField4: UITextField!  //职称
    @IBOutlet weak var textField5: UITextField!  //擅长病症
    
    var picker: UIImagePickerController?
    
    var isEdit = true
    var pickerView: UIPickerView!
    var jobPickerView: UIPickerView!  //职称列表
    var departmentPickerView: UIPickerView!    //科室
    var illnessPickerView: UIPickerView!       //病症
    var area: NSArray!
    let jobDataArray : NSArray = ["助理医师","医师","主治医师","主任医师","副主任医师"]
    var departmentDataArray : NSMutableArray! = NSMutableArray()
    var illnessDataArray : NSMutableArray! = NSMutableArray()

    var province_id: String?    // 省 Id
    var city_id: String?        // 市 Id
    var ill_id: String?       //病症 Id
    var dep_id: String?       //科室 Id
    var hospital_id : String?   //医院 id
    var finished : (() -> Void)!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 初始化省市区
        if let areaFilePath = NSBundle.mainBundle().pathForResource("area", ofType: "txt"), let areaData = NSData(contentsOfFile: areaFilePath) {
           
            do {
                self.area = try NSJSONSerialization.JSONObjectWithData(areaData, options: NSJSONReadingOptions()) as? NSArray
            }catch {
                
            }
            
        }
        assert(self.area != nil, "省市区数据为空，area.txt文件出错啦")
        self.departmentDataArray = QN_Department.getDepartmentData()  //获取科室
        self.illnessDataArray = QN_Disease.getIllData()  //获取病症

        
        NSNotificationCenter.defaultCenter().rac_addObserverForName(UIKeyboardWillShowNotification, object: nil).subscribeNext { (sender) -> Void in
            self.view.endEditing(true)
        }
        self.view.backgroundColor = defaultBackgroundGrayColor
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    // 省市区
    @IBAction func showAreaSelectView(sender: AnyObject!) {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
        self.view.addSubview(pickerView)
    }
    
    // 提交用户信息
    @IBAction func done(sender: UIButton!) {
        if self.check() {
            QNTool.showActivityView(nil, inView: self.view)
           
        }
    }
    
    //MARK: --Private Method
    // 判断输入的合法性
    private func check() -> Bool {
        
        if !QNTool.stringCheck(self.textField2.text) {
            QNTool.showPromptView("请选择所在医院！")
            self.textField2.text = nil;
            return false
        }
        
        if !QNTool.stringCheck(self.textField3.text) {
            QNTool.showPromptView("请选择所在科室！")
            self.textField3.text = nil;
            return false
        }
        if !QNTool.stringCheck(self.textField4.text) {
            QNTool.showPromptView("请选择职称！")
            return false
        }
        if !QNTool.stringCheck(self.textField5.text) {
            QNTool.showPromptView("请选择擅长疾病！")
            return false
        }

        return true
    }
    
    func getRightBtn(textFiled : UITextField) -> UIButton {
        let selectButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: textFiled.bounds.height*COEFFICIENT_OF_HEIGHT_ZOOM))
        selectButton.layer.borderWidth = 0.5
        selectButton.layer.borderColor = defaultLineColor.CGColor
        selectButton.backgroundColor = UIColor.whiteColor()
        selectButton.setImage(UIImage(named: "Regsiter_RightArrow"), forState: .Normal)
        selectButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { (sender) -> Void in
            self.selectBtnCli(textFiled)
        }
        return selectButton
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        // 存储图片
//        let headImage = self.imageWithImageSimple(image, scaledSize: CGSizeMake(image.size.width, image.size.height))
//        let headImageData = UIImageJPEGRepresentation(headImage, 0.125)
//        self.uploadUserFace(headImageData)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    func configTextFieldCli(textFiled : UITextField) {
        let selectBtnCli = UIButton(frame: CGRectMake(textFiled.bounds.origin.x, textFiled.bounds.origin.y, screenWidth -  textFiled.bounds.origin.x * 2 + 30, textFiled.bounds.height))
        selectBtnCli.backgroundColor = UIColor.clearColor()
        textFiled.addSubview(selectBtnCli)
        selectBtnCli.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { (sender) -> Void in
            self.selectBtnCli(textFiled)
        }
        //不弹出键盘
        
        textFiled.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { (sender) -> Void in
            sender.resignFirstResponder()
        }
    }

    @IBAction func photoAction(sender: AnyObject) {
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
                    self.picker!.allowsEditing = true
                    self.presentViewController(self.picker!, animated: true, completion: nil)
                default: break
                }
            }
        })
        actionSheet.showInView(self.view)
    }
    func selectBtnCli(textFiled : UITextField) {
        if textFiled  == self.textField4 {
//            //职称
//            let vc = EditInfoSelectLeveOneViewController()
//            vc.type = 1
//            vc.finished = { (str,id) -> Void in
//                self.textField4.text = str
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
        } else if textFiled  == self.textField5 {
//            //擅长病症
//            let vc = EditInfoSelectLeveOneViewController()
//            vc.type = 2
//            vc.finished = { (name,id) -> Void in
//                self.textField5.text = name
//                self.ill_id = id
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
        } else if textFiled  == self.textField3 {
            //科室
//            let vc = EditInfoEpartmentSelectViewController()
//            vc.hospital = self.textField2.text!
//            vc.finished = { (id,name) -> Void in
//                self.textField3.text = name
//                self.dep_id = id
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
        } else if textFiled  == self.textField2 {
            //地区 医院
//            let vc = EditInfoAreaSelectViewController()
//            vc.finished = { (province_id,city_id,name,id) -> Void in
//                self.textField2.text = name
//                self.province_id = province_id
//                self.city_id = city_id
//                self.hospital_id = id
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
