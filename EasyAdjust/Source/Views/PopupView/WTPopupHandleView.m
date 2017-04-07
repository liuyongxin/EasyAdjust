//
//  WTPopupHandleView.m
//  DzhProjectiPhone
//
//  Created by DZH_Louis on 2017/3/29.
//  Copyright © 2017年 gw. All rights reserved.
//

#import "WTPopupHandleView.h"

static CGFloat kAlertMaxWidth = 280; //弹窗显示部分最大宽度
static CGFloat kContentMinHeight = 100;  //内容最低高度
static CGFloat kBtnHeight = 40;  //按钮默认高度
static CGFloat kContentLRSpace = 10; //默认内容左右边距
static CGFloat kContentFontSize = 15; //默认字体大小
static CGFloat kContentTextVerticalSpace = 5; ////默认内容每行间隔

@interface WTPopupHandleView ()<CAAnimationDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSAttributedString *titleAttrStr;
@property(nonatomic,retain)NSArray <NSArray <NSAttributedString*>*>*contentItems;
@property(nonatomic,retain)NSArray <NSAttributedString*>*btnItems;
@property(nonatomic,copy)void(^clickBtnAction)(NSInteger btnIndex);
@property(nonatomic,retain)NSMutableArray *contentItemsHeightArr;
@property(nonatomic,assign)BOOL isNeeedDismissAnimation;
@property(nonatomic,retain)UIView *alertView;
@property(nonatomic,retain)UIImageView *mainBgView;
@property(nonatomic,retain)UITableView *contentTableView;
@property(nonatomic,retain)UITableView *btnTableView;
@property(nonatomic,retain)UIButton *closeBtn;

@end

@implementation WTPopupHandleView

- (void)dealloc
{
    self.contentItemsHeightArr = nil;
    self.closeBtnImage = nil;
    self.titleAttrStr = nil;
    self.titleColor = nil;
    self.btnColor = nil;
    self.contentItems = nil;
    self.btnItems = nil;
    self.clickBtnAction = nil;
#ifdef MRC_PopupConfirmView
    [super dealloc];
#endif
}

- (instancetype)initWithTitle:(NSAttributedString *)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems clickBtnAction:(void(^)(NSInteger btnIndex))action
{
    self = [super init];
    if (self) {
        self.titleAttrStr = titleAttrStr;
        self.contentItems = contentItems;
        self.btnItems = btnItems;
        self.clickBtnAction = action;
        [self initData];
    }
    return self;
}

- (void)initData
{
    _contentItemsHeightArr = [[NSMutableArray alloc]init];
    
    _titleColor = [UIColor blackColor];
    _btnColor = [UIColor blackColor];
    _alertBackgroundColor = [UIColor whiteColor];

    _btnSizeHeight =  kBtnHeight;
    _contentFontSize = kContentFontSize;
    _contentLRSpace = kContentLRSpace;
    _contentTextVerticalSpace = kContentTextVerticalSpace;
    
    _contentTextAlignment = NSTextAlignmentLeft;
    _isNeedShowCloseBtn = NO;
    _isNeeedDismissAnimation = NO;
}

- (void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    self.frame = _selfSuperView.bounds;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    if (self.mainBgView) {
        [self.mainBgView removeFromSuperview];
        self.mainBgView = nil;
    }

    _mainBgView  = [[UIImageView alloc]initWithFrame:self.bounds];
    _mainBgView.backgroundColor = [UIColor blackColor];
    _mainBgView.userInteractionEnabled = YES;
    _mainBgView.alpha = 0.3;
    [self addSubview:_mainBgView];
#ifdef MRC_PopupConfirmView
    [_mainBgView release];
#endif
    if (self.alertView) {
        [self.alertView removeFromSuperview];
        self.alertView = nil;
    }
    _alertView = [self createAlertView];
    _alertView.layer.shouldRasterize = YES;
    _alertView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _alertView.center = self.center;
    [self addSubview:_alertView];
#ifdef MRC_PopupConfirmView
    [_alertView release];
#endif
}

- (void)closeBtnAction:(UIButton *)btn
{
    [self dismiss:self.isNeeedDismissAnimation];
}

- (UIView *)createAlertView
{
    CGFloat yAxis = 0.0;
    CGFloat aWidth = self.frame.size.width -  40;
    CGFloat maxWidth = aWidth;
    (aWidth > kAlertMaxWidth) ? (maxWidth = kAlertMaxWidth) : (maxWidth = aWidth);
    CGFloat maxHeight = self.frame.size.height - 40;
    
    //alertView
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, maxWidth, maxHeight)];
    alertView.backgroundColor = [UIColor clearColor];
    alertView.userInteractionEnabled = YES;
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 5;
    alertView.layer.masksToBounds = YES;
    
    CGFloat titleHeight = 0;
   CGFloat closeBtnWidth = 40;
    if (_titleAttrStr && [_titleAttrStr isKindOfClass:[NSAttributedString class]] && _titleAttrStr.length > 0) {
        titleHeight = 40;
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(closeBtnWidth, 0, maxWidth - closeBtnWidth*2, titleHeight)];
        titleLabel.attributedText = _titleAttrStr;
        titleLabel.textColor = _titleColor;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [alertView addSubview:titleLabel];
#ifdef MRC_PopupConfirmView
        [titleLabel release];
#endif
        if (_isNeedShowCloseBtn) {
            _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _closeBtn.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame), 0,closeBtnWidth, titleHeight);
            [_closeBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
            [_closeBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            if (_closeBtnImage) {
                [_closeBtn setImage:_closeBtnImage forState:UIControlStateNormal];
            }
            else if (_closeBtnAttrStr && [_closeBtnAttrStr isKindOfClass:[NSAttributedString class]])
            {
                [_closeBtn setAttributedTitle:_closeBtnAttrStr forState:UIControlStateNormal];
            }
            else{
            [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
            }
            _closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;  //对齐方式
            _closeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [_closeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [alertView addSubview:_closeBtn];
        }
        yAxis += titleHeight;
        CALayer *lineLayer1 = [CALayer layer];
        lineLayer1.frame = CGRectMake(0, yAxis -0.5,maxWidth, 0.5);
        lineLayer1.backgroundColor = [UIColor lightGrayColor].CGColor;
        [alertView.layer addSublayer:lineLayer1];
    }
    titleHeight += _contentTextVerticalSpace;
    yAxis += _contentTextVerticalSpace;
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.bounces = NO;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [alertView addSubview:_contentTableView];
    if ([_contentTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_contentTableView setSeparatorInset:UIEdgeInsetsZero];
    }
#ifdef MRC_PopupConfirmView
    [_contentTableView release];
#endif
    
    if (!(_toHorizontalArrangementWhenTwoButtons && _btnItems.count == 2)) {
        _btnTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _btnTableView.dataSource = self;
        _btnTableView.delegate = self;
        _btnTableView.bounces = NO;
        [alertView addSubview:_btnTableView];
#ifdef MRC_PopupConfirmView
        [_btnTableView release];
#endif
        if ([_btnTableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [_btnTableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    CGFloat sumHeight = 0.0;
    CGFloat midSpace = 10;
    CGFloat lrSpace = _contentLRSpace;
    for (NSArray *subArr in self.contentItems) {
        CGFloat mHeight = 0.0;
        CGFloat cellWidth = (maxWidth - lrSpace*2);
        if (subArr.count == 2)
        {
            cellWidth = (maxWidth - midSpace - lrSpace*2)/2;
        }
        for (NSAttributedString *aStr in subArr) {
            NSString  *str = @"";
            if (aStr && [aStr isKindOfClass:[NSAttributedString class]] && aStr.length > 0)
            {
                str = aStr.string;
            }
            CGSize tempSize = [self stringBoundingRectWithSize:CGSizeMake(cellWidth, MAXFLOAT) withFont:[UIFont systemFontOfSize:_contentFontSize] withDescription:str];
            if (tempSize.height > mHeight) {
                mHeight = tempSize.height;
            }
        }
        [self.contentItemsHeightArr addObject:[NSNumber numberWithFloat:mHeight + _contentTextVerticalSpace]];
        sumHeight += mHeight + _contentTextVerticalSpace;
    }
    
    CGFloat btnTableViewHeight = (_toHorizontalArrangementWhenTwoButtons && self.btnItems.count == 2) ? _btnSizeHeight : (self.btnItems.count * _btnSizeHeight); //两个按钮横向排列
    CGFloat contentMinHeight = (sumHeight > kContentMinHeight) ?  kContentMinHeight : sumHeight;
    if (btnTableViewHeight + contentMinHeight > maxHeight - titleHeight) {
        btnTableViewHeight = ((int)((maxHeight -titleHeight - contentMinHeight)/_btnSizeHeight))*_btnSizeHeight;
    }
    CGFloat contentTableViewHeight = maxHeight - btnTableViewHeight - titleHeight;
    if (contentTableViewHeight > sumHeight) {
        contentTableViewHeight = sumHeight;
    }
    _contentTableView.frame = CGRectMake(0,yAxis, maxWidth, contentTableViewHeight);
    yAxis += contentTableViewHeight + 0.5;
    CALayer *lineLayer2 = [CALayer layer];
    lineLayer2.frame = CGRectMake(0, yAxis - 0.5,maxWidth, 0.5);
    lineLayer2.backgroundColor = [UIColor lightGrayColor].CGColor;
    [alertView.layer addSublayer:lineLayer2];
    if (!(_toHorizontalArrangementWhenTwoButtons && _btnItems.count == 2)) {
        _btnTableView.frame = CGRectMake(0,yAxis, maxWidth, btnTableViewHeight);
    }
    else
    {
        for (int i = 0; i < _btnItems.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake((maxWidth/2 + 0.5)*i, yAxis, maxWidth/2 - 0.25, _btnSizeHeight);
            btn.tag = i;
            NSAttributedString *btnAStr = _btnItems[i];
             if (btnAStr && [btnAStr isKindOfClass:[NSAttributedString class]] && btnAStr.length > 0){
                [btn setAttributedTitle:btnAStr forState:UIControlStateNormal];
             }
            [btn setTitleColor:_btnColor forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(tapBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [alertView addSubview:btn];
        }
        CALayer *lineLayer3 = [CALayer layer];
        lineLayer3.frame = CGRectMake((maxWidth/2 - 0.25), yAxis,0.5, btnTableViewHeight);
        lineLayer3.backgroundColor = [UIColor lightGrayColor].CGColor;
        [alertView.layer addSublayer:lineLayer3];
    }
    
    yAxis += btnTableViewHeight;
    alertView.frame = CGRectMake(0, 0, maxWidth, yAxis);
    return alertView;
}

- (void)reloadTableViewData
{
    [_contentTableView reloadData];
     if (!(_toHorizontalArrangementWhenTwoButtons && _btnItems.count == 2))
     {
         [_btnTableView reloadData];
     }
}

- (void)showInWindow
{
    [self showInView:[[UIApplication sharedApplication] delegate].window];
}

- (void)showInView:(UIView *)view;
{
    [self showInView:view animated:NO withDismissAnimation:NO];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated withDismissAnimation:(BOOL)dismissAnimation
{
    self.isNeeedDismissAnimation = dismissAnimation;
    _selfSuperView = view;
    [self configUI];
    [self reloadTableViewData];
    //显示self到父视图
    [self removeFromSuperview];
    [_selfSuperView addSubview:self];
    if (animated) {
        [self showAnimation];
    }
    else
    {
        _isShow = YES;
    }
}

- (void)dismiss:(BOOL)animation
{
    if (animation) {
        [self dismissAnimation];
    }
    else
    {
        _isShow = NO;
        [self removeFromSuperview];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [event.allTouches anyObject];
    CGPoint point  = [touch locationInView:_selfSuperView];
    if (self.isShow && !CGRectContainsPoint(self.alertView.frame, point))
    {
        [self dismiss:self.isNeeedDismissAnimation];
    }
}

- (void)tapBtnAction:(UIButton *)btn
{
    if (self.clickBtnAction) {
        self.clickBtnAction(btn.tag);
    }
    [self dismiss:self.isNeeedDismissAnimation];
}

#pragma mark--  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _contentTableView) {
        return self.contentItems.count;
    }
    else
    {
        return self.btnItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _contentTableView) {
        static NSString *cellID = @"PopupHandleItemCell";
        PopupHandleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[PopupHandleItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.cellWidth = tableView.frame.size.width;
            cell.itemFontSize = _contentFontSize;
            cell.contentLRSpace = _contentLRSpace;
            cell.contentTextAlignment = self.contentTextAlignment;
        }
        if (self.contentItemsHeightArr.count > indexPath.row) {
            cell.cellHeight = [self.contentItemsHeightArr[indexPath.row] floatValue];
        }
        [cell fillItemsData:self.contentItems[indexPath.row]];
        return cell;
    }
    else
    {
        static NSString *cellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
                [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
                [cell setPreservesSuperviewLayoutMargins:NO];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = _btnColor;
        }
        cell.textLabel.attributedText = self.btnItems[indexPath.row];
        return cell;
    }
}

#pragma mark--  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _contentTableView) {
        CGFloat height = 0.0;
        if (self.contentItemsHeightArr.count > indexPath.row) {
            height = [self.contentItemsHeightArr[indexPath.row] floatValue];
        }
        return height;
    }
    else
    {
        return _btnSizeHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _btnTableView) {
        if (self.clickBtnAction) {
            self.clickBtnAction(indexPath.row);
        }
        [self dismiss:self.isNeeedDismissAnimation];
    }
}

#pragma mark -- Animation
- (void)showAnimation  //仿UIAlertView动画效果
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.delegate=self;
    popAnimation.removedOnCompletion = NO;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.alertView.layer addAnimation:popAnimation forKey:@"showAnimation"];
}

- (void)dismissAnimation
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0];
    scaleAnimation.fillMode = kCAFillModeForwards;
    //    scaleAnimation.fillMode = kCAFillModeRemoved;
    scaleAnimation.duration = 0.1;
    scaleAnimation.delegate = self;
    scaleAnimation.removedOnCompletion = NO;
    [self.alertView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag //动画代理
{
    if(anim ==[self.alertView.layer animationForKey:@"scaleAnimation"])
    {
        [self.alertView.layer removeAnimationForKey:@"scaleAnimation"];
        _isShow = NO;
        [self removeFromSuperview];
    }
    else if (anim == [self.alertView.layer animationForKey:@"showAnimation"])
    {
        [self.alertView.layer removeAnimationForKey:@"showAnimation"];
        _isShow = YES;
    }
}

#pragma mark -- Util
//计算字符串尺寸
- (CGSize)stringBoundingRectWithSize:(CGSize)size withFont:(UIFont *)font withDescription:(NSString *)text
{
    CGSize s = CGSizeMake(size.width, size.height);
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize retSize = [text boundingRectWithSize:s    //该方法支持 ios 7.0以上系统
                                        options:
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    return CGSizeMake(retSize.width, retSize.height);
}

@end

#pragma mark -- PopupHandleItemCell;
@interface PopupHandleItemCell()

@property(nonatomic,retain)UILabel *itemLabelOne;
@property(nonatomic,retain)UILabel *itemLabelTwo;

@end

@implementation PopupHandleItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self respondsToSelector:@selector(setLayoutMargins:)]){
            [self setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        if([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [self setPreservesSuperviewLayoutMargins:NO];
        }
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    _itemLabelOne = [[UILabel alloc]initWithFrame:CGRectZero];
    _itemLabelOne.adjustsFontSizeToFitWidth = YES;
    _itemLabelOne.textAlignment = _contentTextAlignment;
    _itemLabelOne.numberOfLines = 0;
    [self addSubview:_itemLabelOne];
#ifdef MRC_PopupConfirmView
    [_itemLabelOne release];
#endif
    _itemLabelTwo = [[UILabel alloc]initWithFrame:CGRectZero];
    _itemLabelTwo.textAlignment = _contentTextAlignment;
    _itemLabelTwo.adjustsFontSizeToFitWidth = YES;
    _itemLabelTwo.numberOfLines = 0;
    [self addSubview:_itemLabelTwo];
#ifdef MRC_PopupConfirmView
    [_itemLabelTwo release];
#endif
}

- (void)setContentTextAlignment:(NSTextAlignment)contentTextAlignment
{
    _contentTextAlignment = contentTextAlignment;
    _itemLabelOne.textAlignment = _contentTextAlignment;
    _itemLabelTwo.textAlignment = _contentTextAlignment;
}
- (void)setItemFontSize:(CGFloat)itemFontSize
{
    _itemFontSize = itemFontSize;
    _itemLabelOne.font = [UIFont systemFontOfSize:_itemFontSize ? _itemFontSize : kContentFontSize];
    _itemLabelTwo.font = [UIFont systemFontOfSize:_itemFontSize ? _itemFontSize : kContentFontSize];
}

- (void)fillItemsData:(NSArray *)itemsArr
{
    _itemLabelOne.attributedText = nil;
    _itemLabelOne.attributedText = nil;
    if (!itemsArr || itemsArr.count <= 0) {return;}
    CGFloat midSpace = 10;
    CGFloat lrSpace = _contentLRSpace;
    if (itemsArr.count == 1) {
        CGFloat width = (_cellWidth - lrSpace*2);
        _itemLabelOne.frame = CGRectMake(lrSpace, 0, width, _cellHeight);
        NSAttributedString *attrStr = itemsArr[0];
        if (attrStr && [attrStr isKindOfClass:[NSAttributedString class]] && attrStr.length > 0){
            _itemLabelOne.attributedText = attrStr;
        }
        _itemLabelTwo.frame = CGRectZero;
    }
    else if (itemsArr.count == 2)
    {
        CGFloat width = (_cellWidth - midSpace - lrSpace*2)/2;
        NSAttributedString *aStr1 = itemsArr[0];
        NSDictionary *attribute1 = @{NSFontAttributeName: _itemLabelOne.font};
        CGSize size1 = [aStr1.string boundingRectWithSize:CGSizeMake(width, _cellHeight)     //该方法支持 ios 7.0以上系统
                                            options:
                          NSStringDrawingTruncatesLastVisibleLine |
                          NSStringDrawingUsesLineFragmentOrigin |
                          NSStringDrawingUsesFontLeading
                                         attributes:attribute1
                                            context:nil].size;
        _itemLabelOne.frame = CGRectMake(lrSpace, 0, width, size1.height);
        NSAttributedString *attrStr1 = itemsArr[0];
        if (attrStr1 && [attrStr1 isKindOfClass:[NSAttributedString class]] && attrStr1.length > 0){
            _itemLabelOne.attributedText = attrStr1;
        }
        
        NSAttributedString *aStr2 = itemsArr[1];
        NSDictionary *attribute2 = @{NSFontAttributeName: _itemLabelTwo.font};
        CGSize size2 = [aStr2.string boundingRectWithSize:CGSizeMake(width, _cellHeight)     //该方法支持 ios 7.0以上系统
                                                  options:
                        NSStringDrawingTruncatesLastVisibleLine |
                        NSStringDrawingUsesLineFragmentOrigin |
                        NSStringDrawingUsesFontLeading
                                               attributes:attribute2
                                                  context:nil].size;
        _itemLabelTwo.frame = CGRectMake(width+midSpace+lrSpace, 0, width, size2.height);
        NSAttributedString *attrStr2 = itemsArr[1];
        if (attrStr2 && [attrStr2 isKindOfClass:[NSAttributedString class]] && attrStr2.length > 0){
            _itemLabelTwo.attributedText = attrStr2;
        }
    }
}

@end

