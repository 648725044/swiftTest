//
//  UIViewController+fzextention.m
//  runtime黑魔法
//
//  Created by fuzhong on 2017/6/12.
//  Copyright © 2017年 fuzhong. All rights reserved.
//

#import "UIViewController+fzextention.h"
#import <objc/runtime.h>
@implementation UIViewController (fzextention)

 +(void)load
{

    Method Memorytest = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    
    Method teststart = class_getInstanceMethod(self, @selector(XMdelloc));
    
    
    method_exchangeImplementations(Memorytest, teststart);
}
    
- (void)XMdelloc{

    NSLog(@"XMdelloc-- %@",self);
    
    [self XMdelloc];
}
@end
