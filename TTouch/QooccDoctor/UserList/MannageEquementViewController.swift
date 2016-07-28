//
//  MannageEquementViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/5.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaAsyncSocket

class MannageEquementViewController: UIViewController  ,GCDAsyncSocketDelegate,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var myTableView: UITableView!
    var data: NSMutableArray = NSMutableArray()
    var icons: NSArray!
    var flags: NSMutableArray!
    var VC: UIViewController!
    
    let addr = "192.168.0.10"
    let port:UInt16 = 33632
    var clientSocket:GCDAsyncSocket!
     var mainQueue = dispatch_get_main_queue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备管理"
        
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
            
        }
        let d = self.data[indexPath.row] as! Device
        

        let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 120, 44))
        logoButton.setTitle(d.dev_name!, forState: .Normal)
        logoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        logoButton.titleLabel?.textAlignment = .Left
        logoButton.contentHorizontalAlignment = .Left
        logoButton.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0)
        cell.contentView.addSubview(logoButton)
        
        let logoButton1:UIButton = UIButton(frame: CGRectMake(screenWidth/2-22, 12, 44, 44))
        logoButton1.setImage(UIImage(data: d.icon_url!), forState: UIControlState.Normal)
      
        cell.contentView.addSubview(logoButton1)
        let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 12, 44, 44))
        searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            
            return RACSignal.empty()
            })
        cell.contentView.addSubview(searchButton)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let d = self.data[indexPath.row] as! Device
        if d.dev_type == 1 {//总控
            self.VC = MainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 2{//六场景
            self.VC = SixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }else if d.dev_type == 3{//单回路调光控制端
            self.VC = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 4{//双回路调光控制端
            self.VC = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 5{//三回路开关控制端
            
        }else if d.dev_type == 6{//六回路开关控制端
            
        }else if d.dev_type == 7{//窗帘控制端
            self.VC = CutainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }else if d.dev_type == 8{//单回路调光控制端(旧版)
            self.VC = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            self.VC = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 10{//三/六回路开关控制端
            self.VC = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 11{
            
        }else if d.dev_type == 12{//空调
            self.VC = AirViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }
        else if d.dev_type == 13{//地暖
            self.VC = DNuanViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }
        else if d.dev_type == 14{//新风
            self.VC = XFengViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }
    
    }
    //MARK://-Private method
    func sendMsg() {//修改各设备的信息,未完待续
        
        // 1.处理请求，返回数据给客户端 ok
        let dict = ["command": "31"]
        
        clientSocket.writeData(self.paramsToJsonDataParams(dict) , withTimeout: -1, tag: 0)
    }
    
    //MARK:- private method
    func paramsToJsonDataParams(params: [String : AnyObject]) -> NSData {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            //            let jsonDataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            return jsonData
        }catch{
            return NSData()
        }
    }
    
    //连接服务器按钮事件
    func connect() {
        do {
            clientSocket = GCDAsyncSocket()
            clientSocket.delegate = self
            clientSocket.delegateQueue = dispatch_get_global_queue(0,0)
            try clientSocket.connectToHost(addr, onPort: port)
        }
            
        catch {
            print("error")
        }
    }
    //MARK:- GCDAsyncSocketDelegate
    func socket(sock:GCDAsyncSocket!, didConnectToHost host: String!, port:UInt16) {
        
        print("与服务器连接成功！")
        
        clientSocket.readDataWithTimeout(-1, tag:0)
        
    }
    
    func socketDidDisconnect(sock:GCDAsyncSocket!, withError err: NSError!) {
        print("与服务器断开连接")
    }
    
    func socket(sock:GCDAsyncSocket!, didReadData data: NSData!, withTag tag:Int) {
        // 1 获取客户的发来的数据 ，把 NSData 转 NSString
        let readClientDataString:NSString? = NSString(data: data, encoding:NSUTF8StringEncoding)
        print(readClientDataString!)
        
        // 2 主界面ui 显示数据
        dispatch_async(mainQueue, {
            
            let showStr:NSMutableString = NSMutableString()
            
        })
        
        // 3.处理请求，返回数据给客户端 ok
        let serviceStr:NSMutableString = NSMutableString()
        serviceStr.appendString("ok\n")
        clientSocket.writeData(serviceStr.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
        
        // 4每次读完数据后，都要调用一次监听数据的方法
        clientSocket.readDataWithTimeout(-1, tag:0)
    }

    func fetchData(){
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDataNotRepeat()

        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type != 100  {
                self.data.addObject(element)
            }
            
        }
        self.myTableView.reloadData()
        
    }

}
