//
//  LoggerManager.m
//  Apollo
//
//  Created by TienPham on 5/18/17.
//  Copyright © 2017 Vinasource company. All rights reserved.
//

#import "LoggerManager.h"
#import <mach/mach.h>
#import <sys/sysctl.h>
#import "NSLogger.h"
#import <UIKit/UIKit.h>

@implementation LoggerManager

#pragma mark - Initialize

+ (LoggerManager *)sharedInstance {
    static LoggerManager * sharedInstance;
    if (!sharedInstance){
        sharedInstance = [[LoggerManager alloc] init];
    }
    return sharedInstance;
}

- (void)startCPUMemoryLogger {
    NSLog(@"Start CPU Memory Logger");
}

#pragma mark - CPU/Memory Logging

- (void)getCPUUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    NSLog(@"CPU Usage: %f \n", tot_cpu);
}

- (void)getMemoryStatistics {
    // Get Page Size
    int mib[2];
    int page_size;
    size_t len;
    
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    len = sizeof(page_size);
    
    //    // 方法一: 16384
    //    int status = sysctl(mib, 2, &page_size, &len, NULL, 0);
    //    if (status < 0) {
    //        perror("Failed to get page size");
    //    }
    //    // 方法二: 16384
    //    page_size = getpagesize();
    // 方法三: 4096
    if( host_page_size(mach_host_self(), &page_size)!= KERN_SUCCESS ){
        perror("Failed to get page size");
    }
    NSLog(@"Page size is %d bytes\n", page_size);
    
    // Get Memory Size
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    long ram;
    len = sizeof(ram);
    if (sysctl(mib, 2, &ram, &len, NULL, 0)) {
        perror("Failed to get ram size");
    }
    NSLog(@"Ram size is %f MB\n", ram / (1024.0) / (1024.0));
    
    // Get Memory Statistics
    //    vm_statistics_data_t vm_stats;
    //    mach_msg_type_number_t info_count = HOST_VM_INFO_COUNT;
    vm_statistics64_data_t vm_stats;
    mach_msg_type_number_t info_count64 = HOST_VM_INFO64_COUNT;
    //    kern_return_t kern_return = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vm_stats, &info_count);
    kern_return_t kern_return = host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vm_stats, &info_count64);
    if (kern_return != KERN_SUCCESS) {
        printf("Failed to get VM statistics!");
    }
    
    double vm_total = vm_stats.wire_count + vm_stats.active_count + vm_stats.inactive_count + vm_stats.free_count;
    double vm_wire = vm_stats.wire_count;
    double vm_active = vm_stats.active_count;
    double vm_inactive = vm_stats.inactive_count;
    double vm_free = vm_stats.free_count;
    double unit = (1024.0) * (1024.0);
    
    NSLog(@"Total Memory: %f", vm_total * page_size / unit);
    NSLog(@"Wired Memory: %f", vm_wire * page_size / unit);
    NSLog(@"Active Memory: %f", vm_active * page_size / unit);
    NSLog(@"Inactive Memory: %f", vm_inactive * page_size / unit);
    NSLog(@"Free Memory: %f", vm_free * page_size / unit);
}

#pragma mark - Kandao v13 Logging

void UncaughtExceptionHandler(NSException *exception) {
    NSLog(@"UncaughtExceptionHandler Begin\r\n");
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; //将调用栈拼成输出日志的字符串
    for (NSString *item in symbols) {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    
    // 将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CBBLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.txt"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    // 把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
    NSLog(@"UncaughtExceptionHandler End\r\n");
}

- (void)redirectNSlogToDocumentFolder {
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] hasSuffix:@"Simulator"]) {
        //在模拟器不保存到文件中
        return;
    }
    
    // 将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.txt",dateStr];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}


@end
