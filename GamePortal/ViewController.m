//
//  ViewController.m
//  GamePortal
//
//  Created by 甘宏 on 3/18/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

// to tell the truth I know nothing .....


#import "ViewController.h"
#import "GameViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property CALayer *bottomLine;
@property (weak, nonatomic) IBOutlet UIButton *launchBtn;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputTextField.delegate = self;
    
    _bottomLine = [CALayer layer];
    _bottomLine.frame = CGRectMake(0.0f, _inputTextField.frame.size.height - 1, _inputTextField.frame.size.width, 1.0f);
    _bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    [_inputTextField setBorderStyle:UITextBorderStyleNone];
    [_inputTextField.layer addSublayer:_bottomLine];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIView animateWithDuration:1.0f
                          delay:0
                        options:UIViewAnimationOptionRepeat
                     animations:^{ self.launchBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);}
                     completion: NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputTextField resignFirstResponder];
    return NO;
}

// segue: passing argument

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"launchgame"]) {
        GameViewController *gvc = (GameViewController *)segue.destinationViewController;
        [gvc setStage:kInitial];
        [gvc setUsername:self.inputTextField.text];
        [gvc setVideoProfile:AgoraRtc_VideoProfile_480P];
        [gvc setClientRole:AgoraRtc_ClientRole_Audience];
    }
}

@end
