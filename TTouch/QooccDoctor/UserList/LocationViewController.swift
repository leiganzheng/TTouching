//
//  LocationViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/15.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController,QNInterceptorProtocol{

    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("定位", tableName: "Localization",comment:"jj")
         lb.text = NSLocalizedString("功能升级中...", tableName: "Localization",comment:"jj")
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
