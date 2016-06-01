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

    var titles: NSArray!
    var icons: NSArray!

    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titles = ["书房","主浴","露台","小孩房","主卧房"]
        self.icons = ["Room_StudingRoom_icon","Room_MasterBath_icon","Room_Treeace_icon","Room_ChildRoom _icon","Room_MasterBedRoom_icon"]

        self.myTableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 36)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = UIColor.whiteColor()
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UserTableViewCell.height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            //            cell.accessoryType = .DisclosureIndicator
        }
        cell.textLabel?.text = self.titles[indexPath.row] as? String
        cell.imageView?.image = UIImage(named: (self.icons[indexPath.row] as? String)!)
        let searchButton:UIButton = UIButton(type: .DetailDisclosure)
        searchButton.frame = CGRectMake(0, 5, 40, 30)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
        
        return RACSignal.empty()
        })
        cell.accessoryView = searchButton
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    //MARK:- private method
    
}
