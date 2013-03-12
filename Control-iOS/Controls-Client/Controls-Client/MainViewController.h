//
//  MainViewController.h
//  Controls-Client
//
//  Created by Mateo Olaya Bernal on 10/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface MainViewController : UIViewController <GCDAsyncSocketDelegate>
{
    BOOL isConnected;
    __weak IBOutlet UIImageView *serverStatusImage;    
    __weak IBOutlet UITextField *addressLabel;
    __weak IBOutlet UITextField *portLabel;
}
@property (nonatomic, strong) GCDAsyncSocket *socket;

- (IBAction)sendCommand:(id)sender;
- (IBAction)kernel:(id)sender;
- (IBAction)sendVolume:(id)sender;
- (IBAction)sendHalt:(id)sender;

@end
