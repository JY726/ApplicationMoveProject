//
//  LJYApplicationHeader.m
//  ApplicationMoveDemo
//
//  Created by 林继沅 on 2020/11/16.
//

#import "LJYApplicationHeader.h"
#import <Masonry/Masonry.h>

@interface LJYApplicationHeader ()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation LJYApplicationHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
        [self layoutViews];
    }
    return self;
}

- (void)createUI{
    [self addSubview:self.titleLabel];
}

- (void)layoutViews{
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.centerY.equalTo(self);
    }];
}

#pragma mark --- setter

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = _title;
}

#pragma mark --- getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:400];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}


@end
