//
//  WIZDynamicScrollerAnimator.m
//  customElementh
//
//  Created by a.vorozhishchev on 29/03/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import "WIZDynamicScrollerAnimator.h"

@implementation WIZViewsObjects

-(id)initWithLeftView:(UIView*)leftView centerView:(UIView*)centerView rightView:(UIView*)rightView
{
    self = [super init];
    self.leftView = leftView;
    self.centerView = centerView;
    self.rightView = rightView;
    
    return self;
}

@end

@interface WIZDynamicScrollerAnimator()
{
    float mainWidth;
    float mainHeight;
    float widthLRViews;
    float heightLRViews;
    float yLRViews;
}

@property BOOL animationNow;


@end

@implementation WIZDynamicScrollerAnimator

-(id)initWithContentFrame:(CGRect)frame
{
    self = [super init];

    //calculate main values
    mainWidth = frame.size.width;
    mainHeight = frame.size.height;
    widthLRViews = mainWidth * 0.49;
    heightLRViews = mainHeight * 0.56;
    yLRViews = (mainHeight - heightLRViews) / 2;
    
    return self;
}

-(CGRect)phantomRightRect
{
    float x = mainWidth * 0.95 + 2 * widthLRViews;
    return CGRectMake(x, yLRViews, widthLRViews, heightLRViews);
}

-(CGRect)phantomLeftRect
{
    float x = mainWidth * 0.05 - 2 * widthLRViews;
    return CGRectMake(x, yLRViews, widthLRViews, heightLRViews);
}

-(CGRect)calculateLeftRect
{
    float x = mainWidth * 0.1 - widthLRViews;
    return CGRectMake(x, yLRViews, widthLRViews, heightLRViews);
}

-(CGRect)calculateRightRect
{
    float x = mainWidth * 0.9;
    return CGRectMake(x, yLRViews, widthLRViews, heightLRViews);
}

-(CGRect)calculateCenterRect
{
    float x = mainWidth * 0.15;
    float y = mainHeight * 0.1;
    float width = mainWidth * 0.7;
    float height = mainHeight * 0.8;
    
    return CGRectMake(x, y, width, height);
}

#pragma mark - swipe animation

-(void)rotateToRightWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion
{
    if (self.animationNow)
    {
        if (phantomView)
            [phantomView removeFromSuperview];
        return;
    }
    
    self.animationNow = YES;
    
    if (phantomView) {
        phantomView.transform = CGAffineTransformScale(phantomView.transform, 0.7, 0.7);
        phantomView.frame = [self phantomRightRect];
    }

    WIZViewsObjects *views = [_delegate leftCenterRightViewsForAnimationsForWIZDSAnimator];
    __block UIView *leftView = views.leftView;
    __block UIView *centerView = views.centerView;
    __block UIView *rightView = views.rightView;
    [UIView animateWithDuration:0.5 animations:^{
        leftView.frame = [self phantomLeftRect];
        centerView.transform = CGAffineTransformScale(centerView.transform, 0.7, 0.7);
        centerView.frame = [self calculateLeftRect];
        rightView.transform = CGAffineTransformScale(rightView.transform, 1.4, 1.4);
        rightView.frame = [self calculateCenterRect];
        if (phantomView)
            phantomView.frame = [self calculateRightRect];
    } completion:^(BOOL finished) {
        if (finished) {
            [leftView removeFromSuperview];
            leftView = nil;
            leftView = centerView;
            centerView = rightView;
            rightView = phantomView;
            
            [self.delegate WIZDSAnimatorCurrentViews:[[WIZViewsObjects alloc] initWithLeftView:leftView centerView:centerView rightView:rightView]];
            self.animationNow = NO;
            
            leftView.userInteractionEnabled = NO;
            centerView.userInteractionEnabled = YES;
            rightView.userInteractionEnabled = NO;
            
            completion(YES);
        }
    }];
    
}


-(void)rotateToLeftWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion;
{
    if (self.animationNow)
    {
        if (phantomView)
            [phantomView removeFromSuperview];
        return;
    }
    
    self.animationNow = YES;
    
    if (phantomView) {
        phantomView.transform = CGAffineTransformScale(phantomView.transform, 0.7, 0.7);
        phantomView.frame = [self phantomLeftRect];
    }
    
    WIZViewsObjects *views = [_delegate leftCenterRightViewsForAnimationsForWIZDSAnimator];
    __block UIView *leftView = views.leftView;
    __block UIView *centerView = views.centerView;
    __block UIView *rightView = views.rightView;
    [UIView animateWithDuration:0.5 animations:^{
        rightView.frame = [self phantomRightRect];
        centerView.transform = CGAffineTransformScale(centerView.transform, 0.7, 0.7);
        centerView.frame = [self calculateRightRect];
        leftView.transform = CGAffineTransformScale(leftView.transform, 1.4, 1.4);
        leftView.frame = [self calculateCenterRect];
        if (phantomView)
            phantomView.frame = [self calculateLeftRect];
    } completion:^(BOOL finished) {
        if (finished) {
            [rightView removeFromSuperview];
            rightView = nil;
            rightView = centerView;
            centerView = leftView;
            leftView = phantomView;
            
             [self.delegate WIZDSAnimatorCurrentViews:[[WIZViewsObjects alloc] initWithLeftView:leftView centerView:centerView rightView:rightView]];
            self.animationNow = NO;
            
            leftView.userInteractionEnabled = NO;
            centerView.userInteractionEnabled = YES;
            rightView.userInteractionEnabled = NO;
            
            completion(YES);
        }
    }];
}

#pragma mark - move animation

-(void)moveToLeftWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion
{
    if (self.animationNow)
    {
        if (phantomView)
            [phantomView removeFromSuperview];
        return;
    }
    
    self.animationNow = YES;
    
    if (phantomView) {
        phantomView.transform = CGAffineTransformScale(phantomView.transform, 0.7, 0.7);
        phantomView.frame = [self phantomLeftRect];
    }
    
    WIZViewsObjects *views = [_delegate leftCenterRightViewsForAnimationsForWIZDSAnimator];
    __block UIView *leftView = views.leftView;
    __block UIView *centerView = views.centerView;
    __block UIView *rightView = views.rightView;
    
    [UIView animateWithDuration:0.3 animations:^{
        //go animation
        rightView.frame = [self phantomRightRect];
        leftView.frame = [self calculateRightRect];
        
        if (phantomView)
            phantomView.frame = [self calculateLeftRect];
        
    } completion:^(BOOL finished) {
        if (finished) {
            //clear
            [rightView removeFromSuperview];
            rightView = nil;
            rightView = leftView;
            leftView = phantomView;
            leftView.alpha = 0.60;
            rightView.alpha = 0.60;
            
            [self.delegate WIZDSAnimatorCurrentViews:[[WIZViewsObjects alloc] initWithLeftView:leftView centerView:centerView rightView:rightView]];
            
            completion(YES);
            
            self.animationNow = NO;
        }
    }];
    
}

-(void)moveToRightWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion
{
    if (self.animationNow)
    {
        if (phantomView)
            [phantomView removeFromSuperview];
        return;
    }
    
    self.animationNow = YES;
    
    if (phantomView) {
        phantomView.transform = CGAffineTransformScale(phantomView.transform, 0.7, 0.7);
        phantomView.frame = [self phantomRightRect];
    }
    
    WIZViewsObjects *views = [_delegate leftCenterRightViewsForAnimationsForWIZDSAnimator];
    __block UIView *leftView = views.leftView;
    __block UIView *centerView = views.centerView;
    __block UIView *rightView = views.rightView;
    
    [UIView animateWithDuration:0.3 animations:^{
        //go animation
        rightView.frame = [self calculateLeftRect];
        leftView.frame = [self phantomLeftRect];
        
        if (phantomView)
            phantomView.frame = [self calculateRightRect];
        
    } completion:^(BOOL finished) {
        if (finished) {
            //clear
            [leftView removeFromSuperview];
            leftView = nil;
            leftView = rightView;
            rightView = phantomView;
            leftView.alpha = 0.60;
            rightView.alpha = 0.60;
            
            [self.delegate WIZDSAnimatorCurrentViews:[[WIZViewsObjects alloc] initWithLeftView:leftView centerView:centerView rightView:rightView]];
            
            completion(YES);
            
            self.animationNow = NO;
        }
    }];
}


-(void)deleteAnimationToPoint:(CGPoint)point phantomView:(UIView*)phantomView direction:(kDirection)direction completion:(nonnull void (^)(BOOL))completion
{
    phantomView.transform = CGAffineTransformScale(phantomView.transform, 0.7, 0.7);
    if (direction == kOnRight)
        phantomView.frame = [self phantomRightRect];
   else
       phantomView.frame = [self phantomLeftRect];
    
    WIZViewsObjects *views = [_delegate leftCenterRightViewsForAnimationsForWIZDSAnimator];
    __block UIView *leftView = views.leftView;
    __block UIView *centerView = views.centerView;
    __block UIView *rightView = views.rightView;
    
    [UIView animateWithDuration:0.3 animations:^{
        centerView.frame = CGRectMake(point.x, point.y, 1, 1);
        if (direction == kOnRight) {
            rightView.transform = CGAffineTransformScale(rightView.transform, 1.4, 1.4);
            rightView.frame = [self calculateCenterRect];
            if (phantomView)
                phantomView.frame = [self calculateRightRect];
        } else {
            leftView.transform = CGAffineTransformScale(leftView.transform, 1.4, 1.4);
            leftView.frame = [self calculateCenterRect];
            if (phantomView)
                phantomView.frame = [self calculateLeftRect];
        }
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [centerView removeFromSuperview];
            //clear
            if (direction == kOnRight) {
                centerView = rightView;
                rightView = phantomView;
            } else {
                centerView = leftView;
                leftView = phantomView;
            }
            
            centerView.alpha = 1.0;
            centerView.layer.zPosition = 1000;
            leftView.alpha = 0.6;
            rightView.alpha = 0.6;
            
            leftView.userInteractionEnabled = NO;
            centerView.userInteractionEnabled = YES;
            rightView.userInteractionEnabled = NO;
            
            [self.delegate WIZDSAnimatorCurrentViews:[[WIZViewsObjects alloc] initWithLeftView:leftView centerView:centerView rightView:rightView]];
            
            completion(YES);
            
            self.animationNow = NO;
        }
    }];
    
}

@end
