//
//  EditInfoEpartmentSelectViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/17.
//  Copyright (c) 2015年 juxi. All rights reserved.
//
// MARK: - 填写资料  科室
import UIKit

class EditInfoEpartmentSelectViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    var departmentDataArray : NSMutableArray! = NSMutableArray()
    var leftTableView : UITableView!
    var rightTableView : UITableView!
    var headTitle : UILabel!

    var  rightArrays : NSMutableArray = NSMutableArray()
    var finished :((String,String) -> Void)!
    var leftSelectColor = UIColor(red: 228/255, green: 243/255, blue: 255/255, alpha: 1.0)
    var hospital = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.departmentDataArray = QN_Department.getDepartmentData()  //获取科室
        if SYSTEM_VERSION_FLOAT >= 8.0 {
            self.view.layoutMargins = UIEdgeInsetsZero
        }
        self.subViewInit()
        self.tableViewInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.leftTableView ? self.departmentDataArray.count : self.rightArrays.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView == self.leftTableView ? 55 : 60
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView  == leftTableView) {
            let cellIdentifier = "leftcell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) 
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                
                QNTool.configTableViewCellDefault(cell!)
                //设置选中时颜色
                let bgView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 55))
                bgView.backgroundColor = UIColor.whiteColor()
                cell!.selectedBackgroundView = bgView

                let label : UILabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width,  55))
                label.text = ""
                label.textColor = UIColor.blackColor()
                label.textAlignment = NSTextAlignment.Center
                label.font = UIFont.systemFontOfSize(18)
                label.tag = 10002
                label.backgroundColor = leftSelectColor
                cell?.addSubview(label)
            }
            if indexPath.row < self.departmentDataArray.count {
                let tmpDis  = self.self.departmentDataArray[indexPath.row] as! QN_Department
                let label : UILabel =  cell?.viewWithTag(10002) as! UILabel
                label.text = tmpDis.name
            }
            return cell!
        }else  {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            let cellIdentifier = "rightcell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) 
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                
                QNTool.configTableViewCellDefault(cell!)
                
                //设置选中时颜色
                let bgView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 55))
                bgView.backgroundColor = defaultBackgroundGrayColor
                cell!.selectedBackgroundView = bgView
                
                let lineLabel = UILabel(frame: CGRectMake(0, 59,tableView.frame.size.width, 1))
                lineLabel.backgroundColor = defaultLineColor
                cell?.addSubview(lineLabel)
            }
            if indexPath.row < self.rightArrays.count {
                let tmpDis  = self.self.rightArrays[indexPath.row] as! QN_DepartmentChild
                cell!.textLabel?.text = tmpDis.name
            }
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == leftTableView) {
            let tmp = self.departmentDataArray[indexPath.row ] as! QN_Department
            self.rightArrays =  tmp.child
            self.rightTableView.reloadData()
        }else {
            let tmp  = self.rightArrays[indexPath.row] as! QN_DepartmentChild
            self.finished(tmp.id,tmp.name)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Private Method
    func subViewInit() {
        self.title = "选择科室"
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.view.backgroundColor = UIColor.whiteColor()
        
        headTitle = UILabel(frame: CGRectMake(16, 0, screenWidth, 60))
        headTitle.text = "当前位置：" + hospital
        headTitle.font = UIFont.systemFontOfSize(15)
        self.view.addSubview(headTitle)
        
        self.leftTableView = UITableView(frame:CGRectMake(0, 60 ,screenWidth * 1/3, self.view.bounds.height - 60))
        self.leftTableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , .FlexibleHeight]
        self.leftTableView.dataSource = self
        self.leftTableView.delegate = self
        self.leftTableView.separatorStyle = .None
        self.view.addSubview(self.leftTableView)
        
        self.rightTableView = UITableView(frame:CGRectMake(screenWidth * 1/3 + 30, 60 ,screenWidth * 2/3 - 30, self.view.bounds.height - 60))
        self.rightTableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , .FlexibleHeight]
        self.rightTableView.backgroundColor = UIColor.whiteColor()
        self.rightTableView.dataSource = self
        self.rightTableView.delegate = self
        self.rightTableView.separatorStyle = .None
        self.view.addSubview(self.rightTableView)
    }
    func tableViewInit() {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        self.leftTableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        let tmp = self.departmentDataArray[0] as! QN_Department
        self.rightArrays =  tmp.child
        self.rightTableView.reloadData()
    }
}
