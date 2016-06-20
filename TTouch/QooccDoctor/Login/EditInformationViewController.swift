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

    @IBOutlet weak var textField1: UITextField!  
    @IBOutlet weak var textField2: UITextField!  
    @IBOutlet weak var textField3: UITextField!  
    @IBOutlet weak var textField4: UITextField!  
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var photoButton: UIButton!
    private(set) var customDate:CustomDatePickerViewController? //日期
    var picker: UIImagePickerController?
    
    var pickerView: UIPickerView!
    var finished : (() -> Void)!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoButton.layer.masksToBounds = true
        self.photoButton.layer.cornerRadius = self.photoButton.frame.size.width/2
        self.view.backgroundColor = defaultBackgroundGrayColor
        let path_sandox = NSHomeDirectory()
        let imagePath = path_sandox.stringByAppendingString("/Documents/profile.png")
        let image = UIImage(contentsOfFile: imagePath)
        self.photoButton.setImage(image, forState: .Normal)
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
    }


    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // 存储图片
        let headImage = self.imageWithImageSimple(image, scaledSize: CGSizeMake(image.size.width, image.size.height))
        let path_sandox = NSHomeDirectory()
        let imagePath = path_sandox.stringByAppendingString("/Documents/profile.png")
        UIImagePNGRepresentation(headImage)?.writeToURL(NSURL(string: imagePath)!, atomically: true)
        self.photoButton.setImage(image, forState: .Normal)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
 //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField  == self.textField4 {
            textField.resignFirstResponder()
            self.customDate = CustomDatePickerViewController()
            self.customDate?.datePickerFinish = { (dateString)->Void in
                if dateString != ""{
                    self.textField4.text = dateString as String
                }
                self.customDate?.view.removeFromSuperview()
            }
            UIApplication.sharedApplication().keyWindow?.addSubview(self.customDate!.view)
        } else if textField  == self.textField5 {
            textField.resignFirstResponder()
            let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
            actionSheet.addButtonWithTitle("男")
            actionSheet.addButtonWithTitle("女")
            actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                if let indexInt = index as? Int {
                    switch indexInt {
                    case 1:
                       self.textField5.text = "男"
                    case 2:
                        self.textField5.text = "女"
                    default: break
                    }
                }
            })
            actionSheet.showInView(self.view)

            
        } else if textField  == self.textField3 {
            
        } else if textField  == self.textField2 {
            
        }

    }
    //MARK: --Private Method
    // 提交用户信息
    @IBAction func done(sender: UIButton!) {
        if self.check() {
            QNTool.showActivityView(nil, inView: self.view)
            
        }
    }
    
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
    
    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
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
   }
