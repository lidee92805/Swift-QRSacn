//
//  LDHAlertView.h
//  LDHAlertView
//
//  Created by lidehua on 15/5/29.
//  Copyright (c) 2015年 李德华. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, LDHAlertActionStyle) {
    LDHAlertActionStyleDefault = 0,
    LDHAlertActionStyleCancel,
    LDHAlertActionStyleDestructive
} ;
@class LDHAlertAction;
@interface LDHAlertView : UIView
@property (copy, nonatomic) NSString * title;
@property (copy, nonatomic) NSString * message;
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView;
- (void)addAction:(LDHAlertAction *)action;
- (void)show;
@end
@interface LDHAlertAction : NSObject
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) LDHAlertActionStyle style;
+ (instancetype)actionWithTitle:(NSString *)title style:(LDHAlertActionStyle)style handler:(void (^)(LDHAlertAction *action))handler;
@end