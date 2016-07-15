//
//  TimeMannageViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/7.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TimeMannageViewController: UIViewController,QNInterceptorProtocol,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var myTableView: UITableView!
    var data:NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.data = NSMutableArray()
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        searchButton.setImage(UIImage(named: "time"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            let vc = NewClockViewController()
            vc.bock =  {(obj) -> Void in
                self?.data.addObject(obj!)
                self?.myTableView.reloadData()
            }
            self?.presentViewController(UINavigationController(rootViewController:vc ), animated: true, completion: nil)
            return RACSignal.empty()
            })
        rightBarButton.addSubview(searchButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = defaultBackgroundGrayColor
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: ClockTableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId) as! ClockTableViewCell
        if cell == nil {
            cell = ClockTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell.contentView.backgroundColor = UIColor.whiteColor()
        let dict = self.data[indexPath.row] as! NSMutableDictionary
        var str = dict.valueForKey("name") as? String
        if str == "" {
            str = "闹钟"
        }
        cell.name.setTitle(str, forState: .Normal)
        cell.time.setTitle(dict.valueForKey("time") as? String, forState: .Normal)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }


}
