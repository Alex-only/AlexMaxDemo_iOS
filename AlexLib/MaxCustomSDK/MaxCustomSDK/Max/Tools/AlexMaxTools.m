

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

@end
