//
//  LoggerManager.h
//  Apollo
//
//  Created by TienPham on 5/18/17.
//  Copyright © 2017 Vinasource company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoggerManager : NSObject

+ (LoggerManager *)sharedInstance;

- (void)startCPUMemoryLogger;
- (void)getCPUUsage;
- (void)getMemoryStatistics;
- (void)redirectNSlogToDocumentFolder;

@end
