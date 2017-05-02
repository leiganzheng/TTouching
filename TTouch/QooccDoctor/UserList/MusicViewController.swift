//
//  MusicViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/20.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController,QNInterceptorProtocol {
    var flag:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        if flag == 0 {
             self.title = NSLocalizedString("保全", tableName: "Localization",comment:"jj")
        }else{
             self.title = NSLocalizedString("音乐", tableName: "Localization",comment:"jj")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
