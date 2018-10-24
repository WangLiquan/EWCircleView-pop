//
//  ViewController.swift
//  EWCircleView+pop
//
//  Created by Ethan.Wang on 2018/9/20.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit
import pop
struct ScreenInfo {
    static let Frame = UIScreen.main.bounds
    static let Height = Frame.height
    static let Width = Frame.width
    static let navigationHeight:CGFloat = navBarHeight()

    static func isIphoneX() -> Bool {
        return UIScreen.main.bounds.equalTo(CGRect(x: 0, y: 0, width: 375, height: 812))
    }
    static private func navBarHeight() -> CGFloat {
        return isIphoneX() ? 88 : 64;
    }
}

// 子view比例
let MENURADIUS = 0.5 * ScreenInfo.Width
// 中心view比例
let PROPORTION: Float = 0.65

class ViewController: UIViewController {

    ///监听器,当长按中间按钮时监听subView的即时layer.不按时暂停
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        return displayLink
    }()
    ///周围subView的数据
    private var subArray: [String] = ["1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8"]
    // 背景view
    private var contentView: UIView?
    // 中心view
    private var circleView: UIImageView?
    // 子view Array
    private var viewArray: [EWSubView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentView()
        updateCircleViews()
        // Do any additional setup after loading the view, typically from a nib.
    }
    /// 添加背景view,也是旋转的view
    private func setContentView() {
        setCircleView()
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenInfo.Width, height: ScreenInfo.Width))
        contentView?.center = self.view.center
        self.view.addSubview(contentView!)
        contentView!.addSubview(circleView!)
    }
    /// 添加中间圆形view
    private func setCircleView(){
        let view = UIImageView(frame: CGRect(x: 0.5 * CGFloat(1 - PROPORTION) * ScreenInfo.Width + 10, y: 0.5 * CGFloat(1 - PROPORTION) * ScreenInfo.Width + 10, width: ScreenInfo.Width * CGFloat(PROPORTION) - 20, height: ScreenInfo.Width * CGFloat(PROPORTION) - 20))
        /// 为了适配保证size变化center不变
        let centerPoint = view.center
        view.frame.size = CGSize(width: ScreenInfo.Width * CGFloat(PROPORTION) - 40, height: ScreenInfo.Width * CGFloat(PROPORTION) - 40)
        view.center = centerPoint
        view.image = UIImage(named: "11")
        view.layer.cornerRadius = view.frame.width*0.5
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        circleView = view
        let button = UIButton(frame:view.frame)
        button.layer.cornerRadius = view.frame.width * 0.5
        button.addTarget(self, action: #selector(autoRotateContentView), for: .touchDown)
        button.addTarget(self, action: #selector(endRotateContentView), for: [.touchUpInside, .touchDragExit])
        circleView?.addSubview(button)
    }
    /// 布局旋转的子view
    private func rotationCircleCenter(contentOrgin: CGPoint,
                                      contentRadius: CGFloat,subnode: [String]){
        // 添加比例,实现当要添加的子view数量较多时候可以自适应大小.
        var scale: CGFloat = 1
        if subnode.count > 10 {
            scale = CGFloat(CGFloat(subnode.count) / 13.0)
        }

        for i in 0..<subnode.count {
            let x = contentRadius * CGFloat(sin(.pi * 2 / Double(subnode.count) * Double(i)))
            let y = contentRadius * CGFloat(cos(.pi * 2 / Double(subnode.count) * Double(i)))
            // 当子view数量大于10个,view.size变小,防止view偏移,要保证view.center不变.
            let view = EWSubView(frame: CGRect(x:contentRadius + 0.5 * CGFloat((1 + PROPORTION)) * x - 0.5 * CGFloat((1 - PROPORTION)) * contentRadius, y: contentRadius - 0.5 * CGFloat(1 + PROPORTION) * y - 0.5 * CGFloat(1 - PROPORTION) * contentRadius, width: CGFloat((1 - PROPORTION)) * contentRadius, height: CGFloat((1 - PROPORTION)) * contentRadius), imageName: subnode[i])
            let centerPoint = view.center
            view.frame.size = CGSize(width: CGFloat((1 - PROPORTION)) * contentRadius / scale , height: CGFloat((1 - PROPORTION)) * contentRadius / scale)
            view.center = centerPoint
            view.drawSubView()
            // 这个tag判断view是不是在最下方变大状态,非变大状态0,变大为1
            view.tag = 0
            // 获取子view在当前屏幕中的rect.来实现在最下方的那个变大
            let rect = view.convert(view.bounds, to: UIApplication.shared.keyWindow)
            let viewCenterX = rect.origin.x + (rect.width) / 2
            if viewCenterX > self.view.center.x - 20 && viewCenterX < self.view.center.x + 20 && rect.origin.y > (contentView?.center.y)! {
                view.transform = view.transform.scaledBy(x: 1.5, y: 1.5)
                view.tag = 1
            }
            contentView?.addSubview(view)
            viewArray.append(view)
        }
    }

    private func updateCircleViews() {
        self.rotationCircleCenter(contentOrgin: CGPoint(x: MENURADIUS, y: MENURADIUS), contentRadius: MENURADIUS,subnode:subArray)
    }
    ///contentView点击中心自动旋转方法
    @objc func autoRotateContentView(){
        ///先添加整体背景旋转动画
        let animation: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
        ///旋转角度,给一个大的数字优化体验,防止卡顿
        animation.toValue = CGFloat.pi * 16
        ///动画持续时间
        animation.duration = 32
        ///使动画重复
        animation.repeatCount = Int(MAXPRI)
        ///动画线性匀速展示
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        ///将动画添加到contentView.layer
        self.contentView?.layer.pop_add(animation, forKey: "rotation")

        ///添加中心View反向旋转动画
        let subAnimation: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
        ///将旋转角度反向
        subAnimation.toValue = -CGFloat.pi * 16
        ///给一个相同速度来实现中心view不动
        subAnimation.duration = 32
        subAnimation.repeatCount = Int(MAXPRI)
        subAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        ///将动画添加到circleView.layer
        self.circleView?.layer.pop_add(subAnimation, forKey: "subRotation")
        ///监听子view.frame的监听器暂停
        displayLink.isPaused = false
        ///给周围旋转的子View添加同样的反向旋转动画
        for subView in viewArray {
            subView.layer.pop_add(subAnimation, forKey: "subRotation")
        }
    }
    ///监听器回调方法
    @objc func displayLinkCallback() {
        for subView in viewArray {
            ///根据subView在屏幕中的frame来实现最下方view变大,并获取其image
            ///动画中获取view.frame,layer.frame都不变,不能即时获取,所以获取subView.layer.presentaion().bounds
            changeBottomSubView(subView: subView, bounds: (subView.layer.presentation()?.bounds)!)
        }
    }
    ///不再点击中心View时,将动画移除.
    ///之前尝试使用CABasicAnimation,发现其只修改layer.frame,并不修改View.frame,所以当移除动画或者会View.frame返回原处,或者就是layer与frame不同,导致View错位展示效果与功能效果不匹配.所以尝试使用faceBook的pop框架.
    @objc func endRotateContentView(){
        contentView?.layer.pop_removeAllAnimations()
        circleView?.layer.pop_removeAllAnimations()
        for subView in viewArray{
            subView.layer.pop_removeAllAnimations()
        }
        ///将监听器暂停
        displayLink.isPaused = true
    }
    /// 当subView在最下方时进行的修改其大小,修改中心circleView.image方法
    ///
    /// - Parameters:
    ///   - subView: subView
    ///   - bounds: 如果是长按动画进入的是subview.layer.presentation().bounds,手动滑动则是subView.bounds,需要根据bounds来                        计算subView在当前页面的frame
    func changeBottomSubView(subView: EWSubView, bounds: CGRect){
        ///获取view在当前页面的实际frame
        let rect = subView.convert(bounds, to: UIApplication.shared.keyWindow)
        let viewCenterX = rect.origin.x + (rect.width) / 2
        ///当View在页面中心线附近,并且处于下方时使用transform将其放大,并将中心imageView.image修改
        if viewCenterX > self.view.center.x - 20 && viewCenterX < self.view.center.x + 20 && rect.origin.y > (contentView?.center.y)! {
            if subView.tag == 0{
                subView.transform = subView.transform.scaledBy(x: 1.5, y: 1.5)
                ///使用tag标记确认其已被放大,防止重复放大,样式改变
                subView.tag = 1
                ///将放大的View提到最上方,保证展示效果
                subView.bringSubviewToFront(subView)
                self.circleView?.image = subView.imageView.image
            }
        }
        else {
            ///如果subView在变大状态
            if subView.tag == 1 {
                ///将不在条件中的View恢复原样
                subView.transform = subView.transform.scaledBy(x: 1/1.5, y: 1/1.5)
                subView.tag = 0
                contentView?.sendSubviewToBack(subView)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
class EWSubView: UIView {
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()

    init(frame: CGRect, imageName: String?) {
        super.init(frame: frame)
        self.imageView.image = UIImage(named: imageName!)
        self.addSubview(imageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func drawSubView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.imageView.frame = CGRect(x: 0, y:0 , width: self.frame.width, height: self.frame.width)
    }

}

