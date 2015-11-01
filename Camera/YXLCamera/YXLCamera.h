//
//  YXLCamera.h
//  Camera
//
//  Created by 叶星龙 on 15/11/1.
//  Copyright © 2015年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// 屏幕大小
#define kScreenBounds [[UIScreen                          mainScreen]bounds]
#define kWindowWidth  ([[UIScreen mainScreen]             bounds].size.width)
#define kWindowHeight ([[UIScreen mainScreen]             bounds].size.height)

@class YXLCamera;

@protocol YXLCameraDelegate <NSObject>
- (void)cameraImage:(UIImage *)image;
@end
@interface YXLCamera : UIViewController

@property (nonatomic, weak) id<YXLCameraDelegate>delegate;

@end
