//
//  EquementsViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/2.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class EquementsViewController: UIViewController,AsyncSocketDelegate{

    let addr = "192.168.0.10"
    let port:UInt16 = 35000
    var socket:GCDAsyncSocket!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAction(sender: AnyObject) {
        self.navigationController?.pushViewController(ModifyEquenmentsViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
    }
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:UInt16)
    {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("Received Response")
    }
    
    func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        print("Connected to \(host) on port \(p).")
    }
    //MARK:- private method
    func fectchData() {
        
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.connectToHost(addr, onPort: port)
            let request:String = "Arn.Preg:3302:"
            let data:NSData = request.dataUsingEncoding(NSUTF8StringEncoding)!
            socket.writeData(data, withTimeout: -1.0, tag: 0)
            socket.readDataWithTimeout(-1.0, tag: 0)
        } catch let e {
            print(e)
        }
    }

}
