//
//  MOInterprete.m
//  Controls-Sever
//
//  Created by Mateo Olaya Bernal on 10/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import "MOInterprete.h"

@implementation MOInterprete

+ (void)execute:(NSString *)command
{
    //el interprete funciona con un comando seguido de una accion, ejemplo:{ comando hacer }
    NSArray *cmd = [command componentsSeparatedByString:@" "];
    
    //Comandos para iTunes
    if ([[cmd objectAtIndex:0] isEqualToString:@"itunes"]) {
        if ([[cmd objectAtIndex:1] isEqualToString:@"play"] || [[cmd objectAtIndex:1] isEqualToString:@"pause"]) { //Si esta en pausa, reproduce la cancion, si esta reproduciondo pausa la cancion.
            [self appleScript:@"tell app \"iTunes\" to playpause"];
        }
        if ([[cmd objectAtIndex:1] isEqualToString:@"next"]) { // Reproduce la siguiente cancion.
            [self appleScript:@"tell app \"iTunes\" to next track"];
        }
        if ([[cmd objectAtIndex:1] isEqualToString:@"prev"]) { // Reproduce la siguiente cancion.
            [self appleScript:@"tell app \"iTunes\" to previous track"];
        }
    }
    
    //Comando de volumen del sistema
    if ([[cmd objectAtIndex:0] isEqualToString:@"volume"]) {
        [self appleScript:[NSString stringWithFormat:@"set volume output volume %ld", (long)[[cmd objectAtIndex:1] integerValue]]];
    }
    
    if ([[cmd objectAtIndex:0] isEqualToString:@"keyboard"]) {
        if ([[cmd objectAtIndex:1] integerValue] > -1 && [[cmd objectAtIndex:1] integerValue] < 127) {
            [self appleScript:[NSString stringWithFormat:@"tell application \"System Events\" to key code %ld", (long)[[cmd objectAtIndex:1] integerValue]]];
        }
    }
}

// Ejecutar comandos como AppleScript

+ (void)appleScript:(NSString *)cmd
{
    NSAppleScript *appsc = [[NSAppleScript alloc] initWithSource:cmd];
    [appsc executeAndReturnError:nil];
}

@end
