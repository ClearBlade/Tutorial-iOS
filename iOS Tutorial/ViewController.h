//
//  ViewController.h
//  iOS Tutorial
//
//  Created by Steve W. Manweiler on 9/3/15.
//  Copyright (c) 2015 ClearBlade, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBAPI.h"

@interface Part: NSObject

@property (nonatomic, strong) NSString *htmlFilename;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *buttonLabel;
@property SEL tutorialStep;
@property SEL setupStep;

-(id) initWithFilename:(NSString *)filename
              andTitle:(NSString *)title
        andButtonLabel:(NSString *)buttonLabel
              andSetup:(SEL)setup
           andSelector:(SEL)func;

@end

@interface ViewController : UIViewController <CBMessageClientDelegate>

@property (nonatomic, weak) IBOutlet UILabel *partLabel;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *stopIt;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) IBOutlet UITextField *text1, *text2, *text3;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSString *textViewText;

//  The last messaging view is right here...
@property (nonatomic, weak) IBOutlet UIView *messagingView;
@property (nonatomic, weak) IBOutlet UITextField *publishString;
@property (nonatomic, weak) IBOutlet UITextView *publishResults;

-(IBAction) nextButtonPressed:(id)sender;
-(IBAction) backButtonPressed:(id)sender;
-(IBAction) subscribePressed:(id)sender;
-(IBAction) publishPressed:(id)sender;

@end

