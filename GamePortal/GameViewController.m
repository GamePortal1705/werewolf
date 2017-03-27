//
//  GameViewController.m
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GameViewController.h"
#import "GPMsgTableViewCell.h"

@interface GameViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) SocketIOClient *socket;
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
@property (strong, nonatomic) NSMutableArray *msgArray;
@property (weak, nonatomic) IBOutlet UIButton *avBox1;
@property (weak, nonatomic) IBOutlet UIButton *avBox2;
@property (weak, nonatomic) IBOutlet UIButton *avBox3;
@property (weak, nonatomic) IBOutlet UIButton *avBox4;
@property (weak, nonatomic) IBOutlet UIButton *avBox5;
@property (weak, nonatomic) IBOutlet UIButton *avBox6;
@property (strong, nonatomic) NSArray *avBoxs;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startDateTime;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgTableView.delegate = self;
    self.msgTableView.dataSource = self;
    self.msgTableView.separatorColor = [UIColor clearColor];
    NSURL* url = [[NSURL alloc] initWithString:@"http://localhost:3000"];
    _socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO, @"forcePolling": @YES}];
    _msgArray = [[NSMutableArray alloc] init];
    _avBoxs = [[NSArray alloc] initWithObjects: _avBox1, _avBox2, _avBox3, _avBox4, _avBox5, _avBox6, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupSocket];
    [_socket connect];
    if (_stage != kVote) {
        _timerLabel.hidden = YES;
    }
    for (UIButton *box in _avBoxs) {
        box.layer.cornerRadius = 5;
        [box.layer setMasksToBounds:YES];
        [box.layer setBorderWidth:1.5];
        box.userInteractionEnabled = NO;
    }
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
        self.msgTableView.backgroundColor = [UIColor redColor];
    }];
    
    [_socket on:@"msg" callback:^(NSArray* data, SocketAckEmitter* ack) {
        /* receive system msg from server. */
        NSString *str = [data objectAtIndex:0];
        [_msgArray addObject: str];
        [_msgTableView reloadData];
    }];
    
    [_socket on:@"vote" callback:^(NSArray* data, SocketAckEmitter* ack) {
        _stage = kVote;
        [self buttonClickEnable];
        NSString *votehint = @"Vote begins, please choose one player in 60 secs";
        [_msgArray addObject:votehint];
        [self.msgTableView reloadData];
    }];
}

- (void)buttonClickEnable {
    if (_stage == kVote) {
        for (UIButton *box in self.avBoxs) {
            box.userInteractionEnabled = YES;
        }
        _timerLabel.hidden = NO;
        if (![_timer isValid]) {
            _startDateTime = [NSDate date];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readTimer) userInfo:nil repeats:YES];
        }
    }
}

- (void)readTimer {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_startDateTime];
    NSInteger interval= 60 - timeInterval;
    [self.timerLabel setText:[[NSString alloc] initWithFormat:@"%2ld", (long)interval]];
    if (interval == 0) {
        [_timer invalidate];
        _timerLabel.hidden = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.msgArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GPMsgTableViewCell *cell = nil;
    cell = [self.msgTableView dequeueReusableCellWithIdentifier: @"msgCell"];
    if (!cell) {
        cell = [[GPMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"msgCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.msg.text = [self.msgArray objectAtIndex:indexPath.row];
    cell.msg.adjustsFontSizeToFitWidth = YES;
    return cell;
}

- (IBAction)makeVoteDecision:(id)sender {
    int index = 0;
    for (UIButton *tmp in self.avBoxs) {
        if (sender == tmp)
            NSLog(@"%d", index);
        index++;
    }
    // socket emit kill msg
    // disable button interaction & invalid timer
    for (UIButton *tmp in self.avBoxs)
        tmp.userInteractionEnabled = NO;
    [_timer invalidate];
    _timerLabel.hidden = YES;
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
