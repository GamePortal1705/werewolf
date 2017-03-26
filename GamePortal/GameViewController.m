//
//  GameViewController.m
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@property SocketIOClient *socket;
@property (weak, nonatomic) IBOutlet UIScrollView *msgView;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL* url = [[NSURL alloc] initWithString:@"http://localhost:3000"];
    _socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupSocket];
    [_socket connect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupSocket {
    /* client try to connect to server */
    [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        [self setStage:kConnectionEstablished];
        OnAckCallback *callback = [_socket emitWithAck:@"joinGame" with:@[@{@"username":@"hong"}]];
        [callback timingOutAfter:5.0 callback:^(NSArray* data) {
            /* join game call back do nothing */
        }];
    }];
    
    [_socket on:@"onDispatchRole" callback:^(NSArray * data, SocketAckEmitter * ack) {
        // user got its rule, game is starting.
        [self setStage:kGameStart];
        self.msgView.backgroundColor = [UIColor redColor];
    }];
    
    [_socket on:@"night" callback:^(NSArray* data, SocketAckEmitter* ack) {
        // get the current night's sequnce number
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
