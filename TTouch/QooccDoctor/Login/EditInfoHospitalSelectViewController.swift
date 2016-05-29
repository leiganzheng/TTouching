//
//  EditInfoHospitalSelectViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/17.
//  Copyright (c) 2015年 juxi. All rights reserved.
//
// MARK: - 填写资料  选择医院 
import UIKit

class EditInfoHospitalSelectViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    var tableView : UITableView!
    
    var province_id: String?    // 省 Id
    var city_id: String?        // 市 Id
    var currentPlace = ""
    var hospitalList : NSArray = NSArray()
    var finished :((String,String,String,String) -> Void)!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.subViewInit()
        self.fetchHospitalItems()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.hospitalList.count
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
        if let tmp = self.hospitalList[indexPath.row] as? NSDictionary {
            let name = tmp["hospitalName"] as! String
            cell.textLabel?.text = name
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let tmp = self.hospitalList[indexPath.row] as? NSDictionary {
            let name = tmp["hospitalName"] as! String
            let id: AnyObject? = tmp["id"]
            self.finished(self.province_id!,self.city_id!,name,"\(id!)")
        }
        let array = NSArray(array: self.navigationController!.viewControllers)
        for vc in array {
            if vc is EditInformationViewController {
                self.navigationController?.popToViewController(vc as! UIViewController, animated: true)
            }
        }
    }
    
    // MARK: Private Method
    func subViewInit() {
        self.title = "选择医院"
        let headTitle = UILabel(frame: CGRectMake(16, 0, screenWidth, 60))
        headTitle.text = "当前位置：" + currentPlace
        headTitle.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(headTitle)
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView = UITableView(frame:CGRectMake(0, 60 ,self.view.bounds.width, self.view.bounds.height - 60))
        self.tableView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .None
        self.view.addSubview(self.tableView)
    }
    func fetchHospitalItems() {
            }
}
