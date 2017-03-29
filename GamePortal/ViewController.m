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
#import "FUIButton.h"
#import "FUITextField.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet FUITextField *inputTextField;
@property (weak, nonatomic) IBOutlet FUIButton *launchBtn;

@property CALayer *bottomLine;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputTextField.delegate = self;
    
    _launchBtn.buttonColor = [UIColor turquoiseColor];
    _launchBtn.shadowColor = [UIColor greenSeaColor];
    _launchBtn.shadowHeight = 3.0f;
    _launchBtn.cornerRadius = 6.0f;
    _launchBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [_launchBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [_launchBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    _inputTextField.font = [UIFont flatFontOfSize:16];
    _inputTextField.backgroundColor = [UIColor clearColor];
    _inputTextField.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    _inputTextField.textFieldColor = [UIColor clearColor];
    _inputTextField.borderColor = [UIColor turquoiseColor];
    _inputTextField.borderWidth = 2.0f;
    _inputTextField.cornerRadius = 3.0f;
    
    _bottomLine = [CALayer layer];
    _bottomLine.frame = CGRectMake(0.0f, _inputTextField.frame.size.height - 1, _inputTextField.frame.size.width, 1.0f);
    _bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    [_inputTextField setBorderStyle:UITextBorderStyleNone];
    [_inputTextField.layer addSublayer:_bottomLine];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _bottomLine.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
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
