
#import "AlexMAXNetworkC2STool.h"


@interface AlexMAXNetworkC2STool()

@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *requestDic;

@end


@implementation AlexMAXNetworkC2STool


+ (instancetype)sharedInstance {
    static AlexMAXNetworkC2STool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AlexMAXNetworkC2STool alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    _requestDic = [NSMutableDictionary dictionary];
    return self;
}

#pragma mark - request CRUD
- (void)saveRequestItem:(id)request withUnitId:(NSString *)unitID{
    @synchronized (self) {
        [self.requestDic setValue:request forKey:unitID];
    }
}

- (id)getRequestItemWithUnitID:(NSString*)unitID {
    @synchronized (self) {
        return [self.requestDic objectForKey:unitID];
    }
}

- (void)removeRequestItemWithUnitID:(NSString*)unitID {
    @synchronized (self) {
        [self.requestDic removeObjectForKey:unitID];
    }
}


@end
