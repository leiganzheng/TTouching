//
//  EquementsViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/2.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class EquementsViewController: UIViewController {

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

}
