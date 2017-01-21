//
//  UIWindow+Motion.swift
//  QooccDoctor
//
//  Created by leiganzheng on 17/1/21.
//  Copyright © 2017年 Private. All rights reserved.
//

import Foundation
import AudioToolbox
extension UIWindow {
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    public override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
    }
    public override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake
        {
            var  soundID:SystemSoundID = 0
            let path = NSBundle.mainBundle().pathForResource("glass", ofType: "wav")
            AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: path!), &soundID)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound (soundID)
            if (getObjectFromUserDefaults("KZone") != nil) && (getObjectFromUserDefaults("KSwitch") as! Bool == true){
                if  (getObjectFromUserDefaults("KZone") != nil) && (getObjectFromUserDefaults("KScene") != nil){
                    let str = getObjectFromUserDefaults("KZone") as? String
                    let dict = ["command": 36, "dev_addr" : Int(str!)!, "dev_type": 2, "work_status":getObjectFromUserDefaults("KScene") as! Int]
                    QNTool.openSence(dict)
                    
                }
                
            }else{
                QNTool.showPromptView("请去摇一摇设置")
            }
            
            
        }

    }
    public override func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
    }
}