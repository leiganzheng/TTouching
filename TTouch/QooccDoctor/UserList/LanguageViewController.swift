//
//  LanguageViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/1.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController , QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
    
    var titles: NSArray!

    @IBOutlet weak var myTableView: UITableView!
    var flags:NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "语言"
        self.titles = ["简体中文","繁体中文","English"]
        self.flags = [false,true,false]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell.textLabel?.textColor = UIColor.blackColor()
        let title = self.titles[indexPath.row] as! NSString
        cell.textLabel?.text = title as String
        let flag = self.flags[indexPath.row] as! Bool
        let icon = (flag==true) ? "pic_hd" : "Menu_Trigger_icon1"
        cell.imageView?.image = UIImage(named: icon)
        let lb = UILabel(frame: CGRectMake(0, 54, self.view.bounds.width, 1))
        lb.backgroundColor = defaultBackgroundGrayColor
        cell.contentView.addSubview(lb)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        for index in 0 ..< 3 {
            if index == indexPath.row {
                self.flags.replaceObjectAtIndex(index, withObject: true)
            }else{
                self.flags.replaceObjectAtIndex(index, withObject: false)
            }
        }
        self.myTableView.reloadData()
    }


}
