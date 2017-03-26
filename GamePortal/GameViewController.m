//
//  GameViewController.m
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) SocketIOClient *socket;
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
@property (strong, nonatomic) NSMutableArray *msgArray;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgTableView.delegate = self;
    self.msgTableView.dataSource = self;
    NSURL* url = [[NSURL alloc] initWithString:@"http://localhost:3000"];
    _socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
    _msgArray = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupSocket];
    [_socket connect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSocket {
    /* client try to connect to server */
    [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        [self setStage:kConnectionEstablished];
        OnAckCallback *callback = [_socket emitWithAck:@"joinGame" with:@[@{@"username": self.username}]];
        [callback timingOutAfter:5.0 callback:^(NSArray* data) {
            /* join game call back do nothing */
            NSLog(@"joinGame call back");
        }];
    }];
    
    [_socket on:@"onDispatchRole" callback:^(NSArray * data, SocketAckEmitter * ack) {
        /* user got its rule, game is starting. */
        [self setStage: kGameStart];
        /* get role information. */
        NSDictionary *rr = [data objectAtIndex:0];
        NSLog(@"%@", rr[@"role"]);
    }];
    
    [_socket on:@"night" callback:^(NSArray* data, SocketAckEmitter* ack) {
        /* get the current night's sequnce number. */
    }];
    
    [_socket on:@"msg" callback:^(NSArray* data, SocketAckEmitter* ack) {
        /* receive system msg from server. */
        NSString *str = [data objectAtIndex:0];
        [_msgArray addObject: str];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.msgArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
