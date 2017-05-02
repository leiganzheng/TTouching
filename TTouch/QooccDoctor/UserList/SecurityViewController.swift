//
//  SecurityViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/13.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class SecurityViewController: UIViewController,QNInterceptorProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("监视", tableName: "Localization",comment:"jj")
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
