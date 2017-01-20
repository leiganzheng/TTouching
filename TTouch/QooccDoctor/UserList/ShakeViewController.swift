//
//  ShakeViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa
import AudioToolbox

class ShakeViewController: UIViewController,QNInterceptorProtocol, UICollectionViewDataSource, UICollectionViewDelegate {


    @IBOutlet weak var zoneCollectionView: UICollectionView!
    @IBOutlet weak var sceneCollectionView: UICollectionView!
    @IBOutlet weak var onOfOff: UISwitch!
    var searchButton:UIButton?
    var  soundID:SystemSoundID = 0
    var tempDic:NSMutableDictionary = NSMutableDictionary()
    var flags:NSMutableArray = []
    var flags1:NSMutableArray = []
    var sceneArrdata:NSMutableArray!
    var sceneArr:NSMutableArray!
    var dataArr:NSMutableArray!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        let path = NSBundle.mainBundle().pathForResource("glass", ofType: "wav")
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: path!), &soundID);
        
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 60, 60)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 60, 60))
        searchButton.setTitle("保存", forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            if self.onOfOff.on || (self.tempDic.objectForKey("KZone") != nil) || (self.tempDic.objectForKey("KScene") != nil){
                saveObjectToUserDefaults("KShark", value: self.tempDic)
                QNTool.showPromptView("保存成功，可以使用摇一摇了")
            }else{
                QNTool.showPromptView("请开启摇一摇")
            }
            return RACSignal.empty()
            })
        rightBarButton.addSubview(searchButton)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

        
        
        self.dataArr = NSMutableArray()
        self.sceneArr = ["s1  迎宾模式","s2  主灯气氛","s3  影音欣赏","s4  浪漫情调","s5  全开模式","s6  关闭模式"]
        self.sceneArrdata = [97,98,99,100,110,111]
        self.flags1 = [false,false,false,false,false,false]
        if getObjectFromUserDefaults("KShark") != nil {
            let dict = getObjectFromUserDefaults("KShark") as! NSMutableDictionary
            self.tempDic = dict
            if self.tempDic.allValues.count != 0 {
                self.onOfOff.on = self.tempDic.objectForKey("KSwitch") as! Bool
            }

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
        self.resignFirstResponder()
    }
     //MARK:- method
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
////       let anim = [CABasicAnimation animationWithKeyPath:"position"];
////        anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(100, 50)];
////        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(100, 500)];
////        
////        anim.removedOnCompletion = NO;
////        anim.duration = 1.0f;
////        anim.fillMode = kCAFillModeForwards;
////        anim.delegate = self;
////        //  随便拖过来的一个label测试效果
////        [self.label.layer addAnimation:anim forKey:nil];
//        let anim = CABasicAnimation.init(keyPath: "position")
//        a
    }
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake
        {
            searchButton!.hidden = true
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound (soundID)
            if self.tempDic.allValues.count != 0 {
                let dict = ["command": 36, "dev_addr" : self.tempDic.objectForKey("KZone") as! String, "dev_type": 2, "work_status":self.tempDic.objectForKey("KScene") as! Int]
                QNTool.openSence(dict)

            }
           
        }
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
            self.tempDic.setObject(d.address!, forKey: "KZone")
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
            self.tempDic.setObject(str, forKey: "KScene")
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
        self.tempDic.setObject(sender.on, forKey: "KSwitch")
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
        if self.tempDic.allValues.count != 0 {
            for index in 0 ..< self.dataArr.count {
                let d = self.dataArr[index] as! Device
                if d.address == self.tempDic.objectForKey("KZone") as! String {
                    self.flags.replaceObjectAtIndex(index, withObject: true)
                }else{
                    self.flags.replaceObjectAtIndex(index, withObject: false)
                }
            }

        }
        if self.tempDic.allValues.count != 0 {
            for index1 in 0 ..< self.sceneArrdata.count {
                let d = self.sceneArrdata[index1] as! Int
                if d == self.tempDic.objectForKey("KScene") as! Int {
                    self.flags1.replaceObjectAtIndex(index1, withObject: true)
                }else{
                    self.flags1.replaceObjectAtIndex(index1, withObject: false)
                }
            }
            self.sceneCollectionView.reloadData()
        }

        self.zoneCollectionView.reloadData()
        
    }

}
