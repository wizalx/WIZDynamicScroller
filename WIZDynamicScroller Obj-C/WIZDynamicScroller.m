//
//  WIZDynamicScroller.m
//  customElementh
//
//  Created by a.vorozhishchev on 21/03/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import "WIZDynamicScroller.h"
#import "WIZDynamicScrollerAnimator.h"
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface WIZDynamicScroller() <WIZDynamicScrollerAnimatorDelegate>
{
    float mainWidth;
    float mainHeight;
    float widthLRViews;
    float heightLRViews;
    float yLRViews;
    
    NSInteger count;
    
    //animation property
    BOOL longPressTapped;
    BOOL moving;
    CGPoint startLocation;
    
    CGPoint firstTouchPoint;
    
    NSInteger indexBeforeMoving;
}

@property (nonatomic) UIView *centerView;
@property (nonatomic) UIView *leftView;
@property (nonatomic) UIView *rightView;

@property (nonatomic) NSInteger currentIndex;

@property UIImageView *deleteBasket;

@property WIZDynamicScrollerAnimator *animator;

@end

@implementation WIZDynamicScroller


#pragma mark - init

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                (int64_t)(0.01 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self customInit];
        });
    }
    
    return self;
}

-(void)customInit
{
    //calculate main values
    mainWidth = self.frame.size.width;
    mainHeight = self.frame.size.height;
    widthLRViews = mainWidth * 0.49;
    heightLRViews = mainHeight * 0.56;
    yLRViews = (mainHeight - heightLRViews) / 2;
    
    //add swipes
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightGesture:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightGesture];
    
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGesture:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftGesture];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    longGesture.minimumPressDuration = 1.0;
    [self addGestureRecognizer:longGesture];
    
    
    //set default values
    if (!(self.currentIndex > 0))
        self.currentIndex = 0;
    
    longPressTapped = NO;
    indexBeforeMoving = -7;
    
    self.animator = [[WIZDynamicScrollerAnimator alloc] initWithContentFrame:self.frame];
    self.animator.delegate = self;
    
    if (_delegate) {
        [self setDelegate:_delegate];
    }
}

-(void)setDelegate:(id<WIZDynamicScrollerDelegate>)delegate
{
    _delegate = delegate;
    if (mainWidth) {
        //set default value
        count = [_delegate countItemOfDynamicScroller:self];
        
        //add views
        
        if (_leftView)
            [_leftView removeFromSuperview];
        if (_centerView)
            [_centerView removeFromSuperview];
        if (_rightView)
            [_rightView removeFromSuperview];
        
        if (_currentIndex > 0 && _currentIndex-1 < count) {
            _leftView = [_delegate dynamicScroller:self viewForItemAtIndex:_currentIndex-1];
            self.leftView.transform = CGAffineTransformScale(self.leftView.transform, 0.7, 0.7);
            _leftView.frame = [self calculateLeftRect];
            [self addSubview:_leftView];
        }
        
        if (_currentIndex < count) {
            _centerView = [_delegate dynamicScroller:self viewForItemAtIndex:_currentIndex];
            _centerView.frame = [self calculateCenterRect];
            [self addSubview:_centerView];
            if ([self.delegate respondsToSelector:@selector(dynamicScroller:didShowItemAtIndex:)]) {
                [self.delegate dynamicScroller:self didShowItemAtIndex:self.currentIndex];
            }
            
        }
        
        if (count>1 && _currentIndex+1 < count) {
            _rightView = [_delegate dynamicScroller:self viewForItemAtIndex:_currentIndex+1];
            self.rightView.transform = CGAffineTransformScale(self.rightView.transform, 0.7, 0.7);
            _rightView.frame = [self calculateRightRect];
            [self addSubview:_rightView];
        }
    }
}

-(void)updateScroller
{
    if (_delegate)
        [self setDelegate:_delegate];
    
}

#pragma mark - calculate rects

-(CGRect)calculateCenterRect
{
    float x = mainWidth * 0.15;
    float y = mainHeight * 0.1;
    float width = mainWidth * 0.7;
    float height = mainHeight * 0.8;
    
    return CGRectMake(x, y, width, height);
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

#pragma mark - gestures

-(void)rightGesture:(UIGestureRecognizer*)gr
{
    if (!longPressTapped && self.currentIndex != 0) {
        UIView* phantomView = nil;
        if (self.currentIndex-1 > 0) {
            phantomView = [_delegate dynamicScroller:self viewForItemAtIndex:self.currentIndex-2];
            [self addSubview:phantomView];
        }
        [self.animator rotateToLeftWithPhantom:phantomView completion:^(BOOL finished) {
            self.currentIndex--;
            if ([self.delegate respondsToSelector:@selector(dynamicScroller:didShowItemAtIndex:)]) {
                [self.delegate dynamicScroller:self didShowItemAtIndex:self.currentIndex];
            }
        }];
        
    }
}

-(void)leftGesture:(UIGestureRecognizer*)gr
{
    if (!longPressTapped && self.currentIndex < count-1) {
        UIView* phantomView = nil;
        if (self.currentIndex+1 < count-1) {
            phantomView = [_delegate dynamicScroller:self viewForItemAtIndex:self.currentIndex+2];
            [self addSubview:phantomView];
        }
        [self.animator rotateToRightWithPhantom:phantomView completion:^(BOOL finished) {
            self.currentIndex++;
            if ([self.delegate respondsToSelector:@selector(dynamicScroller:didShowItemAtIndex:)]) {
                [self.delegate dynamicScroller:self didShowItemAtIndex:self.currentIndex];
            }
        }];
        
    }
}

#pragma mark - edit gesture

-(void)longGesture:(UILongPressGestureRecognizer*)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        if (!longPressTapped) {
            [self shakeAnimation];
            _leftView.alpha = 0.60;
            _rightView.alpha = 0.60;
            _centerView.layer.zPosition = 1000;
            _centerView.multipleTouchEnabled = YES;
            longPressTapped = YES;
            
            self.deleteBasket = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 25, self.bounds.origin.y - 65, 50, 50)];
            [self.deleteBasket setImage:[UIImage imageNamed:@"deleteBasket.png"]];
            [self addSubview:self.deleteBasket];
            
        } else if (!moving) {
            [_centerView.layer removeAllAnimations];
            _leftView.alpha = 1;
            _rightView.alpha = 1;
            
            longPressTapped = NO;
            
            [self.deleteBasket removeFromSuperview];
        }
        
    }
}

-(void)shakeAnimation
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    [shake setDuration:2];
    [shake setRepeatCount:100];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSNumber numberWithFloat:DEGREES_TO_RADIANS(0.0)]];
    [shake setToValue:[NSNumber numberWithFloat:DEGREES_TO_RADIANS(-5.0)]];
    [_centerView.layer addAnimation:shake forKey:@"transform.rotation.z"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (longPressTapped) {
        CGPoint pt = [[touches anyObject]locationInView:_centerView];
        startLocation = pt;
        
        UITouch* bTouch = [touches anyObject];
        firstTouchPoint = [bTouch locationInView:self];
        //        if ([bTouch.view isEqual:_centerView] || [bTouch.view isDescendantOfView:_centerView])
        //        {
        indexBeforeMoving = _currentIndex;
        //        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (longPressTapped) {
        UITouch* mTouch = [touches anyObject];
        CGPoint cp = [mTouch locationInView:self];
        if (cp.x > _deleteBasket.frame.origin.x && cp.x < _deleteBasket.frame.origin.x+_deleteBasket.frame.size.width && cp.y > _deleteBasket.frame.origin.y && cp.y < _deleteBasket.frame.origin.y + _deleteBasket.frame.size.height)
        {
            [self deleteAnimation];
        } else {
            moving = NO;
            _centerView.frame = [self calculateCenterRect];
            if (indexBeforeMoving == _currentIndex)
                indexBeforeMoving = -7;
            
            if (indexBeforeMoving != -7) {
                if ([self.delegate respondsToSelector:@selector(dynamicScroller:didMoveFromIndex:toIndex:)])
                    [self.delegate dynamicScroller:self didMoveFromIndex:indexBeforeMoving toIndex:self.currentIndex];
                
            }
            
            [self shakeAnimation];
        }
    }
    
    indexBeforeMoving = -7;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (longPressTapped) {
        moving = YES;
        UITouch* mTouch = [touches anyObject];
        CGPoint cp = [mTouch locationInView:self];
        [_centerView setCenter:CGPointMake(cp.x, cp.y)];
        if (cp.x >= _rightView.frame.origin.x && _rightView) {
            [self movedRightAnimation];
        } else if (cp.x < _leftView.frame.origin.x+_leftView.frame.size.width && _leftView)
        {
            [self movedLeftAnimation];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)movedRightAnimation
{
    if (_currentIndex == count-1)
        return;
    
    //create phantom view
    UIView *phantomView = nil;
    if (self.currentIndex+1 < count-1) {
        phantomView = [_delegate dynamicScroller:self viewForItemAtIndex:self.currentIndex+2];
        [self addSubview:phantomView];
    }
    
    [self.animator moveToRightWithPhantom:phantomView completion:^(BOOL finished) {
        self.currentIndex++;
    }];
}

-(void)movedLeftAnimation
{
    if (_currentIndex == 0)
        return;
    
    //create phantom view
    UIView *phantomView = nil;
    if (self.currentIndex-1 > 0) {
        phantomView = [_delegate dynamicScroller:self viewForItemAtIndex:self.currentIndex-2];
        [self addSubview:phantomView];
    }
    
    [self.animator moveToLeftWithPhantom:phantomView completion:^(BOOL finished) {
        self.currentIndex--;
    }];
}

-(void)deleteAnimation
{
    kDirection directionAnimation = kOnRight;
    
    //create phantom view
    UIView *phantomView = nil;
    if (self.currentIndex+2 < count-1) {
        phantomView = [_delegate dynamicScroller:self viewForItemAtIndex:self.currentIndex+2];
        [self addSubview:phantomView];
        directionAnimation = kOnRight;
    }
    
    if (self.currentIndex == count-1) {
        phantomView = [_delegate dynamicScroller:self viewForItemAtIndex:self.currentIndex-2];
        [self addSubview:phantomView];
        directionAnimation = kOnLeft;
    }
    
    [self.animator deleteAnimationToPoint:self.deleteBasket.center phantomView:phantomView direction:directionAnimation completion:^(BOOL finished) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self shakeAnimation];
        });
        if ([self.delegate respondsToSelector:@selector(dynamicScroller:deleteItemArIndex:)])
            [self.delegate dynamicScroller:self deleteItemArIndex:self.currentIndex];
        
        if (self.currentIndex == self->count-1)
            self.currentIndex--;
    }];
    
}

#pragma mark - setters and getters

-(void)setStartIndex:(NSInteger)startIndex
{
    NSLog(@"startIndex = %li",(long)startIndex);
    self.currentIndex = startIndex;
    if (_delegate)
        [self setDelegate:_delegate];
}

-(NSInteger)currentViewsIndex
{
    return self.currentIndex;
}

#pragma mark - WIZDSAnimatorDelegate

-(WIZViewsObjects*)leftCenterRightViewsForAnimationsForWIZDSAnimator
{
    return [[WIZViewsObjects alloc] initWithLeftView:_leftView centerView:_centerView rightView:_rightView];
}

-(void)WIZDSAnimatorCurrentViews:(WIZViewsObjects*)views
{
    _leftView = views.leftView;
    _centerView = views.centerView;
    _rightView = views.rightView;
}

@end
