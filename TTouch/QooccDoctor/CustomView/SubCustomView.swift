//
//  SubCustomView.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SubCustomView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource{

    var collectionView:UICollectionView?
    var flag: NSInteger?
    var data:NSArray? {
        didSet {
            self.updateLayerFrames()
        }
    }
    var icon:NSArray?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    //实现UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.data!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let identify:String = "Cell"
        let cell:UICollectionViewCell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(
            identify, forIndexPath: indexPath)
        let button:UIButton = UIButton(frame:CGRectMake(0, 0, screenWidth/2, 50))
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        if icon?.count>0 {
            button.setImage(UIImage(named: (self.icon![indexPath.row] as? String)!), forState: UIControlState.Normal)
        }
        
        button.setTitle(self.data![indexPath.row] as? String, forState: UIControlState.Normal)
        cell.contentView.addSubview(button)
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenWidth/2-6, 50)
    }

    //实现UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        NSLog("cell")
        //总控
         let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":17]
        let sockertManger = SocketManagerTool()
        sockertManger.sendMsg(dict)
        
//        //六情景
//        let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":97]
//        let sockertManger = SocketManagerTool()
//        sockertManger.sendMsg(dict)

    }
    func updateLayerFrames() {
        let height = CGFloat(self.data!.count/2 == 0 ? self.data!.count/2 : self.data!.count/2 + 1)*50
        self.frame.size.height = height
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRectMake(0, 0, screenWidth, height), collectionViewLayout: layout)
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            self.collectionView!.delegate = self;
        self.collectionView!.dataSource = self;
        
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.collectionView!)
        self.collectionView?.reloadData()
        
    }

}
