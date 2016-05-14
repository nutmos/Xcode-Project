//
//  Base64.h
//  CryptTest
//  Created by SURAJ K THOMAS  on 02/05/2013.


#import <Foundation/Foundation.h>


@interface Base64 : NSObject {
    
}
+ (void) initialize;
+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;
+ (NSString*) encode:(NSData*) rawBytes;
+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;
+ (NSData*) decode:(NSString*) string;
@end