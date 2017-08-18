//
//  UIViewController+fzextention.m
//  runtime黑魔法
//
//  Created by fuzhong on 2017/6/12.
//  Copyright © 2017年 fuzhong. All rights reserved.
//

#import "UIViewController+fzextention.h"
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "NSLogger.h"
#import "LoggerManager.h"

@implementation UIViewController (fzextention)

+(void)load
{
    
    //Method Memorytest = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    //didReceiveMemoryWarning
    Method Memorytest = class_getInstanceMethod(self, NSSelectorFromString(@"didReceiveMemoryWarning"));
    
    Method teststart = class_getInstanceMethod(self, @selector(XMdelloc));
    
    method_exchangeImplementations(Memorytest, teststart);
    
}

- (void)getDevidefzDiskspace
{
    //    if (!self.fztimer) {
    //       LoggerApp(1,@"fztimer--: %@",self.fztimer);
    //      self.fztimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(functionTimer) userInfo:nil repeats:YES];
    //    }
    [[LoggerManager sharedInstance] getCPUUsage];
    //[[LoggerManager sharedInstance] getMemoryStatistics];
    
    double av = [self availableMemory];
    
    double uv = [self availableMemory];
    
    LoggerApp(1,@"getDevidefzDiskspace-- %f --%f",av,uv);
    [self getFreeDiskspace];
    
}

- (void)functionTimer{
    
    LoggerApp(1,@"functionTimer-- %@",self);
}

- (void)XMdelloc{
    
    NSLog(@"didReceiveMemoryWarning-- %@",self);
    LoggerApp(1,@"didReceiveMemoryWarning(内存警告)-- %@",self);
    [[LoggerManager sharedInstance] getCPUUsage];
    [[LoggerManager sharedInstance] getMemoryStatistics];
    
    [self XMdelloc];
}

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

-(void)getFreeDiskspace {
    uint64_t totalSpace = 0.0f;
    uint64_t totalFreeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        NSLog(@"Memory Capacity of %llu GB with %llu GB Free memory available.", ((totalSpace/1024ll)/1024ll/1024ll), ((totalFreeSpace/1024ll)/1024ll/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    LoggerApp(1,@"getFreeDiskspace--totalSpace: %f --totalFreeSpace: %f",totalSpace / 1024.0 / 1024.0,totalFreeSpace / 1024.0 / 1024.0);
}
@end
