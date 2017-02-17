//
//  ShakeViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ShakeViewController: UIViewController,QNInterceptorProtocol, UICollectionViewDataSource, UICollectionViewDelegate {


    @IBOutlet weak var lbzone: UILabel!
    @IBOutlet weak var sceneLb: UILabel!
    @IBOutlet weak var zoneCollectionView: UICollectionView!
    @IBOutlet weak var sceneCollectionView: UICollectionView!
    @IBOutlet weak var onOfOff: UISwitch!
    var flags:NSMutableArray = []
    var flags1:NSMutableArray = []
    var sceneArrdata:NSMutableArray!
    var sceneArr:NSMutableArray!
    var dataArr:NSMutableArray!
    
    var flagon: Bool = true
    var zoneStr:String = ""
    var scene:Int = 0
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.title = NSLocalizedString("摇摇", tableName: "Localization",comment:"jj")
        lbzone.text = NSLocalizedString("选择区域", tableName: "Localization",comment:"jj")
        sceneLb.text = NSLocalizedString("情景选择", tableName: "Localization",comment:"jj")
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 60, 60)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 60, 60))
        searchButton.setTitle(NSLocalizedString("保存", tableName: "Localization",comment:"jj"), forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            if self.onOfOff.on && (self.zoneStr != "") && (self.scene != 0) && (self.flagon == true){
                saveObjectToUserDefaults("KZone", value: self.zoneStr)
                saveObjectToUserDefaults("KScene", value: self.scene)
                saveObjectToUserDefaults("KSwitch", value: self.flagon)
                QNTool.showPromptView(NSLocalizedString("保存成功，可以使用摇一摇了", tableName: "Localization",comment:"jj"))
            }else{
                QNTool.showPromptView(NSLocalizedString("请开启摇一摇、选择区域和场景", tableName: "Localization",comment:"jj"))
            }
            return RACSignal.empty()
            })
        rightBarButton.addSubview(searchButton)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

        
        
        self.dataArr = NSMutableArray()
        self.sceneArr = [NSLocalizedString("S1 场景一", tableName: "Localization",comment:"jj"),NSLocalizedString("S2 场景二", tableName: "Localization",comment:"jj"),NSLocalizedString("S3 场景三", tableName: "Localization",comment:"jj"),NSLocalizedString("S4 场景四", tableName: "Localization",comment:"jj"),NSLocalizedString("S5 全开模式", tableName: "Localization",comment:"jj"),NSLocalizedString("S6 关闭模式", tableName: "Localization",comment:"jj")]
        self.sceneArrdata = [97,98,99,100,110,111]
        self.flags1 = [false,false,false,false,false,false]
        if getObjectFromUserDefaults("KSwitch") != nil {
            self.onOfOff.on = getObjectFromUserDefaults("KSwitch") as! Bool
        }
        if getObjectFromUserDefaults("KZone") != nil {
            self.zoneStr = getObjectFromUserDefaults("KZone") as! String
        }
        if getObjectFromUserDefaults("KScene") != nil {
            self.scene = getObjectFromUserDefaults("KScene") as! Int
        }
        
        self.zoneCollectionView.delegate = self
        self.zoneCollectionView.dataSource = self
        self.sceneCollectionView.delegate = self
        self.sceneCollectionView.dataSource = self
       
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    //MARK:- private method
    func animationWith(v: UIView,x:CGFloat) {
        UIView .beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        v.frame = CGRectMake(0,x, v.frame.size.width,screenHeight)
        UIView.commitAnimations()
        
    }
    //MARK:-
    //返回多少个组
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    //返回多少个cell
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.zoneCollectionView) {
             return dataArr.count
        }else if (collectionView == self.sceneCollectionView){
            return self.sceneArr.count
        }
       return 0
    }
    //返回自定义的cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == self.zoneCollectionView) {
            let cell:UICollectionViewCell  = self.zoneCollectionView.dequeueReusableCellWithReuseIdentifier("ZoneCell", forIndexPath: indexPath)
            let flag = self.flags[indexPath.row] as! Bool
            let icon = (flag==true) ? "pic_hd" : "navigation_Options_icon"
            let d = self.dataArr[indexPath.row] as! Device
            let lb = cell.viewWithTag(101) as! UILabel
            lb.text = d.dev_name
            let img = cell.viewWithTag(100) as! UIImageView
            img.image = UIImage(named: icon)
            
            
            return cell
        }else if (collectionView == self.sceneCollectionView){
            let cell:UICollectionViewCell  = self.sceneCollectionView.dequeueReusableCellWithReuseIdentifier("SceneCell", forIndexPath: indexPath)
            let str = self.sceneArr[indexPath.row] as! String
            let lb = cell.viewWithTag(101) as! UILabel
            lb.text = str
            let flag = self.flags1[indexPath.row] as! Bool
            let color = (flag==true) ? UIColor.blueColor() : UIColor.darkGrayColor()
            lb.textColor = color
            return cell
        }else{
            return UICollectionViewCell()
        }

    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView == self.zoneCollectionView) {
            let d = self.dataArr[indexPath.row] as! Device
            self.zoneStr = d.address!
            self.fetchScene(d.address!)
            if self.flags.count == 1 {
                self.flags.replaceObjectAtIndex(0 , withObject: !(self.flags.objectAtIndex(0) as! Bool))
            }else {
                for index in 0 ..< self.flags.count {
                    if index == indexPath.row {
                        self.flags.replaceObjectAtIndex(index, withObject: true)
                    }else{
                        self.flags.replaceObjectAtIndex(index, withObject: false)
                    }
                }
                
            }
            self.zoneCollectionView.reloadData()
        }else if (collectionView == self.sceneCollectionView){
            let str = self.sceneArrdata[indexPath.row] as! Int
            self.scene = str
            if self.flags1.count == 1 {
                self.flags1.replaceObjectAtIndex(0 , withObject: !(self.flags1.objectAtIndex(0) as! Bool))
            }else {
                for index in 0 ..< self.flags1.count {
                    if index == indexPath.row {
                        self.flags1.replaceObjectAtIndex(index, withObject: true)
                    }else{
                        self.flags1.replaceObjectAtIndex(index, withObject: false)
                    }
                }
                
            }
            self.sceneCollectionView.reloadData()
        }
       
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
              return CGSizeMake((collectionView.frame.width - 14)/2.0-8, 43)
    }


    //返回cell 上下左右的间距
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        return UIEdgeInsetsMake(4, 4, 2, 4)
    }
    //MARK:- private method
    @IBAction func switchAction(sender: UISwitch) {
//        self.tempDic.setObject(sender.on, forKey: "KSwitch")
//        saveObjectToUserDefaults("KSwitch", value: sender.on)
        self.flagon = sender.on
        if sender.on {
            QNTool.showPromptView(NSLocalizedString("摇一摇开启", tableName: "Localization",comment:"jj"))
        }else{
            QNTool.showPromptView(NSLocalizedString("摇一摇关闭", tableName: "Localization",comment:"jj"))
        }
        
    }
    func fetchScene(addr:String){
        self.sceneArr.removeAllObjects()
        self.flags1.removeAllObjects()
        //查
        let arr:Array<String> = DBManager.shareInstance().selectScene(addr)
        
        for (_, element): (Int, String) in arr.enumerate(){
                self.flags1.addObject(false)
                self.sceneArr.addObject(element)
            
//            print("Device:\(element.address!)", terminator: "");
        }
        self.sceneCollectionView.reloadData()
    }
    func fetchData(){
        self.dataArr.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type! == 2{
                self.flags.addObject(false)
                self.dataArr.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        if getObjectFromUserDefaults("KZone") != nil {
            for index in 0 ..< self.dataArr.count {
                let d = self.dataArr[index] as! Device
                if d.address == getObjectFromUserDefaults("KZone") as? String {
                    self.flags.replaceObjectAtIndex(index, withObject: true)
                }else{
                    self.flags.replaceObjectAtIndex(index, withObject: false)
                }
            }

        }
        if getObjectFromUserDefaults("KScene") != nil  {
            for index1 in 0 ..< self.sceneArrdata.count {
                let d = self.sceneArrdata[index1] as! Int
                if d ==  getObjectFromUserDefaults("KScene")  as! Int {
                    self.flags1.replaceObjectAtIndex(index1, withObject: true)
                }else{
                    self.flags1.replaceObjectAtIndex(index1, withObject: false)
                }
            }
            self.sceneCollectionView.reloadData()
        }

        self.zoneCollectionView.reloadData()
        if self.dataArr.count>0 {
            self.fetchScene((self.dataArr[0] as! Device).address!)
        }
    }

}
