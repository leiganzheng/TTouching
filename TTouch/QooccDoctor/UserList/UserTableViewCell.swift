//
//  UserTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/6.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class UserTableViewCell: MGSwipeTableCell {

    static let height = CGFloat(72) //
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var vipLevel: UIImageView!
    @IBOutlet weak var startType: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.logo.layer.masksToBounds = true
        self.logo.layer.cornerRadius = self.logo.layer.frame.width/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureButtons(title: String,data: NSArray,index:Int,complete:()->Void){
        //configure right buttons
        self.rightButtons = [MGSwipeButton(title:title , backgroundColor: appThemeColor, callback: { [weak self](obj) -> Bool in
            if let strongSelf = self {
                strongSelf.changeRemark(data, index: index, complete: { () -> Void in
                    complete()
                })
            }
            return true
        })]
//        self.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
    }
    func changeRemark(data:NSArray, index: Int,complete:()->Void) {
        let user = data[index] as! QN_UserInfo
        let alert = UIAlertView(title: "备注", message: "", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles:"确定")
        alert.alertViewStyle = .PlainTextInput
        let tf = alert.textFieldAtIndex(0)
        tf?.text = (user.remark != nil && user.remark!.characters.count > 0) ? user.remark! : ""
        alert.rac_buttonClickedSignal().subscribeNext({(indexNumber) -> Void in
            if indexNumber as! NSInteger == alert.cancelButtonIndex {return}
            let tf = alert.textFieldAtIndex(0)
            if tf?.text != nil {
                if tf?.text == user.remark {return}
                QNNetworkTool.changeRemark(OwnId: user.ownerId, Remark: tf!.text!, completion: { (dictionary, error, errorMessage) -> Void in
                    if dictionary != nil {
                        if let code = dictionary?["errorCode"]?.integerValue where code == 0 {
                            user.remark = tf?.text ?? ""
                            user.starType = 1
                            if self.rightButtons.count > 0 {
                                if let btn = self.rightButtons[0] as? UIButton {
                                    btn.setTitle(tf?.text, forState: UIControlState.Normal)
                                }
                            }
                            complete()
                            QNTool.showPromptView("修改备注成功")
                        }else{
                            QNTool.showErrorPromptView(dictionary, error: error)
                        }
                        
                    }else {
                        QNTool.showPromptView("修改备注失败")
                    }
                })
            }
        })
        alert.show()
    }
}
// MARK: - 增加对 QN_UserInfo 的数据配置
extension UserTableViewCell {
    func config(userInfo: QN_UserInfo) {
        self.logo.sd_setImageWithURL(NSURL(string: userInfo.photo!), placeholderImage: UIImage(named: "header_icon"))
        let nameStr = userInfo.userName
        self.name.text = nameStr
        self.layoutName(nameStr)
        self.time.text = userInfo.lastMeasureDate
        self.content.text = userInfo.signSumary
        self.vipLevel.image = userInfo.vipType.image
        self.startType.hidden = userInfo.starType == 1 ? false : true
        if userInfo.isChecked == 0 {
            if userInfo.abnormalState == 1 {
                self.content.textColor = UIColor(red: 255/255.0, green: 170/255.0, blue: 0/255.0, alpha: 1.0)
            }else if(userInfo.abnormalState == 2){
                self.content.textColor = UIColor(red: 222/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0)
            }
        }else {
            self.content.textColor = UIColor.lightGrayColor()
        }
    }
    private func layoutName(nameStr: String){
        let size = nameStr.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 160)
        self.name.frame = CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y,size.width, self.name.frame.height)
        self.vipLevel.frame = CGRectMake(self.name.frame.origin.x+size.width+5, self.vipLevel.frame.origin.y, self.vipLevel.frame.size.width, self.vipLevel.frame.height)
        self.startType.frame = CGRectMake(self.vipLevel.frame.origin.x+self.vipLevel.frame.width+3, self.startType.frame.origin.y, self.startType.frame.size.width, self.startType.frame.height)
    }
    
}
