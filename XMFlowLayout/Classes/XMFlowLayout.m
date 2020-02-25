//
//  XMFlowLayout.m
//  XMFlowlayout
//
//  Created by 梁小迷 on 2019/12/29.
//  Copyright © 2019 mifit. All rights reserved.
//

#import "XMFlowLayout.h"
#import "XMFlowLayoutItemDelegate.h"


@interface XMFlowLayout ()

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attrsArray; /// < 所有的cell的布局
@property (nonatomic, strong) NSMutableArray *columnHeights;                                  /// < 每一列的高度
@property (nonatomic, assign) NSInteger noneDoubleTime;                                       /// < 没有生成大尺寸次数
@property (nonatomic, assign) NSInteger lastDoubleIndex;                                      /// < 最后一次大尺寸的列数

- (CGFloat)columnCount;     /// < 列数
- (CGFloat)columnMargin;    /// < 列边距
- (CGFloat)rowMargin;       /// < 行边距
- (UIEdgeInsets)edgeInsets; /// < collectionView边距

@end

@implementation XMFlowLayout

#pragma mark - 默认参数
static const CGFloat JKRDefaultColumnCount = 3;                           ///< 默认列数
static const CGFloat JKRDefaultColumnMargin = 10;                         ///< 默认列边距
static const CGFloat JKRDefaultRowMargin = 10;                            ///< 默认行边距
static const UIEdgeInsets JKRDefaultUIEdgeInsets = {10, 10, 10, 10};      ///< 默认collectionView边距

- (instancetype)init {
    if (self = [super init]) {
        _automaticAlignmentPersent = 0.1f;
        _bigPersent = .0333;
    }
    return self;
}

#pragma mark - 布局计算
// collectionView 首次布局和之后重新布局的时候会调用
// 并不是每次滑动都调用，只有在数据源变化的时候才调用
- (void)prepareLayout {
    // 重写必须调用super方法
    [super prepareLayout];
    
    // reload table时候重新计算，加新数据只计算添加的
    if ([self.collectionView numberOfItemsInSection:0] == self.attrsArray.count) {
        [self.attrsArray removeAllObjects];
        [self.columnHeights removeAllObjects];
    }
    // 当列高度数组为空时，即为第一行计算，每一列的基础高度加上collection的边框的top值
    if (self.columnHeights.count <= 0) {
        for (NSInteger index = 0; index < self.columnCount; index++) {
            [self.columnHeights addObject:@(self.edgeInsets.top)];
        }
    }
    // 遍历所有的cell，计算所有cell的布局
    for (NSInteger index = self.attrsArray.count; index < [self.collectionView numberOfItemsInSection:0]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        // 计算布局属性并将结果添加到布局属性数组中
        [self.attrsArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
}

// 返回布局属性，一个UICollectionViewLayoutAttributes对象数组
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

// 计算布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    // cell的宽度
    CGFloat width = (self.collectionView.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - self.columnMargin * (self.columnCount - 1)) / self.columnCount;
    // cell的高度
    id<XMFlowLayoutItemDelegate> shop = [self.delegate modelWithIndexPath:indexPath];
    CGFloat height = shop.height / shop.width * width;
    
    // cell应该拼接的列数
    NSInteger destColumn = 0;
    // 高度最小的列数高度
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    // 获取高度最小的列数
    for (NSInteger i = 1; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    // 计算cell的x
    CGFloat xVal = self.edgeInsets.left + destColumn * (width + self.columnMargin);
    // 计算cell的y
    CGFloat yVal = minColumnHeight;
    if (yVal != self.edgeInsets.top) {
        yVal += self.rowMargin;
    }
    
    CGFloat bigPersent = self.bigPersent * 100;
    // 判断是否放大
    if (destColumn < self.columnCount - 1                               // 放大的列数不能是最后一列（最后一列方法超出屏幕）
        && _noneDoubleTime >= 1                                         // 如果前个cell有放大就不放大，防止连续出现两个放大
        && arc4random() % 100 > bigPersent                                      // 33%几率不放大
        && [self.columnHeights[destColumn] doubleValue] == [self.columnHeights[destColumn + 1] doubleValue] // 当前列的顶部和下一列的顶部要对齐
        && (_lastDoubleIndex != destColumn)                             // 最后一次放大的列不等当前列，防止出现连续两列出现放大不美观
        ) {
        _noneDoubleTime = 0;
        _lastDoubleIndex = destColumn;
        // 重定义当前cell的布局:宽度*2,高度*2
        attrs.frame = CGRectMake(xVal, yVal, width * 2 + self.columnMargin, height * 2 + self.rowMargin);
        self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
        self.columnHeights[destColumn + 1] = @(CGRectGetMaxY(attrs.frame));
    } else {
        // 正常cell的布局
        if (self.columnHeights.count > destColumn + 1 && ABS(yVal + height - [self.columnHeights[destColumn + 1] doubleValue]) < height * self.automaticAlignmentPersent) {
            // 当前cell填充后和上一列的高度偏差不超过cell最大高度的10%，就和下一列对齐
            attrs.frame = CGRectMake(xVal, yVal, width, [self.columnHeights[destColumn + 1] doubleValue] - yVal);
        } else if (destColumn >= 1 && ABS(yVal + height - [self.columnHeights[destColumn - 1] doubleValue]) < height * self.automaticAlignmentPersent) {
            // 当前cell填充后和上上列的高度偏差不超过cell最大高度的10%，就和下一列对齐
            attrs.frame = CGRectMake(xVal, yVal, width, [self.columnHeights[destColumn - 1] doubleValue] - yVal);
        } else {
            attrs.frame = CGRectMake(xVal, yVal, width, height);
        }
        // 当前cell列的高度就是当前cell的最大Y值
        self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
        _noneDoubleTime += 1;
    }
    // 返回计算获取的布局
    return attrs;
}

// 返回collectionView的ContentSize
- (CGSize)collectionViewContentSize {
    // collectionView的contentSize的高度等于所有列高度中最大的值
    CGFloat maxColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (maxColumnHeight < columnHeight) {
            maxColumnHeight = columnHeight;
        }
    }
    return CGSizeMake(0, maxColumnHeight + self.edgeInsets.bottom);
}

#pragma mark - lazy
- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInFlowLayout:)]) {
        return [self.delegate rowMarginInFlowLayout:self];
    } else {
        return JKRDefaultRowMargin;
    }
}

- (CGFloat)columnCount {
    if ([self.delegate respondsToSelector:@selector(columnCountInFlowLayout:)]) {
        return [self.delegate columnCountInFlowLayout:self];
    } else {
        return JKRDefaultColumnCount;
    }
}

- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginInFlowLayout:)]) {
        return [self.delegate columnMarginInFlowLayout:self];
    } else {
        return JKRDefaultColumnMargin;
    }
}

- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInFlowLayout:)]) {
        return [self.delegate edgeInsetsInFlowLayout:self];
    } else {
        return JKRDefaultUIEdgeInsets;
    }
}

@end
