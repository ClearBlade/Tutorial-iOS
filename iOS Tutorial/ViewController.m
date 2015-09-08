//
//  ViewController.m
//  iOS Tutorial
//
//  Created by Steve W. Manweiler on 9/3/15.
//  Copyright (c) 2015 ClearBlade, Inc. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>

NSString *SystemKey = @"9a83c2de0ad4de9fddab90fe9c7a";
NSString *SystemSec = @"9A83C2DE0A9CE1B3F7A2A6E0C72C";
NSString *collectionId = @"9cb0c2de0aa2edc983fbecec8e8e01";
NSString *platformURL = @"https://rtp.clearblade.com";
NSString *messagingURL = @"rtp.clearblade.com";
NSString *userEmail = @"test@clearblade.com";
NSString *userPassword = @"clearblade";

@interface ViewController ()

@property(nonatomic, strong) NSMutableArray *parts;
@property(nonatomic, assign) NSInteger curPart;
@property(nonatomic, strong) NSString *messagingText;
@property(nonatomic, strong) CBMessageClient *messageClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messagingText = @"";
    self.textViewText = @"You shouldn't see this!";
    [self setupTutorial];
    [self playAPartInThis];
    [self.activityIndicator stopAnimating];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shutUp)];
    [self.view addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceed) name:@"Proceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oops) name:@"Oops" object:nil];
}

-(void)shutUp {
    [self.publishString resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) loadPartFile:(NSString *)filename {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    if (htmlData) {
        [self.webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    } else {
        NSLog(@"No such luck");
    }
}

-(void) doDefaultSetup {
    NSLog(@"Do default setup");
    self.text1.hidden = YES;
    self.text2.hidden = YES;
    self.text3.hidden = YES;
    self.textView.hidden = YES;
    self.messagingView.hidden = YES;
}

-(void) doLoginSetup {
    [self doDefaultSetup];
    self.text2.hidden = NO;
    self.text3.hidden = NO;
    self.text3.secureTextEntry = YES;
    self.text2.text = userEmail;
    self.text3.text = userPassword;
}

-(void) doCityStateZipSetup {
    [self doDefaultSetup];
    self.text1.hidden = NO;
    self.text2.hidden = NO;
    self.text3.hidden = NO;
    self.text3.secureTextEntry = NO;
    self.text1.text = @"Austin";
    self.text2.text = @"TX";
    self.text3.text = @"US";
}

-(void) doBigText {
    [self doDefaultSetup];
    self.textView.hidden = NO;
    self.textView.userInteractionEnabled = NO;
    self.textView.text = self.textViewText;
}

-(void) doMessagingSetup {
    [self doDefaultSetup];
    self.publishResults.text = self.messagingText;
    self.messagingView.hidden = NO;
}

-(void) doPart1 {
    NSLog(@"In doPart1");
    //  Connect to platform anonymously
    NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:platformURL, CBSettingsOptionServerAddress,
                          messagingURL, CBSettingsOptionMessagingAddress,
                          nil];
    [ClearBlade initSettingsWithSystemKey:SystemKey withSystemSecret:SystemSec withOptions:opts withSuccessCallback:^(ClearBlade *stuff) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
    } withErrorCallback:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
    }];
}

-(void) doPart1Success {
    NSLog(@"In doPart1Success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart2 {
    NSLog(@"In doPart2");
    NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:platformURL, CBSettingsOptionServerAddress,
                          messagingURL, CBSettingsOptionMessagingAddress,
                          self.text2.text, CBSettingsOptionEmail,
                          self.text3.text, CBSettingsOptionPassword,
                          nil];
    [ClearBlade initSettingsWithSystemKey:SystemKey withSystemSecret:SystemSec withOptions:opts withSuccessCallback:^(ClearBlade *stuff) {
        self.messageClient = [[CBMessageClient alloc] init];
        self.messageClient.delegate = self;
        [self.messageClient connect];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
    } withErrorCallback:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
    }];
}

-(void) doPart2Success {
    NSLog(@"In doPart2Success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart3 {
    NSLog(@"In doPart3");
    // Fetch data from collection
    CBQuery *weatherQuery = [CBQuery queryWithCollectionID:collectionId];
    [weatherQuery fetchWithSuccessCallback:^(CBQueryResponse *response) {
        NSMutableArray *found = response.dataItems;
        NSLog(@"FETCH GOT: %@", found);
        [self processQueryResults:found];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
    } withErrorCallback:^(NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
    }];
}

-(void) doPart3Success {
    NSLog(@"In doPart3Success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart4 {
    NSLog(@"In doPart4");
    // Call a service
    self.textViewText = @"";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.text1.text, @"city",
                            self.text2.text, @"state",
                            self.text3.text, @"country",
                            nil];
    [CBCode executeFunction:@"ServicePart4" withParams:params withSuccessCallback:^(NSString *results) {
        NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        if (e != nil) {
            NSLog(@"JSON DECODE FAILED");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
            return;
        }
        self.textViewText = (NSString *)[dict objectForKey:@"results"];
        self.textView.text = self.textView.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
    } withErrorCallback:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
    }];
}

-(void) doPart4Success {
    NSLog(@"In doPart4Success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart5 {
    NSLog(@"In doPart5");
    // Call a service again
    self.textViewText = @"";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.text1.text, @"city",
                            self.text2.text, @"state",
                            self.text3.text, @"country",
                            nil];
    [CBCode executeFunction:@"ServicePart5" withParams:params withSuccessCallback:^(NSString *results) {
        NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        if (e != nil) {
            NSLog(@"JSON DECODE FAILED");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
            return;
        }
        NSDictionary *tmp = [dict objectForKey:@"results"];
        self.textViewText = [NSString stringWithFormat:@"Temperature: %@, Weather: %@", tmp[@"temperature"], tmp[@"weather"]];
        self.textView.text = self.textViewText;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
    } withErrorCallback:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
    }];
}

-(void) doPart5Success {
    NSLog(@"In doPart5Success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart6 {
    NSLog(@"In doPart6");
    self.textViewText = @"";
    self.textView.text = @"";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.text1.text, @"city",
                            self.text2.text, @"state",
                            self.text3.text, @"country",
                            nil];
    [CBCode executeFunction:@"ServicePart6" withParams:params withSuccessCallback:^(NSString *results) {
        NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        if (e != nil) {
            NSLog(@"JSON DECODE FAILED");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
            return;
        }
        self.textViewText = (NSString *)[dict objectForKey:@"results"];
        self.textView.text = self.textView.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
    } withErrorCallback:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Oops" object:nil];
    }];
}

-(void) doPart6Success {
    NSLog(@"In doPart6Success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart7 {
    NSLog(@"In doPart7");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void) doPart7Really {
    NSLog(@"In doPart7Really");
    // Messaging sub/pub/etc.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Proceed" object:nil];
}

-(void)setupTutorial {
    self.curPart = 0;
    self.parts = [NSMutableArray array];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part1"
                                                andTitle:@"Part 1 - Initializing"
                                          andButtonLabel:@"Connect to Platform"
                                                andSetup:@selector(doDefaultSetup)
                                             andSelector:@selector(doPart1)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part1Success"
                                                andTitle:@"Part 1 - Success"
                                          andButtonLabel:@"Next"
                                                andSetup:@selector(doDefaultSetup)
                                             andSelector:@selector(doPart1Success)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part2"
                                                andTitle:@"Part 2 Authenticate"
                                          andButtonLabel:@"Login"
                                                andSetup:@selector(doLoginSetup)
                                             andSelector:@selector(doPart2)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part2Success"
                                                andTitle:@"Part 2 Success"
                                          andButtonLabel:@"Next"
                                                andSetup:@selector(doDefaultSetup)
                                             andSelector:@selector(doPart2Success)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part3"
                                                andTitle:@"Part 3 - Collections"
                                          andButtonLabel:@"Fetch Your Data"
                                                andSetup:@selector(doDefaultSetup)
                                             andSelector:@selector(doPart3)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part3Success"
                                                andTitle:@"Part 3 - Success"
                                          andButtonLabel:@"Click to start Part 4"
                                                andSetup:@selector(doBigText)
                                             andSelector:@selector(doPart3Success)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part4"
                                                andTitle:@"Part 4 - Create a service"
                                          andButtonLabel:@"Call your service"
                                                andSetup:@selector(doCityStateZipSetup)
                                             andSelector:@selector(doPart4)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part4Success"
                                                andTitle:@"Part 4 - Success"
                                          andButtonLabel:@"Click to start Part 5"
                                                andSetup:@selector(doBigText)
                                             andSelector:@selector(doPart4Success)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part5"
                                                andTitle:@"Part 5 - Getting busy with logic"
                                          andButtonLabel:@"Check your logic"
                                                andSetup:@selector(doCityStateZipSetup)
                                             andSelector:@selector(doPart5)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part5Success"
                                                andTitle:@"Part 5 - Success"
                                          andButtonLabel:@"Go To Part 6"
                                                andSetup:@selector(doBigText)
                                             andSelector:@selector(doPart5Success)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part6"
                                                andTitle:@"Part 6 - Libraries"
                                          andButtonLabel:@"Check Your Library"
                                                andSetup:@selector(doCityStateZipSetup)
                                             andSelector:@selector(doPart6)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part6Success"
                                                andTitle:@"Part 6 - Success"
                                          andButtonLabel:@"Go To Part 7"
                                                andSetup:@selector(doBigText)
                                             andSelector:@selector(doPart6Success)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part7"
                                                andTitle:@"Part 7 - Messaging"
                                          andButtonLabel:@"Let's start messaging"
                                                andSetup:@selector(doDefaultSetup)
                                             andSelector:@selector(doPart7)]];
    [self.parts addObject:[[Part alloc] initWithFilename:@"Part7Really"
                                                andTitle:@"Part 7 - Messaging"
                                          andButtonLabel:@"Shouldn't see this button"
                                                andSetup:@selector(doMessagingSetup)
                                             andSelector:@selector(doPart7Really)]];
    
}

-(void) playAPartInThis {
    [self hideShowButtons];
    Part *ourPart = [self.parts objectAtIndex:self.curPart];
    [self callTheDangSelector:ourPart.setupStep];
    self.partLabel.text = ourPart.title;
    [self.nextButton setTitle:ourPart.buttonLabel forState:UIControlStateNormal];
    [self loadPartFile:ourPart.htmlFilename];
}

-(IBAction) nextButtonPressed:(id)sender {
    NSLog(@"DA BUTTON WAS PRESSED");
    if (self.curPart < self.parts.count) {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        Part *ourPart = [self.parts objectAtIndex:self.curPart];
        [self callTheDangSelector:ourPart.tutorialStep];
    }
}

-(IBAction) backButtonPressed:(id)sender {
    self.curPart--;
    [self playAPartInThis];
}
     
-(void) proceed {
    [self.activityIndicator stopAnimating];
    self.curPart ++;
    if (self.curPart >= self.parts.count) {
        [self hideShowButtons];
        return;
    }
    [self playAPartInThis];
}

-(void) oops {
    //  Error occurred -- put up a dialog. TODO -- add error message
    [self.activityIndicator stopAnimating];
}

-(IBAction) subscribePressed:(id)sender {
    NSLog(@"Trying to subscribe");
    [self.messageClient subscribeToTopic:@"/Weather"];
}

-(IBAction) publishPressed:(id)sender {
    NSString *msg = self.publishString.text;
    [self.messageClient publishMessage:msg toTopic:@"/Weather"];
}

-(void) callTheDangSelector:(SEL)tutorialStep {
    // What a cluster
    IMP imp = [self methodForSelector:tutorialStep];
    void (*func)(id, SEL) = (void *)imp;
    func(self, tutorialStep);
}

-(void) hideShowButtons {
    if (self.curPart == 0) {
        self.backButton.hidden = YES;
    } else {
        self.backButton.hidden = NO;
    }
    
    if (self.curPart >= self.parts.count - 1) {
        self.nextButton.hidden = YES;
    } else {
        self.nextButton.hidden = NO;
    }
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void) processQueryResults:(NSMutableArray *)results {
    [self.textView setFont:[UIFont systemFontOfSize:8]];
    self.textViewText = @"";
    for (id obj in results) {
        CBItem *res = (CBItem *)obj;
        NSDictionary *stuff = res.data;
        NSString *row = [NSString stringWithFormat:@"%@ %@ %@: Temperature: %@, Weather: %@\n",
                         [stuff objectForKey:@"city"],
                         [stuff objectForKey:@"state"],
                         [stuff objectForKey:@"country"],
                         [stuff objectForKey:@"temperature"],
                         [stuff objectForKey:@"weather"]];
        self.textViewText = [self.textViewText stringByAppendingString:row];
    }
}

#pragma mark Message Client Delegate Stuff

-(void)messageClientDidConnect:(CBMessageClient *)client {
    NSLog(@"Connect worked");
}

-(void) messageClient:(CBMessageClient *)client didPublishToTopic:(NSString *)topic withMessage:(CBMessage *)message {
    NSLog(@"DID PUBLISH");
}

-(void) messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    NSLog(@"Got message %@", message.payloadText);
    self.messagingText = [NSString stringWithFormat:@"%@/%@: %@\n", self.messagingText, message.topic, message.payloadText];
    self.publishResults.text = self.messagingText;
}

-(void) messageClient:(CBMessageClient *)client didSubscribe:(NSString *)topic {
    NSLog(@"Did subscribe");
}

@end

@implementation Part

-(id) initWithFilename:(NSString *)filename
              andTitle:(NSString *)title
        andButtonLabel:(NSString *)buttonLabel
              andSetup:(SEL)setup
           andSelector:(SEL)func {
    self = [super init];
    self.htmlFilename = filename;
    self.title = title;
    self.buttonLabel = buttonLabel;
    self.setupStep = setup;
    self.tutorialStep = func;
    return self;
}

@end
