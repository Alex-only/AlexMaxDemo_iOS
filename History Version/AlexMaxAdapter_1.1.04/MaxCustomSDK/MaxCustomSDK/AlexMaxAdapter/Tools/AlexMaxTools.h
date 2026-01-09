
#import <Foundation/Foundation.h>
 
@interface AlexMaxTools : NSObject

+ (NSDictionary *)AlexMax_convertToDictionary:(NSString *)str;
+ (BOOL)isEmpty:(id)object;
+ (void)Alex_setDict:(NSMutableDictionary *)mdict value:(id)value key:(NSString *)key;

@end
 
