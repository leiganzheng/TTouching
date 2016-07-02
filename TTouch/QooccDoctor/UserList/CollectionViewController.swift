//
//  CollectionViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class CollectionViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{

    var data: NSMutableArray!

    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.myTableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 36)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = defaultLineColor
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        self.fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            //            cell.accessoryType = .DisclosureIndicator
        }
        let d = self.data[indexPath.row] as? Device
        cell.textLabel?.text = d?.dev_name!
        
        let searchButton:UIButton = UIButton(type: .Custom)
        searchButton.frame = CGRectMake(0, 0, 40, 40)
        searchButton.setImage(UIImage(named: "Manage_Collect_icon2"), forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if d?.is_favourited == 0 {
                self?.data.removeObject(d!)
            }
            self?.myTableView .reloadData()
        return RACSignal.empty()
        })
        cell.accessoryView = searchButton
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    //MARK:- private method
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.is_favourited == 0 {
                self.data.addObject(element)
            }
            
        }
        self.myTableView.reloadData()
        
    }

}
