//
//  WTPopupHandleView.h
//  DzhProjectiPhone
//
//  Created by DZH_Louis on 2017/3/29.
//  Copyright © 2017年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_feature(objc_arc)  //arc模式
#else
#define MRC_PopupConfirmView
#endif

@interface WTPopupHandleView : UIView

@property(nonatomic,retain)UIImage *closeBtnImage;
@property(nonatomic,retain)NSAttributedString *closeBtnAttrStr;
@property(nonatomic,retain)UIColor *titleColor; //默认黑色
@property(nonatomic,retain)UIColor *btnColor; //默认黑色
@property(nonatomic,retain)UIColor *alertBackgroundColor; //默认白色

@property(nonatomic,assign)CGFloat contentFontSize; //默认15
@property(nonatomic,assign)CGFloat btnSizeHeight; //按钮高度40
@property(nonatomic,assign)CGFloat contentLRSpace; //内容左右边距,默认10
@property(nonatomic,assign)CGFloat contentTextVerticalSpace; //内容每行间隔,默认5

@property(nonatomic,assign)BOOL isNeedShowCloseBtn; //默认NO
@property(nonatomic,assign,readonly)BOOL isShow;
@property(nonatomic,assign)NSTextAlignment contentTextAlignment; //默认NSTextAlignmentLeft
@property(nonatomic,assign)BOOL toHorizontalArrangementWhenTwoButtons; //横向排列,当有两个按钮时,默认为no

@property(nonatomic,assign,readonly)UIView *selfSuperView;

/**
 初始化
 @param titleAttrStr 标题
 @param contentItems @[@[item1,item2],@[item3],@[item4,item5]....]
 @param btnItems @[str1,str2,str3...]
 @param action 点击按钮事件
 @return 返回对象
 */
- (instancetype)initWithTitle:(NSAttributedString*)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems clickBtnAction:(void(^)(NSInteger btnIndex))action;

/**
 显示视图
 //在window上显示,消失时务必调用dismiss方法
 //默认不需要弹出消失动画
 */
- (void)showInWindow;
/**
 显示视图
 @param view SuperView
//默认不需要弹出消失动画
 */
- (void)showInView:(UIView *)view;
/**
 显示视图
 @param view SuperView
 @param animated 是否需要弹出动画
 @param adismissAnimation 是否需要消失动画
 */
- (void)showInView:(UIView *)view animated:(BOOL)animated withDismissAnimation:(BOOL)dismissAnimation;

/**
 消失方法
 @param animation是否需要消失动画
 */
- (void)dismiss:(BOOL)animation;

@end

@interface PopupHandleItemCell : UITableViewCell

@property(nonatomic,assign)CGFloat cellWidth;
@property(nonatomic,assign)CGFloat cellHeight;
@property(nonatomic,assign)CGFloat itemFontSize;
@property(nonatomic,assign)CGFloat contentLRSpace; //内容左右边距,默认10
@property(nonatomic,assign)NSTextAlignment contentTextAlignment;
- (void)fillItemsData:(NSArray *)itemsArr;

@end
