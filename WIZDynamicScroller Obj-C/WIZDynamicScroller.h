//
//  WIZDynamicScroller.h
//  customElementh
//
//  Created by a.vorozhishchev on 21/03/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WIZDynamicScrollerDelegate;

@interface WIZDynamicScroller : UIView

@property (nonatomic) id <WIZDynamicScrollerDelegate> delegate;
@property (nonatomic, readonly) NSInteger currentViewsIndex;
-(void)setStartIndex:(NSInteger)startIndex;
-(void)updateScroller;

@end

@protocol WIZDynamicScrollerDelegate <NSObject>
-(NSInteger)countItemOfDynamicScroller:(WIZDynamicScroller*)scroller;
-(UIView*)dynamicScroller:(WIZDynamicScroller*)scroller viewForItemAtIndex:(NSInteger)index;

@optional
-(void)dynamicScroller:(WIZDynamicScroller*)scroller didShowItemAtIndex:(NSInteger)index;
-(void)dynamicScroller:(WIZDynamicScroller*)scroller didMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
-(void)dynamicScroller:(WIZDynamicScroller*)scroller deleteItemArIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
