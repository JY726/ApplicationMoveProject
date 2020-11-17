//
//  ViewController.m
//  ApplicationMoveDemo
//
//  Created by 林继沅 on 2020/11/16.
//

#import "ViewController.h"
#import "LJYApplicationView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LJYApplicationView *applicationView = [[LJYApplicationView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    applicationView.headerTitle = @"测试1";
    applicationView.appList = @[@"已办工作",@"待阅工作",@"会议日程",@"其他待办"];
    [self.view addSubview:applicationView];
    
}


@end
