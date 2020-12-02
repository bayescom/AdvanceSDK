//
//  AdvError.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AdvErrorCode) {
    AdvErrorCode_101    =    101,
    AdvErrorCode_102    =    102,
    AdvErrorCode_103    =    103,
    AdvErrorCode_104    =    104,
    AdvErrorCode_105    =    105,
    AdvErrorCode_110    =    110,
    AdvErrorCode_111    =    111,
    AdvErrorCode_112    =    112,
    AdvErrorCode_113    =    113,
    AdvErrorCode_114    =    114,
};

@interface AdvError : NSObject

+ (instancetype)errorWithCode:(AdvErrorCode)code;

+ (instancetype)errorWithCode:(AdvErrorCode)code obj:(id)obj;

- (NSError *)toNSError;

@end

NS_ASSUME_NONNULL_END
