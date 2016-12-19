//
//  SixPaternViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/4.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class SixPaternViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    var data: NSMutableArray!
    var myTableView: UITableView!
    var superVC:UIViewController!
    var flag:String?//0：主界面 1：设备管理 2：左边快捷菜单
    var myDevice:Device?
    var equementType: EquementSign?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
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
        if self.data.count == 0 {
            return 72
        }else{
            let d = self.data[indexPath.row] as! Device
            if d.dev_type == 3{//单回路调光控制端
                return 104
            }else if d.dev_type == 4{//双回路调光控制端
                return 132
            }else if d.dev_type == 5{//三回路开关控制端
                return 170
            }else if d.dev_type == 6{//六回路开关控制端
                return 190
            }else if d.dev_type == 7{//窗帘控制端
//                return 104
                return 54
            }else if d.dev_type == 8{//单回路调光控制端(旧版)
                return 104
            }else if d.dev_type == 9{//双回路调光控制端(旧版)
                
                return 132
            }else if d.dev_type == 10{//三/六回路开关控制端
                return 170
            }else if d.dev_type == 11{
                return 190
            }else if d.dev_type == 12{//空调
                return 312
            }
            else if d.dev_type == 13{//地暖
                
                return 188
            }
            else if d.dev_type == 14{//新风
                
                return 174
            }else{
                return 0
            }
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count == 0 ? 1 : self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.data.count==0 {
            let cellIdentifier = "Cell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            tableView.separatorStyle = .None
            let lb = UILabel(frame: CGRectMake(screenWidth/2-100,0,200,72))
            lb.text = "暂无数据"
            lb.textAlignment = .Center
            cell.contentView.addSubview(lb)
            return cell
        }else{
            let d = self.data[indexPath.row] as! Device
            if d.dev_type == 3{//单回路调光控制端
                let cellIdentifier = "MSigleTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSigleTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSigleTableViewCell
                }
                cell.titel.setTitle(d.dev_name!, forState: .Normal)
                cell.slider.addTarget(self, action:#selector(SixPaternViewController.valueChanged(_:)), forControlEvents: .ValueChanged)
                return cell
            }else if d.dev_type == 4{//双回路调光控制端
                let cellIdentifier = "MDoubleTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDoubleTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDoubleTableViewCell
                }
                cell.title.setTitle(d.dev_name!, forState: .Normal)
                cell.slider1.addTarget(self, action: #selector(SixPaternViewController.dSliderValueChanged(_:)), forControlEvents: .ValueChanged)
                cell.slider2.addTarget(self, action: #selector(SixPaternViewController.dSliderValueChanged(_:)), forControlEvents: .ValueChanged)
                
                return cell
            }else if d.dev_type == 5{//三回路开关控制端
                let cellIdentifier = "MThreeTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
                }
                cell.title.setTitle(d.dev_name!, forState: .Normal)
                cell.r1Btn.addTarget(self, action: "Troad1:", forControlEvents: .TouchUpInside)
                cell.r2Btn.addTarget(self, action: "Troad1:", forControlEvents: .TouchUpInside)
                cell.r3Btn.addTarget(self, action: "Troad1:", forControlEvents: .TouchUpInside)
                
                return cell
            }else if d.dev_type == 6{//六回路开关控制端
                let cellIdentifier = "MSixTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSixTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSixTableViewCell
                }
                cell.title.setTitle(d.dev_name!, forState: .Normal)
                cell.r1.addTarget(self, action: "road1:", forControlEvents: .TouchUpInside)
                cell.r2.addTarget(self, action: "road2:", forControlEvents: .TouchUpInside)
                cell.r3.addTarget(self, action: "road3:", forControlEvents: .TouchUpInside)
                cell.r4.addTarget(self, action: "road4:", forControlEvents: .TouchUpInside)
                cell.r5.addTarget(self, action: "road5:", forControlEvents: .TouchUpInside)
                cell.r6.addTarget(self, action: "road6:", forControlEvents: .TouchUpInside)
                return cell
            }else if d.dev_type == 7{//窗帘控制端
                let cellIdentifier = "MCurtainTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MCurtainTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MCurtainTableViewCell
                }
                cell.LTitle.text=d.dev_name!
                cell.L1.addTarget(self, action: #selector(SixPaternViewController.open1(_:)), forControlEvents: .TouchUpInside)
                let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SixPaternViewController.longOpen1(_:)))
                longGesture.minimumPressDuration = 0.8
                cell.L1.addGestureRecognizer(longGesture)
                cell.L2.addTarget(self, action: #selector(SixPaternViewController.stop1(_:)), forControlEvents: .TouchUpInside)
                cell.L3.addTarget(self, action: #selector(SixPaternViewController.close1(_:)), forControlEvents: .TouchUpInside)
                return cell
            }else if d.dev_type == 8{//单回路调光控制端(旧版)
                let cellIdentifier = "MSigleTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSigleTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSigleTableViewCell
                }
                return cell
            }else if d.dev_type == 9{//双回路调光控制端(旧版)
                let cellIdentifier = "MDoubleTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDoubleTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDoubleTableViewCell
                }
                return cell
            }else if d.dev_type == 10{//三/六回路开关控制端
                let cellIdentifier = "MThreeTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
                }
                cell.title.setTitle(d.dev_name!, forState: .Normal)
                return cell
            }else if d.dev_type == 11{
                let cellIdentifier = "MSixTouchTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSixTouchTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSixTouchTableViewCell
                }
                cell.title.setTitle(d.dev_name!, forState: .Normal)
                return cell
            }else if d.dev_type == 12{//空调
                let cellIdentifier = "MAirTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MAirTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MAirTableViewCell
                }
                return cell
            }
            else if d.dev_type == 13{//地暖
                let cellIdentifier = "MDiNuanTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDiNuanTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDiNuanTableViewCell
                }
                return cell
            }
            else if d.dev_type == 14{//新风
                let cellIdentifier = "MXinFenTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MXinFenTableViewCell!
                if cell == nil {
                    cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MXinFenTableViewCell
                }
                return cell
            }else{
                return UITableViewCell()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
//        superVC.hidesBottomBarWhenPushed = true
//        let d = self.data[indexPath.row] as! Device
//        if d.dev_type == 3{//单回路调光控制端
//            let vc = SigleLightViewController.CreateFromStoryboard("Main") as! SigleLightViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 4{//双回路调光控制端
//            let vc = DoubleLightViewController.CreateFromStoryboard("Main") as! DoubleLightViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 5{//三回路开关控制端
//            let vc = ThreeOrSixViewController.CreateFromStoryboard("Main") as! ThreeOrSixViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 6{//六回路开关控制端
//            let vc = ThreeOrSixViewController.CreateFromStoryboard("Main") as! ThreeOrSixViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 7{//窗帘控制端
//            let vc = CutainControViewController.CreateFromStoryboard("Main") as! CutainControViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//            
//        }else if d.dev_type == 8{//单回路调光控制端(旧版)
//            let vc = SigleLightViewController.CreateFromStoryboard("Main") as! SigleLightViewController
//            vc.device=d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 9{//双回路调光控制端(旧版)
//            let vc = DoubleLightViewController.CreateFromStoryboard("Main") as! DoubleLightViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 10{//三/六回路开关控制端
//            let vc = ThreeOrSixViewController.CreateFromStoryboard("Main") as! ThreeOrSixViewController
//            vc.device = d
//            superVC.navigationController?.pushViewController(vc, animated: true)
//        }else if d.dev_type == 11{
//            
//        }else if d.dev_type == 12{//空调
//            
//        }
//        else if d.dev_type == 13{//地暖
//            
//        }
//        else if d.dev_type == 14{//新风
//            
//        }

    }
    //MARK:- private method
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        if self.flag == "0" {
            for (_, element): (Int, Device) in arr.enumerate(){
                if element.dev_area == self.myDevice?.address {//六场景
                    self.data.addObject(element)
                }
                print("Device:\(element.address!)", terminator: "");
            }

        }else if self.flag == "2" {
            let image = UIImageJPEGRepresentation(UIImage(named:"icon_no" )!, 1)
            let noPattern = Device(address: "1000", dev_type: 100, work_status: 31, dev_name: "未分区的区域", dev_status: 1, dev_area: "0", belong_area: "", is_favourited: 0, icon_url: image)
//            self.data.addObject(noPattern)
            if self.equementType == .Light {
                //查
                let arr:Array<Device> = DBManager.shareInstance().selectDatas()
                
                for (_, element): (Int, Device) in arr.enumerate(){
                    if  (element.dev_type == 9 || element.dev_type == 3 || element.dev_type == 4 || element.dev_type == 5 || element.dev_type == 6 || element.dev_type == 8) &&  element.dev_area == self.myDevice?.address  {
                        self.data.addObject(element)
                    }
                    
                }
            }
            if self.equementType == .Curtain {
                let arr:Array<Device> = DBManager.shareInstance().selectDatas()
                
                for (_, element): (Int, Device) in arr.enumerate(){
                    if  element.dev_type == 7 &&  element.dev_area == self.myDevice?.address {
                        self.data.addObject(element)
                    }
                }
            }
            if self.equementType == .Action {
                let arr:Array<Device> = DBManager.shareInstance().selectDatas()
                
                for (_, element): (Int, Device) in arr.enumerate(){
                    if  element.dev_type == 11 &&  element.dev_area == self.myDevice?.address {
                        self.data.addObject(element)
                    }
                }
                
            }
            if self.equementType == .Air {
                let arr:Array<Device> = DBManager.shareInstance().selectDatas()
                for (_, element): (Int, Device) in arr.enumerate(){
                    if  element.dev_type == 12 &&  element.dev_area == self.myDevice?.address {
                        self.data.addObject(element)
                    }
                }
            }
        }
        self.myTableView.reloadData()
        
    }
    //MARK:- Private Method
    func valueChanged(slider: UISlider) {
        /*"dev_addr": 38585,
         "dev_type": 3,
         "work_status": 0,
         "dev_name": "单回路调光",
         "dev_status": 1,
         "dev_area": 0*/
        //单回路调光控制端 work_status操作码范围是 0 ~ 99,分别表示调光百分比; 0:关闭回路调光;99:最大调光亮度。
        //        let data = slider.value
        let tempCell = slider.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openLight(d, value: Int(slider.value))
        
    }
    func dSliderValueChanged(slider: UISlider) {
        //双回路调光控制端 work_status设备操作码,范围是 0 ~ 299,表示调光百分比; 0:同时关闭两回路;99:两回路最大调光亮度; 100:关闭左回路;199:左回路最大调光亮度; 200:关闭右回路;299:右回路最大调光亮度; 例:左回路 60%亮度:160;右回路 70%亮度:270。
        //        let data = slider.value
        let tempCell = slider.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openDLight(d, slider: slider)
    }
    func open1(sender: UIButton){
        
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 0)
        
    }
    func longOpen1(sender: UIGestureRecognizer){
        
        let tempCell = sender.view!.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 1)
    }
    func stop1(sender: UIButton){
        
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 2)
    }
    func imageOfButton(sender:UIButton){
        sender.selected = !sender.selected
        let title = sender.selected ? "navigation_Options_icon_s" : "navigation_Options_icon"
        sender.setImage(UIImage(named: title), forState: .Normal)

    }
    func close1(sender: UIButton){
        
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 3)
    }
    func Troad1(sender:UIButton){
        self.imageOfButton(sender)
    }
    func Troad2(sender:UIButton){
        self.imageOfButton(sender)
    }

    func Troad3(sender:UIButton){
        
    }
    func road1(sender:UIButton){
        
    }
    func road2(sender:UIButton){
        
    }
    func road3(sender:UIButton){
        
    }
    func road4(sender:UIButton){
        
    }
    func road5(sender:UIButton){
        
    }
    func road6(sender:UIButton){
        
    }



}
