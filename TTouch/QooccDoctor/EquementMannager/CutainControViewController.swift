//
//  CutainControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import Popover

class CutainControViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectePatternAction(sender: AnyObject) {
        
        let btn = sender as! UIButton
        
        let startPoint = CGPoint(x: btn.frame.origin.x+btn.frame.size.width/2, y: btn.frame.origin.y+btn.frame.size.height)
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 180))
        let popover = Popover()
        popover.show(aView, point: startPoint)
        
//        let width = self.view.frame.width / 4
//        let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
//        let options = [
//            .Type(.Up),
//            .CornerRadius(width / 2),
//            .AnimationIn(0.3),
//            .BlackOverlayColor(UIColor.redColor()),
//            .ArrowSize(CGSizeZero)
//            ] as [PopoverOption]
//        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
//        popover.show(aView, fromView: sender as! UIButton)
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
