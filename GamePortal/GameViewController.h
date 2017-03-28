//
//  GameViewController.h
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
@import SocketIO;

typedef enum {
    kInitial,
    kConnectionEstablished,
    kGameStart,
    kNight,
    kVote,
    kStatement
} Stage;

@interface GameViewController : UIViewController

@property NSString *username;
@property Stage stage;
@property NSString *sessionId;
@property NSString *role;
@property long playerId;

//Video chat

@property (copy, nonatomic) NSString *roomName;
@property (assign, nonatomic) AgoraRtcClientRole clientRole;
@property (assign, nonatomic) AgoraRtcVideoProfile videoProfile;

@end
