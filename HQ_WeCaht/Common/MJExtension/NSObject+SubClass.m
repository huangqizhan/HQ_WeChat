//
//  NSObject+SubClass.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "NSObject+SubClass.h"
#import <objc/runtime.h>



@implementation NSObject (SubClass)


+ (NSArray*)subclassesOfClass:(Class)parentClass{
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = (Class*)malloc(sizeof(Class) * numClasses);
    
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    for(NSInteger i=0; i<numClasses; i++){
        Class cls = classes[i];
        
        do{
            cls = class_getSuperclass(cls);
        }while(cls && cls != parentClass);
        
        if(cls){
            [result addObject:classes[i]];
        }
    }
    
    free(classes);
    
    return [result copy];
}



@end
