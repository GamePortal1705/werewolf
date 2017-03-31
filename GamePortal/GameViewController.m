//
//  GameViewController.m
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GameViewController.h"
#import <videoprp/AgoraYuvEnhancerObjc.h>
#import "VideoSession.h"
#import "VideoViewLayouter.h"
#import "KeyCenter.h"
#import "GPMsgTableViewCell.h"
#import "GPHeadView.h"
#import "FUISwitch.h"
#import "UIColor+FlatUI.h"
#import "FUIButton.h"
#import "UIFont+FlatUI.h"
#import "DGActivityIndicatorView.h"
#import "GPCardView.h"

@interface GameViewController () <AgoraRtcEngineDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSMutableArray *isAlive;

@property (weak, nonatomic) IBOutlet UIButton *enhancerButton;
@property (weak, nonatomic) IBOutlet FUIButton *stopStatementBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) FUISwitch *enhanceSwitch;

@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;
@property (strong, nonatomic) SocketIOClient *socket;
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
@property (strong, nonatomic) NSMutableArray *msgArray;
@property (weak, nonatomic) IBOutlet UIButton *avBox1;
@property (weak, nonatomic) IBOutlet UIButton *avBox2;
@property (weak, nonatomic) IBOutlet UIButton *avBox3;
@property (weak, nonatomic) IBOutlet UIButton *avBox4;
@property (weak, nonatomic) IBOutlet UIButton *avBox5;
@property (weak, nonatomic) IBOutlet UIButton *avBox6;
//@property (strong, nonatomic) NSMutableArray *tmpBoxs;
@property (strong, nonatomic) NSMutableArray *avBoxs;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startDateTime;

@property (weak, nonatomic) IBOutlet UIImageView *res1;
@property (weak, nonatomic) IBOutlet UIImageView *res2;
@property (weak, nonatomic) IBOutlet UIImageView *res3;
@property (weak, nonatomic) IBOutlet UIImageView *res4;
@property (weak, nonatomic) IBOutlet UIImageView *res5;
@property (weak, nonatomic) IBOutlet UIImageView *res6;

//@property (strong, nonatomic) NSMutableArray *tmpRes;
@property (strong, nonatomic) NSMutableArray *avRes;



@property (strong, nonatomic) AgoraRtcEngineKit *rtcEngine;
@property (strong, nonatomic) AgoraYuvEnhancerObjc *agoraEnhancer;
@property (assign, nonatomic) BOOL isBroadcaster;
@property (assign, nonatomic) BOOL isMuted;
@property (assign, nonatomic) BOOL shouldEnhancer;
@property (strong, nonatomic) NSMutableArray<VideoSession *> *videoSessions;
@property (strong, nonatomic) VideoSession *fullSession;
@property (strong, nonatomic) VideoViewLayouter *viewLayouter;
@property (strong, nonatomic) DGActivityIndicatorView *loadingView;
@property (strong, nonatomic) UILabel *loadingMsg;
@property (strong, nonatomic) GPHeadView *headView;
@property (strong, nonatomic) GPCardView *roleCard;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation GameViewController

//Video Chat

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgTableView.delegate = self;
    self.msgTableView.dataSource = self;
    self.msgTableView.separatorColor = [UIColor clearColor];
    NSURL* url = [[NSURL alloc] initWithString:@"http://10.128.9.214:3000"];
    _socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO, @"forcePolling": @YES}];
    _msgArray = [[NSMutableArray alloc] init];
    _avBoxs = [[NSMutableArray alloc] initWithObjects: _avBox1, _avBox2, _avBox3, _avBox4, _avBox5, _avBox6, nil];
    _avRes = [[NSMutableArray alloc] initWithObjects:_res1, _res2, _res3, _res4, _res5, _res6, nil];
    
    self.videoSessions = [[NSMutableArray alloc] init];
    //self.roomNameLabel.text = self.roomName;
    self.backgroundImageView.alpha = 1.0;
    self.roomName = @"ctctct";
    
    _headView = [[GPHeadView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    _headView.center = CGPointMake(self.view.frame.size.width/2, 50);
    [_headView rotateImageView];
    [self.view addSubview:_headView];
    
    _enhanceSwitch = [[FUISwitch alloc] initWithFrame:CGRectMake(10, 400, 60, 30)];
    _enhanceSwitch.onColor = [UIColor turquoiseColor];
    _enhanceSwitch.offColor = [UIColor cloudsColor];
    [_enhanceSwitch setOn:YES];
    _enhanceSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    _enhanceSwitch.offBackgroundColor = [UIColor silverColor];
    _enhanceSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    _enhanceSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];
    [self.view addSubview:_enhanceSwitch];
    _enhanceSwitch.hidden = YES;
    [_enhanceSwitch addTarget:self action:@selector(changeEnhanceMode) forControlEvents:UIControlEventValueChanged];
    // default behaviour for video chat enhance mode is off.
    
    self.enhancerButton.hidden = YES;
    
    _stopStatementBtn.buttonColor = [UIColor redColor];
    _stopStatementBtn.shadowColor = [UIColor redColor];
    _stopStatementBtn.shadowHeight = 3.0f;
    _stopStatementBtn.cornerRadius = 6.0f;
    _stopStatementBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [_stopStatementBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [_stopStatementBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];

    [_stopStatementBtn setHidden:YES];
    
    //role Card to display the role information of the current player.
    _roleCard = [[GPCardView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _roleCard.center = CGPointMake(self.view.center.x, 200);
    [self.view addSubview:_roleCard];
    
    self.timerLabel.textColor = [UIColor whiteColor];
    
    [self loadAgoraKit];
    
    
    // kvo subroutine
    [self addObserver:self forKeyPath:@"stage" options:(NSKeyValueChangeNewKey) context:NULL];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"KVO");
    if ([keyPath isEqualToString:@"stage"]) {
        switch ([[change objectForKey:NSKeyValueChangeNewKey] integerValue]) {
            case 0:
                _statusLabel.text = @"state 1";
                break;
            case 1:
                _statusLabel.text = @"state 2";
                break;
            case 2:
                _statusLabel.text = @"state 3";
                break;
            case 3:
                _statusLabel.text = @"state 4";
                break;
            case 4:
                _statusLabel.text = @"state 5";
                break;
            default:
                break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    //_enhancerButton.hidden = YES;
    [super viewWillAppear:animated];
    [self setupSocket];
    [_socket connect];
    
    _loadingView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeCookieTerminator tintColor:[UIColor whiteColor] size:80.0f];
    _loadingView.frame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f);
    _loadingView.center = self.view.center;
    [self.view addSubview:_loadingView];
    [_loadingView startAnimating];
    
    _loadingMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 80)];
    _loadingMsg.center = CGPointMake(self.view.center.x, self.view.center.y + 50.0f);
    _loadingMsg.text = @"Waiting for other people to join the game";
    [_loadingMsg setTextColor:[UIColor whiteColor]];
    [_loadingMsg setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:_loadingMsg];
    
    if (_stage != kVote) {
        _timerLabel.hidden = YES;
    }
    for (UIButton *box in _avBoxs) {
        box.layer.cornerRadius = 25;
        [box.layer setMasksToBounds:YES];
        [box.layer setBorderWidth:1.5];
        box.userInteractionEnabled = NO;
        box.hidden = YES;
    }
    
    for (UIImageView *res in _avRes) {
        res.hidden = YES;
    }
    
    _day = 0;

    _statusLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark SocketIO

- (void)setupSocket {
    /* client try to connect to server */
    [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        [self setStage:kConnectionEstablished];
        OnAckCallback *callback = [_socket emitWithAck:@"joinGame" with:@[@{@"playerName": self.username}]];
        [callback timingOutAfter:5.0 callback:^(NSArray* data) {
            /* join game call back do nothing */
            NSLog(@"joinGame call back");
        }];
    }];
    
    // send Message contains ID, playerName, sessionID and DispatchRoleMsg
    [_socket on:@"dispatchRole" callback:^(NSArray * data, SocketAckEmitter * ack) {
        /* user got its rule, game is starting. */
        [self setStage: kGameStart];
        /* stop the loading view */
        [_loadingView stopAnimating];
        [_loadingView removeFromSuperview];
        [_loadingMsg removeFromSuperview];
        /* get role information. */
        NSDictionary *rr = [data objectAtIndex:0];
        _sessionId = rr[@"sessionId"];
        _playerId = [rr[@"id"] integerValue];
        NSDictionary *tmp = rr[@"data"];
        _role = [tmp[@"role"] integerValue];
        _nPlayers = [tmp[@"numOfPlayers"] integerValue];
        
        
        self.roleCard.role = _role;
        [_roleCard displayRole];
        [self moveRoleCard];
        
        // change status
        self.isAlive = [NSMutableArray arrayWithCapacity:_nPlayers];
        
        for (int idx = 0; idx < _nPlayers; idx ++) {
            [self.isAlive addObject:[NSNumber numberWithInt:1]];
        }
        _statusLabel.hidden = NO;
        
        [_avBoxs removeObjectsInRange:NSMakeRange(_nPlayers, _avBoxs.count - _nPlayers)];
        [_avRes removeObjectsInRange:NSMakeRange(_nPlayers, _avRes.count - _nPlayers)];
        /* show avatar button with animation */
        for (int i = 0; i < _nPlayers; i++) {
            UIButton* cur = [_avBoxs objectAtIndex:i];
            cur.hidden = NO;
        }
        
    }];
    
    [_socket on:@"night" callback:^(NSArray* data, SocketAckEmitter* ack) {
        /* get the current night's sequnce number. */
        _day++;
        self.backgroundImageView.alpha = 1.0;
        self.msgTableView.backgroundColor = [UIColor blackColor];
        NSString *msg1 = @"Night has come, please close your eyes.";
        NSString *msg2 = @"Wolves please open your eyes, and choose one to kill.";
        [_headView showNightTime];
        [_msgArray addObject: msg1];
        [_msgArray addObject: msg2];
        [_msgTableView reloadData];
        if (self.role  == 1) {
            self.stage = kKill;
            [self buttonClickEnable];
        } else {
        }
    }];
    
    // GamePortal Backend Server Event: systemInfo
    [_socket on:@"systemInfo" callback:^(NSArray* data, SocketAckEmitter* ack) {
        /* receive system msg from server. */
        // message that contains ID valued -1 and data a system log string
        NSString *str = [data objectAtIndex:0][@"data"];
        [_msgArray addObject: str];
        [_msgTableView reloadData];
    }];
    
    [_socket on:@"vote" callback:^(NSArray* data, SocketAckEmitter* ack) {
        _stage = kVote;
        [self buttonClickEnable];
        self.backgroundImageView.alpha = 1;
        NSString *votehint = @"Vote begins, please choose one player in 60 secs";
        [_msgArray addObject:votehint];
        [self.msgTableView reloadData];
    }];
    
    [_socket on:@"makeStatement" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [self stopBroadCast];
        self.backgroundImageView.alpha = 0.0;
        [_headView showDayTime];
        NSDictionary *rr = [data objectAtIndex: 0];
        NSString *un = rr[@"playerName"];
        NSString *uid = rr[@"ID"];
        if ([un isEqualToString:_username]) {
            [self setupTimer];
            [self startBroadCast];
            [self.stopStatementBtn setHidden:NO];
        }
        [self updateInterfaceWithAnimation:YES];
    }];
    
    [_socket on:@"killDecision" callback:^(NSArray * data, SocketAckEmitter * ack) {
        NSDictionary *rr = [data objectAtIndex: 0];
        long uid = [rr[@"data"] integerValue];
        if (uid < 0){
            NSLog(@"No one get killed");
        }
        else{
            [self.isAlive setObject:[NSNumber numberWithInt:0] atIndexedSubscript:uid];
            if (uid == _playerId) {
                //
            }
            UIButton *cur = [self.avBoxs objectAtIndex:uid];
            UIView *tmp = [[UIView alloc] initWithFrame: cur.frame];
            tmp.backgroundColor = [UIColor redColor];
            tmp.alpha = 0.5;
            [self.view addSubview:tmp];
        }
    }];
    
    [_socket on:@"gameOver" callback:^(NSArray * data, SocketAckEmitter * ack) {
        // TODO: game over, retry and restart game
        // list of all playes, who wins 0 : villigers, 1 : wolfs
        NSLog(@"game over");
    }];
}

- (void)setupTimer {
    _timerLabel.hidden = NO;
    if (![_timer isValid]) {
        _startDateTime = [NSDate date];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readTimer) userInfo:nil repeats:YES];
    }
}

- (void)buttonClickEnable {
    
    if (_stage == kVote || _stage == kKill) {
        NSLog(@"Vote!!!!!!!!!!!!!!!");
        for (UIButton *box in self.avBoxs) {
            box.userInteractionEnabled = YES;
        }
        [self setupTimer];
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

- (void)moveRoleCard {
    CGAffineTransform translate = CGAffineTransformMakeTranslation((self.view.bounds.size.width / 2 - 20) / 0.4, (self.view.bounds.size.height - 220) / 0.4);
    CGAffineTransform scale = CGAffineTransformMakeScale(0.4, 0.4);
    CGAffineTransform transform = CGAffineTransformConcat(translate, scale);
    
    [UIView beginAnimations:@"roleCardAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:2.0];
    self.roleCard.transform = transform;
    [UIView commitAnimations];
}

#pragma mark - TableView Delegate

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

#pragma mark - IBAction

- (IBAction)makeVoteDecision:(id)sender {
    int index = 0;
    for (UIButton *tmp in self.avBoxs) {
        if (sender == tmp) {
            NSLog(@"%d", index);
            break;
        }
        index++;
    }
    NSNumber *iid = [[NSNumber alloc] initWithInt:index];
    [_socket emit:@"kill" with:@[@{@"data": iid}]];
    // disable button interaction & invalid timer
    for (UIButton *tmp in self.avBoxs)
        tmp.userInteractionEnabled = NO;
    [_timer invalidate];
    _timerLabel.hidden = YES;
}

#pragma mark video chat

- (BOOL)isBroadcaster {
    return self.clientRole == AgoraRtc_ClientRole_Broadcaster;
}

- (VideoViewLayouter *)viewLayouter {
    if (!_viewLayouter) {
        _viewLayouter = [[VideoViewLayouter alloc] init];
    }
    return _viewLayouter;
}

- (AgoraYuvEnhancerObjc *)agoraEnhancer {
    if (!_agoraEnhancer) {
        _agoraEnhancer = [[AgoraYuvEnhancerObjc alloc] init];
        _agoraEnhancer.lighteningFactor = 0.7;
        _agoraEnhancer.smoothness = 1.0;
    }
    return _agoraEnhancer;
}

- (void)startBroadCast{
    _enhanceSwitch.hidden = NO;
    self.clientRole = AgoraRtc_ClientRole_Broadcaster;
    [self.rtcEngine setClientRole:self.clientRole withKey:nil];
    [self updateInterfaceWithAnimation:YES];
}

- (void)stopBroadCast{
    _enhanceSwitch.hidden = YES;
    self.clientRole = AgoraRtc_ClientRole_Audience;
    if (self.fullSession.uid == 0) {
        self.fullSession = nil;
    }
    [self.rtcEngine setClientRole:self.clientRole withKey:nil];
    [self updateInterfaceWithAnimation:YES];
}

- (void)replaceBackgroundImage{
    [self.backgroundImageView setAlpha:1.0];
}



- (void)setClientRole:(AgoraRtcClientRole)clientRole {
    _clientRole = clientRole;
    
    if (self.isBroadcaster) {
        self.shouldEnhancer = YES;
    }
    //[self updateButtonsVisiablity];
}

- (void)setIsMuted:(BOOL)isMuted {
    _isMuted = isMuted;
    [self.rtcEngine muteLocalAudioStream:isMuted];
    //[self.audioMuteButton setImage:[UIImage imageNamed:(isMuted ? @"btn_mute_cancel" : @"btn_mute")] forState:UIControlStateNormal];
}

- (void)setShouldEnhancer:(BOOL)shouldEnhancer {
    _shouldEnhancer = shouldEnhancer;
    if (shouldEnhancer) {
        [self.agoraEnhancer turnOn];
    } else {
        [self.agoraEnhancer turnOff];
    }
    [self.enhancerButton setImage:[UIImage imageNamed:(shouldEnhancer ? @"btn_beautiful_cancel" : @"btn_beautiful")] forState:UIControlStateNormal];
}

- (void)setVideoSessions:(NSMutableArray<VideoSession *> *)videoSessions {
    _videoSessions = videoSessions;
    if (self.remoteContainerView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)setFullSession:(VideoSession *)fullSession {
    _fullSession = fullSession;
    if (self.remoteContainerView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (IBAction)doEnhancerPressed:(id)sender {
    self.shouldEnhancer = !self.shouldEnhancer;
}

- (IBAction)stopStatement:(id)sender {
    [self stopBroadCast];
    [self.stopStatementBtn setHidden:YES];
    OnAckCallback *callback = [_socket emitWithAck:@"finishStatement" with:@[@{@"id": [NSNumber numberWithLong:self.playerId]}]];
    [callback timingOutAfter:5.0 callback:^(NSArray* data) {
        /* join game call back do nothing */
        NSLog(@"finishStatement call back");
    }];
    
}

- (void)changeEnhanceMode {
    self.shouldEnhancer = !self.shouldEnhancer;
}

/*
- (void)updateButtonsVisiablity {
     [self.broadcastButton setImage:[UIImage imageNamed:self.isBroadcaster ? @"btn_join_cancel" : @"btn_join"] forState:UIControlStateNormal];
     for (UIButton *button in self.sessionButtons) {
     button.hidden = !self.isBroadcaster;
     }
}
*/

- (void)leaveChannel {
    [self setIdleTimerActive:YES];
    
    [self.rtcEngine setupLocalVideo:nil];
    [self.rtcEngine leaveChannel:nil];
    if (self.isBroadcaster) {
        [self.rtcEngine stopPreview];
    }
    
    for (VideoSession *session in self.videoSessions) {
        [session.hostingView removeFromSuperview];
    }
    [self.videoSessions removeAllObjects];
    
    [self.agoraEnhancer turnOff];
    
}

- (void)setIdleTimerActive:(BOOL)active {
    [UIApplication sharedApplication].idleTimerDisabled = !active;
}

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateInterfaceWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterface];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self updateInterface];
    }
}

- (void)updateInterface {
    NSArray *displaySessions;
    if (!self.isBroadcaster && self.videoSessions.count) {
        displaySessions = [self.videoSessions subarrayWithRange:NSMakeRange(1, self.videoSessions.count - 1)];
    } else {
        displaySessions = [self.videoSessions copy];
    }
    
    [self.viewLayouter layoutSessions:displaySessions fullSession:self.fullSession inContainer:self.remoteContainerView];
    [self setStreamTypeForSessions:displaySessions fullSession:self.fullSession];
}

- (void)setStreamTypeForSessions:(NSArray<VideoSession *> *)sessions fullSession:(VideoSession *)fullSession {
    if (fullSession) {
        for (VideoSession *session in sessions) {
            [self.rtcEngine setRemoteVideoStream:session.uid type:(session == self.fullSession ? AgoraRtc_VideoStream_High : AgoraRtc_VideoStream_Low)];
        }
    } else {
        for (VideoSession *session in sessions) {
            [self.rtcEngine setRemoteVideoStream:session.uid type:AgoraRtc_VideoStream_High];
        }
    }
}

- (void)addLocalSession {
    VideoSession *localSession = [VideoSession localSession];
    [self.videoSessions addObject:localSession];
    [self.rtcEngine setupLocalVideo:localSession.canvas];
    [self updateInterfaceWithAnimation:YES];
}

- (VideoSession *)fetchSessionOfUid:(NSUInteger)uid {
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            return session;
        }
    }
    return nil;
}

- (VideoSession *)videoSessionOfUid:(NSUInteger)uid {
    VideoSession *fetchedSession = [self fetchSessionOfUid:uid];
    if (fetchedSession) {
        return fetchedSession;
    } else {
        VideoSession *newSession = [[VideoSession alloc] initWithUid:uid];
        [self.videoSessions addObject:newSession];
        [self updateInterfaceWithAnimation:YES];
        return newSession;
    }
}

#pragma mark - Agora Media SDK

- (void)loadAgoraKit {
    self.rtcEngine = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    [self.rtcEngine setChannelProfile:AgoraRtc_ChannelProfile_LiveBroadcasting];
    [self.rtcEngine enableDualStreamMode:YES];
    [self.rtcEngine enableVideo];
    [self.rtcEngine setVideoProfile:self.videoProfile swapWidthAndHeight:YES];
    [self.rtcEngine setClientRole:self.clientRole withKey:nil];
    if (self.isBroadcaster) {
        [self.rtcEngine startPreview];
    }
    
    [self addLocalSession];
    
    
    int code = [self.rtcEngine joinChannelByKey:nil channelName:self.roomName info:nil uid:0 joinSuccess:nil];
    if (code == 0) {
        [self setIdleTimerActive:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertString:[NSString stringWithFormat:@"Join channel failed: %d", code]];
        });
    }
    
    if (self.isBroadcaster) {
        self.shouldEnhancer = YES;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    VideoSession *userSession = [self videoSessionOfUid:uid];
    [self.rtcEngine setupRemoteVideo:userSession.canvas];
}

// hide status bar

- (BOOL)prefersStatusBarHidden {
    return YES;
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
