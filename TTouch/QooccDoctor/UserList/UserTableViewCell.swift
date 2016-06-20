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

    static let height = CGFloat(46) //
    
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
    
}
//// MARK: - 增加对 QN_UserInfo 的数据配置
//extension UserTableViewCell {
//    func config(userInfo: QN_UserInfo) {
//        self.logo.sd_setImageWithURL(NSURL(string: userInfo.photo!), placeholderImage: UIImage(named: "header_icon"))
//        let nameStr = userInfo.userName
//        self.name.text = nameStr
//        self.layoutName(nameStr)
//        self.time.text = userInfo.lastMeasureDate
//        self.content.text = userInfo.signSumary
////        self.vipLevel.image = userInfo.vipType.image
//        self.startType.hidden = userInfo.starType == 1 ? false : true
//        if userInfo.isChecked == 0 {
//            if userInfo.abnormalState == 1 {
//                self.content.textColor = UIColor(red: 255/255.0, green: 170/255.0, blue: 0/255.0, alpha: 1.0)
//            }else if(userInfo.abnormalState == 2){
//                self.content.textColor = UIColor(red: 222/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0)
//            }
//        }else {
//            self.content.textColor = UIColor.lightGrayColor()
//        }
//    }
//    private func layoutName(nameStr: String){
//        let size = nameStr.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 160)
//        self.name.frame = CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y,size.width, self.name.frame.height)
//        self.vipLevel.frame = CGRectMake(self.name.frame.origin.x+size.width+5, self.vipLevel.frame.origin.y, self.vipLevel.frame.size.width, self.vipLevel.frame.height)
//        self.startType.frame = CGRectMake(self.vipLevel.frame.origin.x+self.vipLevel.frame.width+3, self.startType.frame.origin.y, self.startType.frame.size.width, self.startType.frame.height)
//    }
//    
//}
