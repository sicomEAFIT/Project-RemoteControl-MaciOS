//
//  MOInterprete.h
//  Controls-Sever
//
//  Created by Mateo Olaya Bernal on 10/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOInterprete : NSObject

+ (void)execute:(NSString *)command;
+ (void)appleScript:(NSString *)cmd;

@end
