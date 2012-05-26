#import <Foundation/Foundation.h>

@protocol Matcher <NSObject>

- (int) match:(NSString*)text;

@end
