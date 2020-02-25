//
//  XMFlowLayout.h
//  XMFlowlayout
//
//  Created by 梁小迷 on 2019/12/29.
//  Copyright © 2019 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@class XMFlowLayout;
@protocol XMFlowLayoutItemDelegate;

/*
 * 只有一个section的瀑布流布局，可放大图片、自动对齐差距不到10%的cell
 *
 */
@protocol XMFlowLayoutDelegate <NSObject>

@optional
/// 列数
- (CGFloat)columnCountInFlowLayout:(XMFlowLayout *)flowLayout;

/// 列间距
- (CGFloat)columnMarginInFlowLayout:(XMFlowLayout *)flowLayout;

/// 行间距
- (CGFloat)rowMarginInFlowLayout:(XMFlowLayout *)flowLayout;

/// collectionView边距
- (UIEdgeInsets)edgeInsetsInFlowLayout:(XMFlowLayout *)flowLayout;

/// 返回图片模型
- (id<XMFlowLayoutItemDelegate>)modelWithIndexPath:(NSIndexPath *)indexPath;

@end


/*
 * 刷新数据只刷新新加的
 */
@interface XMFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<XMFlowLayoutDelegate> delegate;

/// 自动对齐差距百分比，与相邻相差不大时候自动对齐百分比差。默认0.1
@property (nonatomic, assign) CGFloat automaticAlignmentPersent;

/// 放大概率，可放大时候放大概率，默认1/3
@property (nonatomic, assign) CGFloat bigPersent;
@end

NS_ASSUME_NONNULL_END
