

#import "AlexMaxTools.h"

@implementation AlexMaxTools

#pragma mark - Tools
+ (NSDictionary *)AlexMax_convertToDictionary:(NSString *)str {
    if ([AlexMaxTools isEmpty:self]) {
        return [NSMutableDictionary dictionary];
    }
    
    NSError *error;
    NSDictionary *dic;
    
    @try {
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                            error:&error];
        if (error) {
            return [NSMutableDictionary dictionary];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",[NSString stringWithFormat:@"AlexMaxBaseManager :Expretion occured:%@", exception]);
    } @finally {
        if ([AlexMaxTools isEmpty:dic] == YES) {
            dic = [NSMutableDictionary dictionary];
        }
    }
    return dic;
}

+ (BOOL)isEmpty:(id)object {
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([object isKindOfClass:[NSString class]] && [(NSString *)object isEqualToString:@"(null)"]) {
        return YES;
    }
    
    if (([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSData class]]) && [object respondsToSelector:@selector(length)]) {
        return [object length] == 0;
    }
    
    if (([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) && [object respondsToSelector:@selector(count)]) {
        return [object count] == 0;
    }
    
    return NO;
}

+ (void)Alex_setDict:(NSMutableDictionary *)mdict value:(id)value key:(NSString *)key {
    if ([key isKindOfClass:[NSString class]] == NO) {
        NSAssert(NO, @"Alex_setDict - key must be string");
    }
    if (key != nil && [key respondsToSelector:@selector(length)] && key.length > 0) {
        if ([self isEmpty:value] == NO) {
            [mdict setValue:value forKey:key];
        }
    } else {
        NSAssert(NO, @"Alex_setDict - key must not equal to nil");
    }
}

@end
