//
//  HXReservationDetailViewController.m
//  TipTop-Adviser
//
//  Created by ShiCang on 15/10/25.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "HXReservationDetailViewController.h"
#import "HXReservationDetailViewModel.h"
#import "HXReservationDetailInfoCell.h"
#import "HXReservationDetailClientCell.h"
#import "HXReservationDetailPromptCell.h"
#import "HXReservationDetailRemarkCell.h"
#import "MJRefresh.h"
#import "UIAlertView+BlocksKit.h"
#import "HXAppApiRequest.h"
#import "MBProgressHUD.h"
#import "HXReservationAddRemarkViewController.h"


static NSString *SendOrderApi       = @"/order/confirm";
static NSString *DeleteRemarkApi    = @"/order/remarkDelete";

@interface HXReservationDetailViewController ()
@end

@implementation HXReservationDetailViewController {
    HXReservationDetailViewModel *_viewModel;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _viewModel = [HXReservationDetailViewModel instanceWithOrderID:_orderID];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [self.tableView.header beginRefreshing];
}

- (void)viewConfig {
}

#pragma mark - Event Response
- (IBAction)remarkButtonPressed {
    HXReservationAddRemarkViewController *addRemarkViewController = [HXReservationAddRemarkViewController instance];
    addRemarkViewController.orderID = _orderID;
    [self.navigationController pushViewController:addRemarkViewController animated:YES];
}

- (IBAction)phoneButonPressed {
    [UIAlertView bk_showAlertViewWithTitle:@"是否拨打电话？"
                                   message:_viewModel.detail.order.clientMobile
                         cancelButtonTitle:@"拨打"
                         otherButtonTitles:@[@"取消"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             if (buttonIndex == alertView.cancelButtonIndex) {
                                 ;
                             }
                         }];
}

- (IBAction)sendButonPressed {
    [self sendOrder];
}

#pragma mark - Setter And Getter
- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMyReservation;
}

#pragma mark - Private Methods
- (void)loadData {
    __weak __typeof__(self)weakSelf = self;
    [_viewModel request:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf endLoad];
    }];
}

- (void)endLoad {
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self updateRemarkTapedVew];
}

- (void)updateRemarkTapedVew {
    _remarkTapedView.hidden = !_viewModel.detail.remarks.count;
}

- (void)sendOrder {
    [self startSendOrderReuqestWithParameters:@{@"access_token": @"b487a6db8f621069fc6785b7b303f7de",
                                                             @"id": _orderID}];
}

- (void)startSendOrderReuqestWithParameters:(NSDictionary *)parameters {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof__(self)weakSelf = self;
    [HXAppApiRequest requestPOSTMethodsWithAPI:[HXApi apiURLWithApi:SendOrderApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof__(self)strongSelf = weakSelf;
        NSInteger errorCode = [responseObject[@"error_code"] integerValue];
        if (HXAppApiRequestErrorCodeNoError == errorCode) {
            [UIAlertView bk_showAlertViewWithTitle:@"发送成功！"
                                           message:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil
                                           handler:nil];
        }
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
    }];
}

- (void)startDeleteRemarkRequestWithRemark:(HXReservationDetailRemark *)remark {
    NSDictionary *parameters = @{@"access_token": @"b487a6db8f621069fc6785b7b303f7de",
                                           @"id": remark.ID};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof__(self)weakSelf = self;
    [HXAppApiRequest requestGETMethodsWithAPI:[HXApi apiURLWithApi:DeleteRemarkApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof__(self)strongSelf = weakSelf;
        NSInteger errorCode = [responseObject[@"error_code"] integerValue];
        if (HXAppApiRequestErrorCodeNoError == errorCode) {
            [strongSelf->_viewModel removeRemark:remark];
            [strongSelf.tableView reloadData];
        }
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
    }];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    HXDetailCellRow rowType = [_viewModel.rowTypes[indexPath.row] integerValue];
    switch (rowType) {
        case HXDetailCellRowInfo: {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXReservationDetailInfoCell class]) forIndexPath:indexPath];
            [(HXReservationDetailInfoCell *)cell displayWithDetailViewModel:_viewModel];
            break;
        }
        case HXDetailCellRowClient: {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXReservationDetailClientCell class]) forIndexPath:indexPath];
            [(HXReservationDetailClientCell *)cell displayWithDetailOrder:_viewModel.detail.order];
            break;
        }
        case HXDetailCellRowPrompt: {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXReservationDetailPromptCell class]) forIndexPath:indexPath];
            break;
        }
        case HXDetailCellRowRemark: {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXReservationDetailRemarkCell class]) forIndexPath:indexPath];
            [(HXReservationDetailRemarkCell *)cell displayWithDetailRemark:_viewModel.remarks[indexPath.row - _viewModel.regularRow]];
            break;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row >= _viewModel.regularRow) ? YES : NO;
}

#pragma mark - Table View Delegete Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    HXDetailCellRow row = [_viewModel.rowTypes[indexPath.row] integerValue];
    __weak __typeof__(self)weakSelf = self;
    switch (row) {
        case HXDetailCellRowInfo: {
            height = _viewModel.infoHeight;
            break;
        }
        case HXDetailCellRowClient: {
            height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXReservationDetailClientCell class])
                                              cacheByIndexPath:indexPath
                                                 configuration:
                      ^(HXReservationDetailClientCell *cell) {
                          __strong __typeof__(self)strongSelf = weakSelf;
                          [cell displayWithDetailOrder:strongSelf->_viewModel.detail.order];
                      }];
            break;
        }
        case HXDetailCellRowPrompt: {
            height = _viewModel.promptHeight;
            break;
        }
        case HXDetailCellRowRemark: {
            height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXReservationDetailRemarkCell class])
                                              cacheByIndexPath:indexPath
                                                 configuration:
                      ^(HXReservationDetailRemarkCell *cell) {
                          __strong __typeof__(self)strongSelf = weakSelf;
                          [cell displayWithDetailRemark:strongSelf->_viewModel.remarks[indexPath.row - strongSelf->_viewModel.regularRow]];
                      }];
            break;
        }
    }
    return height;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row >= _viewModel.regularRow) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

static NSString *DeletePrompt = @"删除";
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DeletePrompt;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        [self startDeleteRemarkRequestWithRemark:_viewModel.remarks[indexPath.row - _viewModel.regularRow]];
    }
}


@end
