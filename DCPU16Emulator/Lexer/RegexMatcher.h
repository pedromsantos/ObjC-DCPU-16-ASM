#import "Matcher.h"

@interface RegexMatcher : NSObject <Matcher>

@property (nonatomic, strong) NSRegularExpression* regex;

- (id)initWithPattern:(NSString*)pattern;

@end