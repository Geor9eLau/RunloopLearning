//
//  ViewController.m
//  Demo1
//
//  Created by George on 2017/3/2.
//  Copyright © 2017年 George. All rights reserved.
//

#import "ViewController.h"
#import "TestThread.h"

@interface ViewController ()

@property (nonatomic, strong) TestThread *testThread;

@end

@implementation ViewController

//让子线程长时间存活，通过使用runloop的方式实现

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupThread];
    
//    [self setupThreadWithoutRunLoop];
}

- (void)setupThread{
    self.testThread = [[TestThread alloc] initWithTarget:self selector:@selector(threadEntryPoint) object:nil];
    [self.testThread start];
}

- (void)setupThreadWithoutRunLoop{
    TestThread *thread = [[TestThread alloc] initWithTarget:self selector:@selector(eventWithoutRunLoop) object:nil];
    [thread start];
}

#pragma mark - Event Handlers
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(printSomething) onThread:self.testThread withObject:nil waitUntilDone:NO];
}


- (void)threadEntryPoint{
    @autoreleasepool {
        //获取runloop只能通过[NSRunLoop currentRunLoop]或者  [NSRunLoop mainRunLoop]
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        
        //需要往runloop的mode中添加item，否则在该线程所想执行的任务都不会实现。在NSRunLoop中可以往mode中添加两类item任务：NSPort（对应Source）、NSTimer
        [loop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        
        //如果该runLoop中没有mode或者没有item，runloop会直接在当前的loop中返回并进入睡眠状态
        //作为长驻线程，再没有任何事件的时候，因为是睡眠状态，所以该线程对资源的消耗比较低
        NSLog(@"启动RunLoop前--%@",loop.currentMode);
        [loop run];
    }
}

- (void)printSomething{
    NSLog(@"启动RunLoop后--%@",[NSRunLoop currentRunLoop]);
    NSLog(@"%@----子线程任务开始",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:3.0];
    NSLog(@"%@----子线程任务结束",[NSThread currentThread]);
    NSLog(@"touch touch touch touch touch!!!!!!");
}

- (void)eventWithoutRunLoop{
    NSLog(@"No runLoop");
}

@end
