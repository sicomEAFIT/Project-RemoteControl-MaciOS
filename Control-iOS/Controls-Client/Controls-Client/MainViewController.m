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
    
    switch (button.tag) {
        case 11: // Boton "play / pause"
            send = @"itunes play";
            break;
        case 12: // Boton ">>"
            send = @"itunes next";
            break;
        case 13: // Boton "<<"
            send = @"itunes prev";
            break;
        case 14: // Boton "<"
            send = @"keyboard 123";
            break;
        case 15: // Boton "v"
            send = @"keyboard 125";
            break;
        case 16: // Boton ">"
            send = @"keyboard 124";
            break;
        case 17: // Boton "Espacio"
            send = @"keyboard 49";
            break;
        case 18: // Boton "^"
            send = @"keyboard 126";
            break;
        case 19: // Boton "Enter"
            send = @"keyboard 36";
            break;
        case 20: // Boton "Borrar"
            send = @"keyboard 51";
            break;
        default:
            send = @"";
            break;
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
    usleep(800);
}

- (IBAction)sendHalt:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¿Esta seguro?" message:@"Si continua se cerrarar la conexion, y se apagara el equipo, ¿Quiere continuar?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Si", nil];
    [alert setDelegate:self];
    [alert setTag:10];
    [alert show];
}

#pragma mark - UIAlertView DElegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10) {
        NSLog(@"%d", buttonIndex);
        if (buttonIndex == 1) {
            NSString *send = @"system halt";
            [_socket writeData:[send dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [_socket readDataWithTimeout:-1 tag:0];
        }
    }
}

#pragma mark - Keyboard responder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [addressLabel resignFirstResponder];
    [portLabel resignFirstResponder];
}

#pragma mark - Socket Delegte

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [_socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}
@end
