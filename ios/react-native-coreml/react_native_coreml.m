#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@interface RCT_EXTERN_MODULE(RNCoreML, NSObject)
//RCT_EXTERN_METHOD(test: (NSString *) name success: (RCTPromiseResolveBlock)success reject: (RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(classifyImageWithModel: (NSString *)source modelPath:(NSString *)modelPath success: (RCTPromiseResolveBlock)success reject: (RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(compileModel: (NSString *)source success: (RCTPromiseResolveBlock)success reject: (RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(predictFromDataWithModel: (NSDictionary *)source modelPath:(NSString *)modelPath success: (RCTPromiseResolveBlock)success reject: (RCTPromiseRejectBlock)reject);
@end
