//
//  XMFlowLayoutItemDelegate.h
//  XMFlowlayout
//
//  Created by 梁小迷 on 2019/12/29.
//  Copyright © 2019 mifit. All rights reserved.
//

#ifndef XMFlowLayoutItemDelegate_h
#define XMFlowLayoutItemDelegate_h
#import <UIKit/UIKit.h>

@protocol XMFlowLayoutItemDelegate
- (CGFloat)width;   // item 的宽
- (CGFloat)height;  // item 的高
@end
#endif /* XMFlowLayoutItemDelegate_h */
