//
//  ViewController.m
//  Reorder
//
//  Created by NiiLove on 2020/10/8.
//  Copyright © 2020 zengfandi. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+ZFDSymbolHook.h"

@interface ViewController ()

@end

@implementation ViewController

+ (void)load{
    
}

void(^block1)(void) = ^(void){
    
};

- (void)test3{
    block1();
}
- (void)test2{}
- (void)test1{}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test1];
    [self test2];
    [NSObject ZFDSymbolHook];
}




@end
