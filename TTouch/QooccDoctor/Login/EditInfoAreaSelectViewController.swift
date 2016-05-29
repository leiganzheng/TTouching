//
//  EditInfoAreaSelectViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/17.
//  Copyright (c) 2015年 juxi. All rights reserved.
//
// MARK: - 填写资料  选择地区
import UIKit
import CoreLocation

class EditInfoAreaSelectViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate {
    var area : NSMutableArray! = NSMutableArray()
    var leftTableView : UITableView!
    var rightTableView : UITableView!
    var headTitle : UILabel!
    var  rightArrays : NSArray = NSArray()
    var leftSelectColor = UIColor(red: 228/255, green: 243/255, blue: 255/255, alpha: 1.0) 
    
    var provinceId = ""
    var cityId = ""
    var provinceN: String?    // 省 名
    var cityN: String?        // 市 名
    var finished :((String,String,String,String) -> Void)!
    let locationManager : CLLocationManager = CLLocationManager()
    var currentPlace = ""
    var closeLocation = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化省市区
        if let areaFilePath = NSBundle.mainBundle().pathForResource("area", ofType: "txt"), let areaData = NSData(contentsOfFile: areaFilePath) {
            do {
                self.area = try NSJSONSerialization.JSONObjectWithData(areaData, options: NSJSONReadingOptions()) as? NSMutableArray
            }catch{
                
            }
        }
        if SYSTEM_VERSION_FLOAT >= 8.0 {
            self.view.layoutMargins = UIEdgeInsetsZero
        }
        self.subViewInit()
        self.tableViewInit()
        //定位
        self.configLocationManager()
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.closeLocation = true
        self.locationManager.stopUpdatingLocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.leftTableView ? self.area.count : self.rightArrays.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView == self.leftTableView ? 55 : 60
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView  == leftTableView) {
            let cellIdentifier = "leftcell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) 
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                
                QNTool.configTableViewCellDefault(cell!)
                //设置选中时颜色
                let bgView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 55))
                bgView.backgroundColor = UIColor.whiteColor()
                cell!.selectedBackgroundView = bgView
                
                let label : UILabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width,  55))
                label.text = ""
                label.textColor = UIColor.blackColor()
                label.textAlignment = NSTextAlignment.Center
                label.font = UIFont.systemFontOfSize(18)
                label.tag = 10002
                label.backgroundColor = leftSelectColor
                cell?.addSubview(label)
            }
            if indexPath.row < self.area.count {
                let label : UILabel =  cell?.viewWithTag(10002) as! UILabel
                let name =  self.area[indexPath.row][kKeyName] as? String
                label.text = name
            }
            return cell!
        }else  {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            let cellIdentifier = "rightcell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) 
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                
                QNTool.configTableViewCellDefault(cell!)
                
                let lineLabel = UILabel(frame: CGRectMake(0, 59,tableView.frame.size.width, 1))
                lineLabel.backgroundColor = defaultLineColor
                cell?.addSubview(lineLabel)
            }
            if indexPath.row < self.rightArrays.count {
                let tmp: AnyObject  = self.rightArrays[indexPath.row]
                let name = tmp[kKeyName] as? String
                cell!.textLabel?.text = name
            }
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == leftTableView) {
            let citys = self.area[indexPath.row][kKeyCitys] as! NSArray
            provinceId = self.area[indexPath.row][kKeyId] as! String
            self.provinceN = self.area[indexPath.row][kKeyName] as? String
            self.rightArrays =  citys
            self.rightTableView.reloadData()
        }else {
            let tmp: AnyObject  = self.rightArrays[indexPath.row]
            self.cityId = tmp[kKeyId] as! String
            self.cityN = tmp[kKeyName] as? String
            self.locationManager.stopUpdatingLocation()
            self.jumpToHospitalVc(self.provinceId,cityId: self.cityId,proN: self.provinceN!,cityN: self.cityN!)
        }
    }
    //MARK: -CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation : CLLocation! = locations.last
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currLocation, completionHandler: { (placemarks, error) -> Void in
            if placemarks != nil && (placemarks! as NSArray).count > 0 {
                let dict = (placemarks! as NSArray).objectAtIndex(0).addressDictionary 
                let currentCity = dict!!["City"] as! String
                self.locationManager.stopUpdatingLocation()
                if !self.closeLocation  {
                    self.areaInit(currentCity)
                }
            }
        })
    }
    // MARK: Private Method
    func subViewInit() {
        self.title = "选择医院"
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        let imgV = UIImageView(frame: CGRectMake(16, 20, 16, 20))
        imgV.image = UIImage(named: "Login_Location")
        self.view.addSubview(imgV)
        headTitle = UILabel(frame: CGRectMake(40, 22, screenWidth, 16))
        headTitle.text = "当前位置：" + currentPlace
        headTitle.font = UIFont.systemFontOfSize(16)
        self.view.addSubview(headTitle)
        self.leftTableView = UITableView(frame:CGRectMake(0, 60 ,screenWidth * 1/3, self.view.bounds.height - 60))
        self.leftTableView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        self.leftTableView.dataSource = self
        self.leftTableView.delegate = self
        self.leftTableView.separatorStyle = .None
        self.view.addSubview(self.leftTableView)
        
        self.rightTableView = UITableView(frame:CGRectMake(screenWidth * 1/3 + 30, 60 ,screenWidth * 2/3 - 30, self.view.bounds.height - 60))
        self.rightTableView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        self.rightTableView.dataSource = self
        self.rightTableView.delegate = self
        self.rightTableView.separatorStyle = .None
        self.view.addSubview(self.rightTableView)
    }
    func jumpToHospitalVc(proId:String,cityId:String,proN:String,cityN:String,isFromLocation : Bool = false) {
        let vc = EditInfoHospitalSelectViewController()
        vc.province_id = proId
        vc.city_id = cityId
        self.currentPlace = proN + cityN
        vc.currentPlace = self.currentPlace
        self.headTitle.text = "当前位置：" + self.currentPlace
        vc.finished = self.finished
        if isFromLocation && self.closeLocation {
            return
        }
        self.closeLocation = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func configLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        locationManager.requestAlwaysAuthorization()
        if SYSTEM_VERSION_FLOAT > 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    //地区  定位获取地点信息
    func areaInit(currentCity : String) {
        var areaFile : NSArray!
        let areaArray : NSMutableArray = NSMutableArray()
        if let areaFilePath = NSBundle.mainBundle().pathForResource("area", ofType: "txt"), let areaData = NSData(contentsOfFile: areaFilePath) {
            do {
                areaFile = try NSJSONSerialization.JSONObjectWithData(areaData, options: NSJSONReadingOptions()) as? NSArray
            }catch{
                
            }
                   }
        for(var i : Int = 0 ;i < areaFile.count; i++ ) {
            let dic : NSDictionary = areaFile[i] as! NSDictionary
            areaArray.addObject(QN_Area(dic))
        }
        if !self.closeLocation  {
            predicate(currentCity as NSString, array: areaArray)
        }
    }
    //筛选出地点
    func predicate(city : NSString,array: NSArray) {
        let cityStr = city.substringToIndex(city.length - 1)
        let predicate = NSPredicate(format: "name = '\(cityStr)'")
        var i = 0
        for tmp in array {
            let tmpCity = (tmp as! QN_Area).citys.filteredArrayUsingPredicate(predicate)
            if tmpCity.count != 0 {
                self.cityId = (tmpCity[0] as! QN_City).id
                self.provinceId = (tmp as! QN_Area).id
                self.cityN = (tmpCity[0] as! QN_City).name
                self.provinceN = (tmp as! QN_Area).name
                if !self.closeLocation {
                    self.headTitle.text = "当前位置：" + self.provinceN! + self.cityN!
                    let index = NSIndexPath(forRow: i, inSection: 0)
                    self.leftTableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top)
                    let citys = self.area[i][kKeyCitys] as! NSArray
                    self.rightArrays =  citys
                    self.rightTableView.reloadData()
                    var j = 0
                    for city in citys {
                        if (city[kKeyId] as? String) == (tmpCity[0] as! QN_City).id {
                            let index = NSIndexPath(forRow: j, inSection: 0)
                            self.rightTableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top)
                        }
                        j++
                    }
//                    if !self.closeLocation  {
//                        self.jumpToHospitalVc(self.provinceId, cityId: self.cityId, proN: self.provinceN!, cityN: self.cityN!,isFromLocation: true)
//                    }
                }
            }
            i++
        }
    }
    func tableViewInit() {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        self.leftTableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        let citys = self.area[0][kKeyCitys] as! NSArray
        provinceId = self.area[0][kKeyId] as! String
        self.provinceN = self.area[0][kKeyName] as? String
        self.rightArrays =  citys
        self.rightTableView.reloadData()
    }
}