//
//  MainViewController.m
//  Controls-Client
//
//  Created by Mateo Olaya Bernal on 10/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize socket = _socket;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(checkStatus:) userInfo:nil repeats:YES];
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self kernel:nil];
    
//    NSString *send = @"Hola soy un iphone";
//    [_socket writeData:[send dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [_socket readDataWithTimeout:-1 tag:0];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkStatus:(NSTimer *)timer
{
    if ([_socket isConnected]) {
        [serverStatusImage setImage:[UIImage imageNamed:@"online.png"]];
    } else {
        [serverStatusImage setImage:[UIImage imageNamed:@"offline.png"]];
    }
}

- (IBAction)sendCommand:(id)sender {
    NSString *send;
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 11) {
        send = @"itunes play";
    }
    if (button.tag == 12) {
        send = @"itunes next";
    }
    if (button.tag == 13) {
        send = @"itunes prev";
    }
    
    [_socket writeData:[send dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_socket readDataWithTimeout:-1 tag:0];
}

- (IBAction)kernel:(id)sender {
    if ([_socket isConnected]) {
        [_socket disconnect];
    } else {
        
        NSError *err;
        if(![_socket connectToHost:[addressLabel text] onPort:[[portLabel text] integerValue] error:nil])
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:err.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
}

- (IBAction)sendVolume:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSString *send = [NSString stringWithFormat:@"volume %d", (int)slider.value];
    
    [_socket writeData:[send dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_socket readDataWithTimeout:-1 tag:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [addressLabel resignFirstResponder];
    [portLabel resignFirstResponder];
}

#pragma mark - Socket Delegte

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [logLabel setText:[NSString stringWithFormat:@"%@[Se establecio una conexion con: %@, via puerto:%d]\n", logLabel.text, host, port]];
    [_socket readDataWithTimeout:-1 tag:0];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [logLabel setText:[NSString stringWithFormat:@"%@%@\n", logLabel.text, msg]];
    [_socket readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}
@end
