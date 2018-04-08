//
//  ViewController.m
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import "ViewController.h"
#import "BFNetworkManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[BFNetworkManager sharedInstance] connectToDefaultTargetServer];
//    [self performSelector:@selector(disconnectToServer) withObject:nil afterDelay:10];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[BFNetworkManager sharedInstance] loginDefaultAccount];
}

- (void)disconnectToServer {
    
    [[BFNetworkManager sharedInstance] disconnectToDefaultTargetServer];
}


@end
