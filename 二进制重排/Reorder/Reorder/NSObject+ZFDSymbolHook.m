//
//  NSObject+ZFDSymbolHook.m
//  Reorder
//
//  Created by NiiLove on 2020/10/8.
//  Copyright © 2020 zengfandi. All rights reserved.
//

#import "NSObject+ZFDSymbolHook.h"
#import <dlfcn.h>
#import <libkern/OSAtomic.h>



@implementation NSObject (ZFDSymbolHook)



+ (void)ZFDSymbolHook{
    
    NSMutableArray *symbNames = [NSMutableArray array];
    while (YES) {
        Snode *node = OSAtomicDequeue(&symList, offsetof(Snode, next));
        if (node == NULL) break;
        Dl_info info;
        dladdr(node->pc, &info);
        NSString *name = @(info.dli_sname);
        BOOL isObjc = [name hasPrefix:@"+["]||[name hasPrefix:@"-["];
        NSString *symName = isObjc ? name : [@"_" stringByAppendingString:name];
        [symbNames addObject:symName];
    }
    
    NSEnumerator * emt  = [symbNames reverseObjectEnumerator];
    NSString *name;
    NSMutableArray *newSymbNames = [NSMutableArray arrayWithCapacity:symbNames.count];
    while (name = [emt nextObject]) {
        if (![newSymbNames containsObject:name]) [newSymbNames addObject:name];
    }
    
    NSString *st = [newSymbNames componentsJoinedByString:@"\n"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"new.order"];
    NSData *fileContent = [st dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContent attributes:nil];
    NSLog(@"%@",filePath);
}

static OSQueueHead symList = OS_ATOMIC_QUEUE_INIT;//线程安全的先进后出队列
typedef struct {
    void *pc;
    void *next;
}Snode;

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,uint32_t *stop) {
  static uint64_t N;
  if (start == stop || *start) return;
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    void *PC = __builtin_return_address(0);//hook函数执行完之后的返回地址(x30寄存器读取)就是原来方法的地址。
    Snode *node = malloc(sizeof(Snode));
    *node = (Snode){PC,NULL};
    OSAtomicEnqueue(&symList, node, offsetof(Snode, next));
}
@end
