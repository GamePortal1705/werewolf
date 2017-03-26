//
//  GameViewController.h
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import <UIKit/UIKit.h>
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

@end
