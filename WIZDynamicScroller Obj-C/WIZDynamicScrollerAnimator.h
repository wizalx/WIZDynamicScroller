//
//  WIZDynamicScrollerAnimator.h
//  customElementh
//
//  Created by a.vorozhishchev on 29/03/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kOnLeft,
    kOnRight
} kDirection;

@interface WIZViewsObjects : NSObject

@property (nonatomic) UIView* leftView;
@property (nonatomic) UIView* centerView;
@property (nonatomic) UIView* rightView;

-(id)initWithLeftView:(UIView*)leftView centerView:(UIView*)centerView rightView:(UIView*)rightView;

@end

@protocol WIZDynamicScrollerAnimatorDelegate <NSObject>

-(WIZViewsObjects*)leftCenterRightViewsForAnimationsForWIZDSAnimator;
-(void)WIZDSAnimatorCurrentViews:(WIZViewsObjects*)views;

@end

@interface WIZDynamicScrollerAnimator : NSObject

@property (nonatomic) id <WIZDynamicScrollerAnimatorDelegate> delegate;

-(id)initWithContentFrame:(CGRect)frame;

-(void)rotateToRightWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion;
-(void)rotateToLeftWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion;

-(void)moveToLeftWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion;
-(void)moveToRightWithPhantom:(UIView*)phantomView completion:(void (^)(BOOL finished))completion;
-(void)deleteAnimationToPoint:(CGPoint)point phantomView:(UIView*)phantomView direction:(kDirection)direction completion:(void (^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
