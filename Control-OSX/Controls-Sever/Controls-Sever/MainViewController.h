//
//  MainViewController.h
//  Controls-Sever
//
//  Created by Mateo Olaya Bernal on 10/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "MOInterprete.h"

@interface MainViewController : NSViewController <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *socket;
    NSMutableArray *clients;
    BOOL isConnected;
}
@property (unsafe_unretained) IBOutlet NSTextField *addressLabel;
@property (unsafe_unretained) IBOutlet NSTextView *logLabel;
@property (unsafe_unretained) IBOutlet NSImageView *statusImage;
@property (unsafe_unretained) IBOutlet NSTextField *numClients;
@property (unsafe_unretained) IBOutlet NSTextField *portLabel;
@property (unsafe_unretained) IBOutlet NSTextField *maxConnections;
@property (unsafe_unretained) IBOutlet NSStepper *maxConnectionsCounter;

- (IBAction)kernel:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)connectionsChange:(id)sender;


@end

@interface NSTextView (MainView)

- (void)addLine:(NSString *)string;

@end