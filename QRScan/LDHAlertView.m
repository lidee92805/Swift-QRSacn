//
//  LDHAlertView.m
//  LDHAlertView
//
//  Created by lidehua on 15/5/29.
//  Copyright (c) 2015年 李德华. All rights reserved.
//

#import "LDHAlertView.h"
#import <objc/runtime.h>
typedef void(^handlerBlock)(LDHAlertAction *);
@interface LDHAlertView()
@property (strong, nonatomic) NSMutableArray * actionArray;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * subTitleLabel;
@property (strong, nonatomic) UIView * customView;
@property (assign, nonatomic) CGFloat contentHeight;
@property (strong, nonatomic) UIView * buttonView;
@property (strong, nonatomic) UIWindow * window;
@end
#define kLeftEdge 15
#define kTitleLabelHeight 48
#define kAlertViewWidth ([UIScreen mainScreen].bounds.size.width - 2 * kLeftEdge)
@implementation LDHAlertView
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView {
    LDHAlertView * alertView = [[LDHAlertView alloc] initWithTitle:title message:message costomView:customView];
    return alertView;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message costomView:(UIView *)customView {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        _actionArray = [NSMutableArray array];
        _title = title;
        _message = message;
        _customView = customView;
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews {
    if (_title) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAlertViewWidth, kTitleLabelHeight)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        _contentHeight += kTitleLabelHeight;
        [self addLineFromPoint:CGPointMake(0, _contentHeight) ToPoint:CGPointMake(kAlertViewWidth, _contentHeight)];
    }
    if (_message) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _contentHeight, kAlertViewWidth, 0)];
        _subTitleLabel.text = _message;
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        _subTitleLabel.textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        CGRect subTitleRect = _subTitleLabel.frame;
        subTitleRect.size.height = [_subTitleLabel sizeThatFits:CGSizeMake(kAlertViewWidth, MAXFLOAT)].height + 10;
        _subTitleLabel.frame = subTitleRect;
        [self addSubview:_subTitleLabel];
        _contentHeight += subTitleRect.size.height;
    }
    if (_customView) {
        CGRect customViewRect = _customView.frame;
        if (CGRectEqualToRect(CGRectZero, customViewRect) == true) {
            customViewRect = CGRectMake(0, 0, kAlertViewWidth, 44);
        }
        customViewRect.origin.y = _contentHeight;
        _customView.frame = customViewRect;
        [self addSubview:_customView];
        _contentHeight += customViewRect.size.height;
    }
    CGRect alertRect = self.frame;
    alertRect = CGRectMake(kLeftEdge, (CGRectGetHeight([UIScreen mainScreen].bounds) - _contentHeight)/2, kAlertViewWidth, _contentHeight);
    self.frame = alertRect;
}
- (void)addAction:(LDHAlertAction *)action {
    if ([action isKindOfClass:[LDHAlertAction class]]) {
        [_actionArray addObject:action];
    }
}
- (void)setupButtonView {
    if (!_buttonView) {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, _contentHeight, kAlertViewWidth, 0)];
        [self addSubview:_buttonView];
    }
    [_buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttonView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _buttonView.frame = CGRectMake(0, _contentHeight, kAlertViewWidth, 0);
    [_actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton * btn = [self createButtonWithAction:obj];
        if (_actionArray.count == 2) {
            btn.frame = CGRectMake(kAlertViewWidth / 2 * idx, 0, kAlertViewWidth / 2, 49);
            CGRect btnRect = _buttonView.frame;
            btnRect.size.height = 49;
            _buttonView.frame = btnRect;
            [self addLineFromPoint:CGPointMake(kAlertViewWidth/2, _contentHeight) ToPoint:CGPointMake(kAlertViewWidth/2, _contentHeight + 49)];
        } else {
            btn.frame = CGRectMake(0, 49 * idx, kAlertViewWidth, 49);
            CGRect btnRect = _buttonView.frame;
            btnRect.size.height += 49;
            _buttonView.frame = btnRect;
        }
        [self addLineFromPoint:CGPointMake(0, _contentHeight + 49 * idx) ToPoint:CGPointMake(kAlertViewWidth, _contentHeight + 49 * idx)];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:btn];
    }];
    CGRect alertRect = self.frame;
    alertRect.size.height = CGRectGetHeight(_buttonView.frame) + _contentHeight;
    alertRect.origin.y = (CGRectGetHeight([UIScreen mainScreen].bounds) - alertRect.size.height)/2;
    self.frame = alertRect;
}
- (void)show {
    [self setupButtonView];
     _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.windowLevel = UIWindowLevelNormal;
    _window.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    _window.alpha = 0;
    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
    [_window addSubview:self];
    [_window makeKeyAndVisible];
    [UIView animateWithDuration:0.3 animations:^{
        _window.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }];
}
- (void)btnClick:(UIButton *)btn {
    LDHAlertAction * action = objc_getAssociatedObject(btn, @"buttonAction");
    handlerBlock handle = objc_getAssociatedObject(action, @"actionHandler");
    handle(action);
    _window.hidden = YES;
    [_window resignKeyWindow];
    [_window removeFromSuperview];
    _window = nil;
}
- (UIButton *)createButtonWithAction:(LDHAlertAction *)action {
    UIButton * btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:action.title forState:UIControlStateNormal];
    switch (action.style) {
        case LDHAlertActionStyleDefault: {
            [btn setTitleColor:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1] forState:UIControlStateNormal];
        }
            break;
        case LDHAlertActionStyleCancel: {
            [btn setTitleColor:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1] forState:UIControlStateNormal];
        }
            break;
        case LDHAlertActionStyleDestructive: {
            [btn setTitleColor:[UIColor colorWithRed:228.0/255.0 green:27.0/255.0 blue:70.0/255.0 alpha:1] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    objc_setAssociatedObject(btn, @"buttonAction", action, OBJC_ASSOCIATION_RETAIN);
    return btn;
}
- (void)addLineFromPoint:(CGPoint)startPoint ToPoint:(CGPoint)toPoint {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, toPoint.x, toPoint.y);
    shapeLayer.path = path;
    [shapeLayer setStrokeColor:[UIColor colorWithRed:221/255.f green:221/255.f blue:221/255.f alpha:1].CGColor];
    [shapeLayer setLineWidth:0.5];
    [self.layer addSublayer:shapeLayer];
    CGPathRelease(path);
}
@end
@interface LDHAlertAction()
@property (readwrite) NSString *title;
@property (readwrite , assign) LDHAlertActionStyle style;
@end
@implementation LDHAlertAction
+ (instancetype)actionWithTitle:(NSString *)title style:(LDHAlertActionStyle)style handler:(void (^)(LDHAlertAction *))handler {
    LDHAlertAction * action = [[LDHAlertAction alloc] init];
    action.title = title;
    action.style = style;
    objc_setAssociatedObject(action, @"actionHandler", handler, OBJC_ASSOCIATION_COPY);
    return action;
}
@end