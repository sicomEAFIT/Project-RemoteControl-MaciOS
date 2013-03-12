//
//  MainViewController.m
//  Controls-Sever
//
//  Created by Mateo Olaya Bernal on 10/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize addressLabel, logLabel, statusImage, numClients, portLabel, maxConnections, maxConnectionsCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        isConnected = NO;
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(checkStatus:) userInfo:nil repeats:YES];
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return self;
}

- (void)checkStatus:(NSTimer *)timer
{
    // Ver cuantos clientes hay conectados y mostrarlos
    [numClients setStringValue:[NSString stringWithFormat:@"%ld clientes conectados",
                                (unsigned long)[clients count]]];
    
    if (isConnected) {
        [statusImage setImage:[NSImage imageNamed:@"online.png"]]; //Luz verde
    } else {
        [statusImage setImage:[NSImage imageNamed:@"offline.png"]]; //Luz roja
    }
    
}
- (IBAction)kernel:(id)sender {
    NSButton *button = (NSButton *)sender;
    
    if (button.tag == 10) { // Iniciar/Parar el servidor
        
        if (!isConnected) {
            //Conectar el servidor
            if ([[portLabel stringValue] integerValue] > 1024 && [[portLabel stringValue] integerValue] < 65534) {
                [socket acceptOnPort:[[portLabel stringValue] integerValue] error:nil];
                [addressLabel setStringValue:[[[NSHost currentHost] addresses] objectAtIndex:1]];
                
                [logLabel addLine:@"[root: Servidor conectado]"];
                [portLabel setEditable:NO];
                isConnected = YES;
            } else {
                [[NSAlert alertWithMessageText:@"Advertencia: Puerto no valido" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Puerto no valido, elija un puerto entre el 1024 y el 65535. Puertos menores a 1024 estan reservados por el sistema."] runModal];
            }
        } else {
            //Desconectar servidor
            [self disconnectAllUsers:YES server:YES];
            [addressLabel setStringValue:@""];
            
            [logLabel addLine:@"[root: Servidor desconectado]"];
            [portLabel setEditable:YES];
            isConnected = NO;
        }
        
        
        
    }
    
    if (button.tag == 11) { // Desconectar a todos los clientes
        [self disconnectAllUsers:YES server:NO];
    }
}

- (void)disconnectAllUsers:(BOOL)usr server:(BOOL)srv
{
    if (usr) {
        for (GCDAsyncSocket *sock in clients) {
            [sock disconnect]; //Desconectar cliente
        }
    }
    
    if (srv) {
        [socket disconnect]; //Desconectar servidor
    }

}

- (IBAction)clear:(id)sender {
    [logLabel setString:@""];
}

- (IBAction)connectionsChange:(id)sender {
    NSStepper *step = (NSStepper *)sender;
    [maxConnections setStringValue:[NSString stringWithFormat:@"%ld Conexion (es) maxima (s)", step.integerValue]];
}



#pragma mark - Socket delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    if (!clients) {
        clients = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    NSAlert *confirmConnection = [[NSAlert alloc] init];
    [confirmConnection setMessageText:[NSString stringWithFormat:@"¿Aceptar la conexion de: %@?", [newSocket connectedHost]]];
        
    [confirmConnection setInformativeText:@"Este dispositivo podra contralar su equipo de forma remota."];
    [confirmConnection addButtonWithTitle:@"Si"];
    [confirmConnection addButtonWithTitle:@"No"];
    [confirmConnection setAlertStyle:NSWarningAlertStyle];
        
    if([confirmConnection runModal] == 1001) //1000 <- Es si, 1001 <- Es no
    {
        [newSocket disconnect];
        return;
    }
    
    if ([clients count] < [maxConnectionsCounter integerValue]) {
        @synchronized (clients)
        {
            [clients addObject:newSocket];
        }
        [logLabel addLine:[NSString stringWithFormat:@"[root: Nueva conexion de %@]", [newSocket connectedHost]]];
        
        [newSocket readDataWithTimeout:-1 tag:0];
    } else {
        [newSocket disconnect];
        [[NSAlert alertWithMessageText:@"Error: Numero maximo de conexiones superado" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"No a sido posible la conexion debido a que se supero el numero maximo de conexiones, desconecte un cliente y vuelva a intentarlo"] runModal];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [logLabel addLine:[NSString stringWithFormat:@"[%@: %@]", [sock connectedHost], msg]];
    
    [MOInterprete execute:msg];
    
    [sock writeData:[[NSString stringWithFormat:@"OK: %@", [sock connectedHost]] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [logLabel addLine:@"[root: Se desconecto un cliente]"];
		
    @synchronized(clients)
    {
        [clients removeObject:sock];
    }
}

@end

@implementation NSTextView (MainView)

- (void)addLine:(NSString *)string
{
    [self setString:[NSString stringWithFormat:@"%@%@\n", self.string, string]];
}

@end