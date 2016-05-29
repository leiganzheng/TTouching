//
//  EditInfoSelectLeveOneViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/17.
//  Copyright (c) 2015年 juxi. All rights reserved.
//
// MARK: - 填写资料  包括职称   病症
import UIKit
class EditInfoSelectLeveOneViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
    var tableView : UITableView!
    var illnessDataArray : NSMutableArray! = NSMutableArray()
    let jobDataArray : NSArray = ["助理医师","医师","主治医师","主任医师","副主任医师"]
    let illnessArray = QN_Disease.getIllData()  //获取病症
    var type : Int! = 0  //  1 为 jobDataArray  2 为 illnessDataArray
    var finished :((String,String) -> Void)!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.type == 1 ? "选择职称" : "擅长症状"
        
        for ill in illnessArray {
            illnessDataArray.addObject((ill as! QN_Disease).name)
        }
        self.subViewInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return type == 1 ? self.jobDataArray.count :  self.illnessDataArray.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellId) 
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            QNTool.configTableViewCellDefault(cell)
            cell.accessoryType = .None
        }
        let line = UIView()
        line.frame = CGRectMake(16, 54, self.tableView.bounds.width, 1)
        line.backgroundColor = defaultLineColor
        cell.addSubview(line)
        let tmp = (type == 1 ? self.jobDataArray :  self.illnessDataArray)
        cell.textLabel?.text = tmp[indexPath.row] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if type == 2 {
            //病症
            let tmp = illnessArray[indexPath.row] as! QN_Disease
           self.finished(tmp.name,tmp.id)
        } else {
            let tmp = (type == 1 ? self.jobDataArray :  self.illnessDataArray)
            let des = tmp[indexPath.row] as? String
            self.finished(des!,"")
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: Private Method
    func subViewInit() {
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.view.backgroundColor = defaultBackgroundGrayColor
        self.tableView = UITableView(frame:self.view.frame)
        self.tableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , .FlexibleHeight]
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .None
        self.view.addSubview(self.tableView)
    }

}
