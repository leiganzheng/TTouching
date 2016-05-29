//
//  PhotoBroswerViewController.swift
//  QooccHealth
//
//  Created by haijie on 15/12/10.
//  Copyright (c) 2015年 JuXi. All rights reserved.
//

import UIKit
import MWPhotoBrowser
import ReactiveCocoa

class PhotoBroswerViewController: MWPhotoBrowser{
    var deleteImages: ((index:Int) -> Void)? // 删除图片的回掉
    var isDelete: Bool = false//设置是否显示删除按钮
    var photos = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button:UIButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        button.setImage(UIImage(named: "btn_delete1"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(navigationTextColor, forState: UIControlState.Normal)
        button.backgroundColor = UIColor.clearColor()
        button.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                let actionSheet = UIActionSheet(title: "要删除这张图片吗?", delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
                actionSheet.addButtonWithTitle("删除")
                actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                    if index as! Int == 0 {
                        return
                    }
                    if strongSelf.deleteImages != nil {
                        let index = Int(strongSelf.currentIndex)
                        strongSelf.deleteImages!(index: index)
                        strongSelf.photos--
                        strongSelf.reloadData()
                        strongSelf.displayActionButton = false
                    }
                    if strongSelf.photos <= 0 {
                        self!.navigationController?.popViewControllerAnimated(true)
                    }
                })
                actionSheet.showInView(strongSelf.view)
            }
            return RACSignal.empty()
            });
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem?.customView?.hidden = isDelete
        self.configBroswer()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(18)]
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 修改导航栏样式
        self.navigationController?.navigationBar.barTintColor = navigationBackgroundColor
        self.navigationController?.navigationBar.tintColor = navigationBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: navigationTextColor, NSFontAttributeName: UIFont.systemFontOfSize(18)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //MARK:-Private Method 
    func configBroswer() {
        self.displayActionButton = false  //分享按扭
        self.displayNavArrows = false
        self.displaySelectionButtons = false
        self.zoomPhotosToFill = true
        self.alwaysShowControls = false
        self.enableGrid = false
        self.startOnGrid = false
        self.enableSwipeToDismiss = false
    }
}
