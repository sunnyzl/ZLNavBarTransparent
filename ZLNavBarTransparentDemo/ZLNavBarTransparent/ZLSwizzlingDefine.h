//
//  ZLSwizzlingDefine.h
//  Test
//
//  Created by zhao on 2017/3/22.
//  Copyright © 2017年 zhao. All rights reserved.
//

#ifndef ZLSwizzlingDefine_h
#define ZLSwizzlingDefine_h
#import <objc/runtime.h>

static inline void zl_swizzling_exchangeMethod(Class claszz, SEL originalSlector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(claszz, originalSlector);
    Method swizzledMethod = class_getInstanceMethod(claszz, swizzledSelector);
    
    BOOL success = class_addMethod(claszz, originalSlector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (success) {
        class_replaceMethod(claszz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#endif /* ZLSwizzlingDefine_h */
