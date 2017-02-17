//
//  CollectionViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class CollectionViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{

    var data: NSMutableArray!
    var flags: NSMutableArray!
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("收藏", tableName: "Localization",comment:"jj")
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.flags.count == 0 {
            return 72
        }else{
            let temp = self.flags[indexPath.row] as! Bool
            return temp == true ? 260 : 72
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count == 0 ? 1 : self.data.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.data.count == 0 {
            let cellIdentifier = "Cell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            tableView.separatorStyle = .None
            let lb = UILabel(frame: CGRectMake(screenWidth/2-100,0,200,72))
            lb.text = NSLocalizedString("暂无数据,下拉重试", tableName: "Localization",comment:"jj")
            lb.textAlignment = .Center
            cell.contentView.addSubview(lb)
            return cell
        }else{
             tableView.separatorStyle = .SingleLine
            let cellIdentifier = "UserTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UserTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! UserTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
            }
            let d = self.data[indexPath.row] as! Device
            cell.name.text = d.dev_name!
            
            let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 44, 44))
            logoButton.setImage(UIImage(data: d.icon_url!), forState: UIControlState.Normal)
            cell.contentView.addSubview(logoButton)
            
            let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 12, 44, 44))
            searchButton.setImage(UIImage(named: "Manage_Collect_icon2"), forState: UIControlState.Normal)
            searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                DBManager.shareInstance().updateFav(1, type: (d.address)!, complete: { (flag) in
                    if flag as! Int == 0 {
                        QNTool.showPromptView("取消收藏失败")
                    }else {
                        QNTool.showPromptView("已取消")
                        if d.is_favourited == 0 {
                            self?.data.removeObject(d)
                        }
                        self?.myTableView .reloadData()
                    }
                })
                return RACSignal.empty()
                })
            cell.contentView.addSubview(searchButton)
            searchButton.hidden = d.dev_type == 1
            
            let temp = self.flags[indexPath.row] as! Bool
            
            if temp {
                let v = SubCustomView(frame: CGRectMake(0, 72,screenWidth, 100))
                v.tag = indexPath.row + 100
                v.device = d
                v.flag = 0
                v.data = [NSLocalizedString("S1 场景一", tableName: "Localization",comment:"jj"),NSLocalizedString("S2 场景二", tableName: "Localization",comment:"jj"),NSLocalizedString("S3 场景三", tableName: "Localization",comment:"jj"),NSLocalizedString("S4 场景四", tableName: "Localization",comment:"jj"),NSLocalizedString("S5 全开模式", tableName: "Localization",comment:"jj"),NSLocalizedString("S6 关闭模式", tableName: "Localization",comment:"jj")]
                cell.contentView.addSubview(v)
                cell.addLine(16, y: 126, width: screenWidth-32, height: 1)
                cell.addLine(16, y: 188, width: screenWidth-32, height: 1)
                cell.addLine(0, y: 258, width: screenWidth, height: 1)
            }else{
                let tempV = cell.contentView.viewWithTag(indexPath.row+100)
                tempV?.removeFromSuperview()
                
            }
            cell.addLine(0, y: 71, width: screenWidth, height: 1)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let flag = !(self.flags[indexPath.row] as! Bool)
        self.flags.replaceObjectAtIndex(indexPath.row, withObject: flag)
        self.myTableView.reloadData()
    }
    
    //MARK:- private method
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        self.flags = NSMutableArray()
        self.flags.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.is_favourited == 0 {
                self.data.addObject(element)
                 self.flags.addObject(false)
            }
            
        }
        self.myTableView.reloadData()
        
    }

}
