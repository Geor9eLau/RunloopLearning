//
//  ViewController.m
//  Demo2
//
//  Created by George on 2017/3/2.
//  Copyright © 2017年 George. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupTestTableView];
#if 1
    //timer的使用方法
    NSTimer *timer = [NSTimer timerWithTimeInterval:1
                                             target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
#endif
    
#if 0
    //下面这种使用方法相当于上面的方法，默认将timer加入至runloop的defaultMode当中
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
#endif
    
#if 0
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(subThreadEvent) object:nil];
    [thread start];
    
    
#endif
    //主线程中的RunLoop有两个预设的Mode：kCFRunLoopDefaultMode 和 UITrackingRunLoopMode,并且这两个Mode都已被标记为“Common”属性
    //kCFRunLoopDefaultMode是App平时所处的状态
    //UITrackingRunLoopMode是追踪ScrollView滑动时的状态
    //所以当将timer置入defultMode的时候，timer会得到重复回调，当如果此时滑动tableview时，RunLoop会将当前mode切换为trackingMode，此时timer将不会得到回调。
    
    
    //****************************************************************************************************
    
    /*如果需要timer能在两种mode中都能得到回调，一种方法就是将这个timer分别都加入到这两个mode中
    */
    
    /*第二种方式方式就是直接将timer加入到顶层RunLoop中的NSRunLoopCommonModes中（被添加到NSRunLoopCommonModes中的任务会存储在runloop 的commonModeItems中），这种方式，每当runLoop的内容发生变化时，runloop都会自动将commonModeItems里的Source／Observer／Timer同步到具有“Comment”标记的所有mode里，主线程中即是会同步到kCFRunLoopDefaultMode 和UITrackingRunLoopMode中，前面已经提到系统已将其默认标记为“common”属性，具体方法实现如下
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];  
     */
    
    /*
     第三种方式就是自己再创建一个子线程，然后将timer置入该线程的runloop中，此时无论timer是被置入哪个mode中，它的回调都不会受到影响
     这是因为每个线程都有一个自己的runloop，是相互独立的，每个runloop只负责完成自己mode中的item，因此在主线程滑动tableView的时候不会影响到子线程的任务
     
     */
}


#pragma mark - Helper Methods
- (void)setupTestTableView{
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - Event Handlers
- (void)timerEvent{
    NSLog(@"timer is working!!!!!!!!!!");
}

- (void)subThreadEvent{
    NSLog(@"subThreadTimer is working!!!!!!!!!");
    @autoreleasepool {
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
        [loop run];
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell  *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
