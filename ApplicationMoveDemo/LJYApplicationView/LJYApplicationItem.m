//
//  LJYApplicationItem.m
//  ApplicationMoveDemo
//
//  Created by 林继沅 on 2020/11/16.
//

#import "LJYApplicationItem.h"
#import <Masonry/Masonry.h>

@interface LJYApplicationItem ()

@property(nonatomic, strong) UIImageView *iconImageView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIButton *editBtn;

@end

@implementation LJYApplicationItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
        [self layoutViews];
    }
    return self;
}

- (void)createUI{
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.editBtn];
}

- (void)layoutViews{
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(15);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(5);
    }];
    
    [_editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.iconImageView.mas_trailing);
        make.centerY.equalTo(self.iconImageView.mas_top);
        make.width.mas_equalTo(17);
        make.height.mas_equalTo(17);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = @"";
//    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
    self.iconImageView.image = nil;
}

#pragma mark --- actions

- (void)editBtnAction {
    if (_type == ApplicationItemTypeDelete) {
        if ([self.delegate respondsToSelector:@selector(applicationItemDelete:)]) {
            [self.delegate applicationItemDelete:self];
        }
    }else if (_type == ApplicationItemTypeSelect) {
        if ([self.delegate respondsToSelector:@selector(applicationItemSelect:)]) {
            [self.delegate applicationItemSelect:self];
        }
    }
}

#pragma mark --- setter

- (void)setType:(ApplicationItemType)type {
    _type = type;
    switch (_type) {
        case ApplicationItemTypeNone:{
            _editBtn.hidden = YES;
        }
            break;
        case ApplicationItemTypeDelete:{
            _editBtn.hidden = NO;
            [_editBtn setImage:[UIImage imageNamed:@"Func_remove_btn"] forState:(UIControlStateNormal)];
            _iconImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBtnAction)];
            [_iconImageView addGestureRecognizer:tap];
        }
            break;
        case ApplicationItemTypeSelect:{
            _editBtn.hidden = NO;
            [_editBtn setImage:[UIImage imageNamed:@"func_app_small_unselected"] forState:(UIControlStateNormal)];
            [_editBtn setImage:[UIImage imageNamed:@"func_app_small_selected"] forState:(UIControlStateSelected)];
            _iconImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBtnAction)];
            [_iconImageView addGestureRecognizer:tap];
        }
            break;
    }
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = _title;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = [imageUrl copy];
    if ([_imageUrl hasPrefix:@"http"] || [_imageUrl hasPrefix:@"https"]) {
//        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_imageUrl]];
    }else {
        self.iconImageView.image = [UIImage imageNamed:_imageUrl];
    }
}

- (void)setCellSelect:(BOOL)cellSelect {
    _cellSelect = cellSelect;
    if (_type == ApplicationItemTypeSelect) {
        _editBtn.selected = _cellSelect;
    }
}

#pragma mark --- getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = @"测试标题";
    }
    return _titleLabel;
}

- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _editBtn.hidden = YES;
        [_editBtn addTarget:self action:@selector(editBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _editBtn;
}


@end
