//
//  UserListViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/6.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import ReactiveCocoa

/**
用户排序方式

- DefaultType: 默认综合排序
- VIPType:     vip等级优先
- StartType:   星标用户优先
*/
private enum SortType : Int {
    case DefaultType = 0 // 默认综合排序
    case VIPType = 1   // vip等级优先
    case StartType = 2   // 星标用户优先
}

/**
*  @author leiganzheng, 15-07-06
*
*  //MARK: 用户列表
*/

//用户列表缓存
private let cachePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("UserListDataCache").absoluteString
class UserListViewController: UIViewController, QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    private var dataArray: NSMutableArray!
    private var dataVIPArray: NSMutableArray!
    private var dataStartArray: NSMutableArray!
    
    private var tableViewController: UITableViewController!
    private var leftVC: LeftViewController!
    private var rightVC: RightViewController!
    private var sort: SortType!
    private var pageIndex:NSInteger = 1
    var haveNextData :Bool = true
    private var pageVipIndex:NSInteger = 1
    var haveVipNextData :Bool = true
    private var pageStartIndex:NSInteger = 1
    var haveStartNextData :Bool = true
    var myTableView: UITableView! {
        return self.tableViewController?.tableView
    }
    var datas: NSMutableDictionary = NSMutableDictionary(contentsOfFile: cachePath) ?? NSMutableDictionary() {
        didSet {
            datas.writeToFile(cachePath, atomically: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "监控台"
        self.view.backgroundColor = defaultBackgroundColor
        
        // 让导航栏支持右滑返回功能 Add by LiuYu on 2015-7-20 15:21
        self.navigationController?.navigationBar.translucent = false
        QNTool.addInteractive(self.navigationController)
        
        //数据
        self.dataArray = NSMutableArray()
        self.dataVIPArray = NSMutableArray()
        self.dataStartArray = NSMutableArray()
        //列表创建
        self.tableViewController = UITableViewController(nibName: nil, bundle: nil)
        self.tableViewController.refreshControl = UIRefreshControl()
        self.tableViewController.refreshControl?.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ [weak self](input) -> Void in
            self?.updateData()
        })
        self.myTableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 36)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        
        self.leftVC = LeftViewController.CreateFromStoryboard("Main") as! LeftViewController
        self.leftVC.view.frame = CGRectMake(-screenWidth,0, screenWidth/2,screenHeight)
        self.view.addSubview(self.leftVC.view)
        
        self.rightVC = RightViewController.CreateFromStoryboard("Main") as! RightViewController
        self.rightVC.view.frame = CGRectMake(screenWidth,0, screenWidth/2,screenHeight)
        self.view.addSubview(self.rightVC.view)

        
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) // Added by LiuYu on 2015-7-13 （在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 5, 40, 30))
        searchButton.setImage(UIImage(named: "Main_Search"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            
           self?.animationWith((self?.rightVC)!, x: self?.rightVC.view.frame.origin.x == screenWidth/2 ? screenWidth : screenWidth/2)
            return RACSignal.empty()
        })
        rightBarButton.addSubview(searchButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
        //left
        let leftBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) // Added by LiuYu on 2015-7-13 （在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton1:UIButton = UIButton(frame: CGRectMake(0, 5, 40, 30))
        searchButton1.setImage(UIImage(named: "Main_Search"), forState: UIControlState.Normal)
        searchButton1.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self?.animationWith((self?.leftVC)!, x: self?.leftVC.view.frame.origin.x == 0 ? -screenWidth : 0)
            return RACSignal.empty()
            })
        leftBarButton.addSubview(searchButton1)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)

        //加载数据
        self.sort = .DefaultType//默认排序
        self.updateDatasUI(self.datas)
        self.fectchData()
//        self.configHeadView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        QNPhoneTool.hidden = true
    }
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       return UserTableViewCell.height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var tempArray = []
        switch self.sort.rawValue {
        case 0:
            tempArray = self.dataArray
        case 1:
            tempArray =  self.dataVIPArray
        case 2:
            tempArray = self.dataStartArray
        default:
            assert(self.sort == nil, "未初始化分类")
        }
        return tempArray.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UserTableViewCell!
        if cell == nil {
            cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! UserTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            QNTool.configTableViewCellDefault(cell)
        }
        var tempArray = []
        var next: Bool = true
        switch self.sort.rawValue {
        case 0:
            next = self.haveNextData
           tempArray = self.dataArray
        case 1:
            next = self.haveVipNextData
            tempArray =  self.dataVIPArray
        case 2:
            next = self.haveStartNextData
            tempArray = self.dataStartArray
        default:
            assert(self.sort == nil, "未初始化分类")
        }
        if indexPath.row < tempArray.count {
            let user = tempArray[indexPath.row] as! QN_UserInfo
            cell.config(user)
            cell.configureButtons((user.remark != nil && user.remark!.characters.count > 0) ? user.remark! : "备注", data: tempArray, index: indexPath.row) { () -> Void in
                //刷新当前列表修改行
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                //清空其他列表数据
                switch self.sort.rawValue {
                case 0:
                    self.pageVipIndex = 1
                    self.pageStartIndex = 1
                    self.dataVIPArray.removeAllObjects()
                    self.dataStartArray.removeAllObjects()
                case 1:
                    self.pageIndex = 1
                    self.pageStartIndex = 1
                    self.dataArray.removeAllObjects()
                    self.dataStartArray.removeAllObjects()
                case 2:
                    self.pageVipIndex = 1
                    self.pageIndex = 1
                    self.dataVIPArray.removeAllObjects()
                    self.dataArray.removeAllObjects()
                default:
                    assert(self.sort == nil, "未初始化分类")
                }
                
            }
        }
            // 如果是最后一行，则要去刷新数据
        if indexPath.row ==  tempArray.count - 1 && next{
            self.fectchData()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tempArray = []
        switch self.sort.rawValue {
        case 0:
            tempArray = self.dataArray
        case 1:
            tempArray =  self.dataVIPArray
        case 2:
            tempArray = self.dataStartArray
        default:
            assert(self.sort == nil, "未初始化分类")
        }
        let tempUser = tempArray[indexPath.row] as? QN_UserInfo
        //同步已经查看状态
        if tempUser?.isChecked == 0 {
            tempUser?.isChecked = 1
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.layoutTextColor(tempUser!)
        }
         g_currentUser = tempUser
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
////        let vc = (MedicalAdviceMainViewController.CreateFromStoryboard("Main") as? UIViewController)!
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- private method
    private func layoutTextColor(user:QN_UserInfo){
        var tempArray = []
        switch self.sort.rawValue {
        case 0:
            tempArray = [self.dataVIPArray,self.dataStartArray]
        case 1:
           tempArray = [self.dataStartArray,self.dataArray]
        case 2:
            tempArray = [self.dataVIPArray,self.dataArray]
        default:
            assert(self.sort == nil, "未初始化分类")
        }
        for tempArr in tempArray as NSArray{
            for tempUser in tempArr as! [QN_UserInfo]{
                if tempUser.ownerId == user.ownerId{
                    tempUser.isChecked = 1//已经查看
                    break
                }
            }
        }
    }
    func updateData() {
        self.pageIndex = 1
        self.haveNextData = true
        self.pageStartIndex = 1
        self.haveStartNextData = true
        self.pageVipIndex = 1
        self.haveVipNextData = true
        self.fectchData()
    }
    
    let userListKey = "userList"
    private func updateDatasUI(dictionary: NSDictionary) {
        if let array = dictionary[self.userListKey] as? NSArray {
            let tempArr = NSMutableArray()
            for (_, dict) in array.enumerate() {
                tempArr.addObject(QN_UserInfo(dict as! NSDictionary))
            }
            self.dataArray = tempArr
            self.myTableView.reloadData()
        }
    }
    
    let limit: NSInteger = 10//每页数据条数
    func fectchData(){
        var pageNum: NSInteger = 1
        switch self.sort.rawValue {
        case 0:
            pageNum = self.pageIndex
        case 1:
            pageNum = self.pageVipIndex
        case 2:
            pageNum = self.pageStartIndex
        default:
            assert(self.sort == nil, "未初始化分类")
        }

        QNTool.showActivityView(nil, inView: self.view, nil)
        QNNetworkTool.fetchUserList(DoctorId:g_doctor!.doctorId, Order: NSString(format:"%i",self.sort.rawValue) as String, Start: "\(pageNum)", Limit: "\(limit)") { (dictionary, error, errorMessage) -> Void in
            QNTool.hiddenActivityView()
            if dictionary != nil {
                if let array = dictionary?[self.userListKey] as? NSArray {
                    let tempArr = NSMutableArray()
                    for (_, dict) in array.enumerate() {
                       tempArr.addObject(QN_UserInfo(dict as! NSDictionary))
                    }
                    switch self.sort.rawValue {
                    case 0:
                            if self.pageIndex == 1 {
                                self.datas = NSMutableDictionary(dictionary: dictionary!)
                                self.dataArray.removeAllObjects()
                            }
                            self.dataArray.addObjectsFromArray(tempArr as [AnyObject])
                            if array.count >= self.limit {
                                self.pageIndex++
                            }else {
                                self.haveNextData = false
                            }
                    case 1:
                            if self.pageVipIndex == 1 {
                                self.dataVIPArray.removeAllObjects()
                            }
                            self.dataVIPArray.addObjectsFromArray(tempArr as [AnyObject])
                            if array.count >= self.limit {
                                self.pageVipIndex++
                            }else {
                                self.haveVipNextData = false
                            }
                    case 2:
                            if self.pageStartIndex == 1 {
                                self.dataStartArray.removeAllObjects()
                            }
                            self.dataStartArray.addObjectsFromArray(tempArr as [AnyObject])
                            if array.count >= self.limit {
                                self.pageStartIndex++
                            }else {
                                self.haveStartNextData = false
                            }
                    default:
                          assert(self.sort == nil, "未初始化分类")
                    }
                    self.myTableView.reloadData()
                    // Added by LiuYu on 2015-7-13 (增加无用户的提示)
                    if self.tableView(self.myTableView, numberOfRowsInSection: 0) == 0 {
                        if let isAvaliableString = dictionary?["isAvaliable"] as? String where isAvaliableString == "2" {
                            QNTool.showEmptyView("信息提交成功，请耐心等待审核", inView: self.myTableView)
                        }
                        else {
                             QNTool.showEmptyView("没有可管理的用户，请稍后！", inView: self.myTableView)
                        }
                    }
                    else {
                        QNTool.hiddenEmptyView(self.myTableView)
                    }
                }else{
                    switch self.sort.rawValue {
                    case 0:
                        self.haveNextData = false
                    case 1:
                        self.haveVipNextData = false
                    case 2:
                        self.haveStartNextData = false
                    default:
                        assert(self.sort == nil, "未初始化分类")
                    }

                }
            }else {
                QNTool.showErrorPromptView(dictionary, error: error, errorMsg: errorMessage)
            }
        }
        self.tableViewController.refreshControl?.endRefreshing()
    }
    //changed --by zhenghaijie
    func animationWith(vc: UIViewController,x:CGFloat) {
        UIView .beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        vc.view.frame = CGRectMake(x,0, screenWidth/2,screenHeight)
        UIView.commitAnimations()

    }
}
