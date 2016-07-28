//
//  ImageSingleZoomViewController.swift
//  QooccHealth
//
//  Created by haijie on 15/12/9.
//  Copyright (c) 2015年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ImageSingleZoomViewController: UIViewController, UIScrollViewDelegate {
    
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    private(set) var oneImageView: UIImageView!
    var imageUrl: String!
    var deleteImages: (() -> Void)? // 删除图片的回掉
    var isDelete: Bool = false//设置是否显示删除按钮
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:UIStatusBarAnimation.Fade)
        self.view.backgroundColor = UIColor.blackColor()
        let button:UIButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        button.setImage(UIImage(named: "btn_delete1"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(navigationTextColor, forState: UIControlState.Normal)
        button.backgroundColor = UIColor.clearColor()
        button.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                let actionSheet = UIActionSheet(title: "要删除这张图片吗?", delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
                actionSheet.addButtonWithTitle("删除")
                actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                    strongSelf.deleteImages!()
                    self!.navigationController?.popViewControllerAnimated(true)
                })
                actionSheet.showInView(strongSelf.view)
            }
            return RACSignal.empty()
            });
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem?.customView?.hidden = isDelete
        self.buildUIAndData()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(18)]
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 修改导航栏样式
        
        self.navigationController?.navigationBar.barTintColor = navigationBackgroundColor
        self.navigationController?.navigationBar.tintColor = navigationBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: navigationTextColor, NSFontAttributeName: UIFont.systemFontOfSize(18)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-Private Method
    func buildUIAndData(){
        scrollView = UIScrollView(frame:CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 86))
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        imageView = UIImageView(frame: CGRect(origin: CGPointMake(0.0,0), size:CGSizeMake(screenWidth, self.view.bounds.size.height - 86)))
        imageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: ""))
        imageView.contentMode =  UIViewContentMode.Center
        imageView.contentMode = UIViewContentMode.ScaleAspectFit //缩放显示全部
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.bounds.size
        //双击
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        //收缩比
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = minScale;
        //居中
        centerScrollViewContents()
    }
    func centerScrollViewContents() {
        
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(imageView)
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    //Mark:- UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
