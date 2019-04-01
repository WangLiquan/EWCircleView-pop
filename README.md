# EWCircleView-pop
[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

Swift轮转动画

# 实现效果: 
静止时:子view对称排列,允许动态添加,0~24个都能较好的显示.

旋转时:中心view不动,长按中心View时,子view旋转,最下方子view变大突出,并让中心View展示子View.image

# 实现思路:

所有的控件全部加到一个大的背景view上,本质上旋转的是这个背景view,在旋转背景view的同时,让它所有的子控件反向旋转,就实现了现在这种效果.

使用pop框架添加旋转动画.给中心button一个.touchDown手势事件添加动画,再添加一个[.touchUpInside, .touchDragExit]手势事件来移除动画.

之前有尝试使用transform,CABasicAnimation,UIView.animation三种动画方式,但都无法完美实现,所以使用了faceBook提供的pop框架.

最下方的view变大是通过CADisplayLink监听子view.layer.presention().bounds,来获取子View在当前页面的实际frame.x,当它处于一个范围,并且frame.y小于中心view.frame.y的时候.修改它的transform,来使其变大,并且修改它的tag来标记它已经属于变大状态,当它frame.x超出了预定范围,使其还原.

# 实现方式:

1. 添加背景透明view,中心圆圈view.

2. 添加周围旋转子view.

3. 添加旋转方法.


![效果图预览](https://github.com/WangLiquan/EWCircleView-pop/raw/master/image/demonstration.gif)

# 另:
也有使用transform,通过获取touchMove手势来旋转的类似效果.项目为[CircleView](https://github.com/WangLiquan/CircleView),可供参考.

