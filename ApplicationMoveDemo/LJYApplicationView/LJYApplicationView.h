//
//  LJYApplicationView.h
//  ApplicationMoveDemo
//
//  Created by 林继沅 on 2020/11/16.
//

#import <UIKit/UIKit.h>
#import "LJYApplicationItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LJYApplicationView;
@protocol LJYApplicationViewProtocol <NSObject>
@optional

- (void)applicationViewUpdateItem:(LJYApplicationView *)applictionView;

@end

@interface LJYApplicationView : UIView

@property(nonatomic, copy) NSString *headerTitle;

@property(nonatomic, assign) BOOL banMove; // 禁止拖动开关

@property(nonatomic, assign) BOOL showDeleteArea; // 是否显示删除区域，默认不显示

@property(nonatomic, assign) BOOL lastItemCanMove;

@property(nonatomic, assign) ApplicationItemType type;

@property(nonatomic, strong) NSArray *appList;

@property(nonatomic, assign) id<LJYApplicationViewProtocol>delegate;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
