//
//  LJYApplicationItem.h
//  ApplicationMoveDemo
//
//  Created by 林继沅 on 2020/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ApplicationItemType) {
    ApplicationItemTypeNone,
    ApplicationItemTypeDelete,
    ApplicationItemTypeSelect,
};

@class LJYApplicationItem;
@protocol LJYApplicationItemProtocol <NSObject>
@optional

- (void)applicationItemDelete:(LJYApplicationItem *_Nullable)item;

- (void)applicationItemSelect:(LJYApplicationItem *_Nullable)item;

@end

@interface LJYApplicationItem : UICollectionViewCell

@property(nonatomic, copy) NSString *imageUrl;

@property(nonatomic, copy) NSString *imageName;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, assign) BOOL cellSelect;

@property(nonatomic, assign) ApplicationItemType type;

@property(nonatomic, assign) id<LJYApplicationItemProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
