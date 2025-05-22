
#import <Foundation/Foundation.h>
#import "AlexMaxBiddingRequest.h"
#import "AlexMAXNetworkC2STool.h"
NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxC2SBiddingRequestManager : NSObject

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(AlexMaxBiddingRequest *)request;

+ (void)disposeLoadSuccessCall:(NSString *)priceStr customObject:(id)customObject unitID:(NSString *)unitID;
+ (void)disposeLoadFailCall:(NSError *)error key:(NSString *)keyStr unitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
