//
//  LJYApplicationView.m
//  ApplicationMoveDemo
//
//  Created by 林继沅 on 2020/11/16.
//

#import "LJYApplicationView.h"
#import "LJYApplicationHeader.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kStatusBar_height (SCREEN_HEIGHT >= 812?44:20)

//菜单列数
static NSInteger ColumnNumber = 4;

static CGFloat cellHeight = 80.0f;

static CGFloat headerHeight = 50.0f;

@interface LJYApplicationView ()<UICollectionViewDelegate,UICollectionViewDataSource,LJYApplicationItemProtocol>{
    BOOL _isDidUpdateItemLocation;   // 拖动时，是否item于其他item换位置
}

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) LJYApplicationItem *dragingItem;

@property(nonatomic, strong) NSIndexPath *dragingIndexPath;

@property(nonatomic, strong) NSIndexPath *targetIndexPath;

@property(nonatomic, strong) NSMutableArray *appArr;

@property(nonatomic, strong) UIButton *deleteArea; // 删除区域

@end

@implementation LJYApplicationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lastItemCanMove = NO;
        _banMove = NO;
        _showDeleteArea = NO;
        _type = ApplicationItemTypeNone;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.appArr = [NSMutableArray array];
    self.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.headerReferenceSize = CGSizeMake(self.bounds.size.width, headerHeight);

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[LJYApplicationItem class] forCellWithReuseIdentifier:@"LJYApplicationItem"];
    [self.collectionView registerClass:[LJYApplicationHeader class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LJYApplicationHeader"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    [self addSubview:self.collectionView];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    longPress.minimumPressDuration = 0.3f;
    [self.collectionView addGestureRecognizer:longPress];
    
    CGFloat cellWidth = self.bounds.size.width/ColumnNumber;
    self.dragingItem = [[LJYApplicationItem alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
    self.dragingItem.hidden = true;
    [[UIApplication sharedApplication].keyWindow addSubview:self.dragingItem];

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGFloat H = (kStatusBar_height > 20) ? 88 : 54;
    self.deleteArea = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - H, SCREEN_WIDTH, H)];
    self.deleteArea.backgroundColor = [UIColor redColor];
    [self.deleteArea setTitle:@"松开即可移除" forState:(UIControlStateNormal)];
    [self.deleteArea setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.deleteArea.titleLabel.font = [UIFont systemFontOfSize:18];
    self.deleteArea.hidden = true;
    [keyWindow addSubview:self.deleteArea];
}

#pragma mark -
#pragma mark LongPressMethod
-(void)longPressMethod:(UILongPressGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self.collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd:point];
            break;
        default:
            break;
    }
}

//拖拽开始 找到被拖拽的item
-(void)dragBegin:(CGPoint)point{
    if (_banMove) {return;}
    self.dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!self.dragingIndexPath) {return;}
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.dragingItem];
    LJYApplicationItem *item = (LJYApplicationItem *)[self.collectionView cellForItemAtIndexPath:self.dragingIndexPath];
    // 将是否移动位置标识重新赋值为false
    _isDidUpdateItemLocation = false;
    //更新被拖拽的item
    self.dragingItem.hidden = false;
    if (_showDeleteArea) {
        self.deleteArea.hidden = false;
    }
    item.hidden = YES;
    self.dragingItem.frame = [item convertRect:item.bounds toView:[UIApplication sharedApplication].keyWindow];
    self.dragingItem.title = item.title;
    self.dragingItem.imageUrl = @"icon";
    self.dragingItem.backgroundColor = [UIColor redColor];
    [self.dragingItem setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
}

//正在被拖拽、、、
-(void)dragChanged:(CGPoint)point{
    if (_banMove) {return;}
    if (!self.dragingIndexPath) {return;}
    self.dragingItem.center = [self.collectionView convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    self.targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到self.targetIndexPath则不交换位置
    if (self.dragingIndexPath && self.targetIndexPath) {
        //更新数据源
        [self rearrangeInUseTitles];
        //更新item位置
        [self.collectionView moveItemAtIndexPath:self.dragingIndexPath toIndexPath:self.targetIndexPath];
        self.dragingIndexPath = self.targetIndexPath;
        _isDidUpdateItemLocation = true;
    }
}

//拖拽结束
-(void)dragEnd:(CGPoint)point{
    if (_banMove) {return;}
    if (!self.dragingIndexPath) {return;}
    
    CGPoint endPoint = [self.collectionView convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    BOOL isDelete = (endPoint.y >= self.deleteArea.frame.origin.y);

    LJYApplicationItem *item = (LJYApplicationItem *)[self.collectionView cellForItemAtIndexPath:self.dragingIndexPath];
    [self.dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    item.hidden = NO;
    self.dragingItem.hidden = true;
    self.deleteArea.hidden = true;
    if (_showDeleteArea && isDelete) {
        [self applicationItemDelete:item];
    }else {
        if (_isDidUpdateItemLocation && [self.delegate respondsToSelector:@selector(applicationViewUpdateItem:)]) {
            [self.delegate applicationViewUpdateItem:self];
        }
    }
}

#pragma mark -
#pragma mark 辅助方法

//获取被拖动IndexPath的方法
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point{
    NSIndexPath* dragIndexPath = nil;
    //最后剩一个怎不可以排序
    if ([self.collectionView numberOfItemsInSection:0] == 1) {return dragIndexPath;}
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        //在上半部分中找出相对应的Item
        if (CGRectContainsPoint([self.collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            // 如果lastItemCanMove为NO，则最后一组最后一个item不能移动
            if (_lastItemCanMove) {
                dragIndexPath = indexPath;
            }else {
                if ((indexPath.row != (self.appArr.count - 1))) {
                    dragIndexPath = indexPath;
                }
            }
            break;
        }
    }
    return dragIndexPath;
}

//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:self.dragingIndexPath]) {continue;}
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([self.collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (_lastItemCanMove) {
                targetIndexPath = indexPath;
            }else {
                if ((indexPath.row != (self.appArr.count - 1))) {
                    targetIndexPath = indexPath;
                }
            }
        }
    }
    return targetIndexPath;
}

#pragma mark -
#pragma mark CollectionViewDelegate&DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.appArr.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LJYApplicationHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LJYApplicationHeader" forIndexPath:indexPath];
    headerView.title = self.headerTitle;
    return headerView;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"LJYApplicationItem";
    LJYApplicationItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    item.delegate = self;
    item.type = self.type;
    item.title = self.appArr[indexPath.row];
    item.imageUrl = @"icon";
    return item;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = ColumnNumber;
    CGFloat cellWidth = self.bounds.size.width/count;
    return CGSizeMake(cellWidth,cellHeight);
}

#pragma ---- LJYApplicationItemProtocol
- (void)applicationItemDelete:(LJYApplicationItem *_Nullable)item {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:item];
    id obj = [self.appArr objectAtIndex:indexPath.row];
    [self.appArr removeObject:obj];
    [self reloadData];
    if ([self.delegate respondsToSelector:@selector(applicationViewUpdateItem:)]) {
        [self.delegate applicationViewUpdateItem:self];
    }
}

#pragma mark -
#pragma mark 刷新方法
//拖拽排序后需要重新排序数据源
-(void)rearrangeInUseTitles
{
    id obj = [self.appArr objectAtIndex:self.dragingIndexPath.row];
    [self.appArr removeObject:obj];
    [self.appArr insertObject:obj atIndex:self.targetIndexPath.row];
}

- (void)setAppList:(NSArray *)appList {
    _appList = [appList copy];
    self.appArr = [NSMutableArray arrayWithArray:_appList];
}

-(void)reloadData
{
    [self.collectionView reloadData];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.collectionView.frame = self.bounds;
}

@end
