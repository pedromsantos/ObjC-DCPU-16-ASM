#import "RegexMatcher.h"

@implementation RegexMatcher

@synthesize regex;

- (id)initWithPattern:(NSString*)pattern
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    NSError *error = nil;
    
    self.regex = [NSRegularExpression 
                  regularExpressionWithPattern:pattern 
                  options:NSRegularExpressionDotMatchesLineSeparators 
                  error:&error];
    
    return self;
}

- (int) match:(NSString*)text
{
    NSRange range = [regex rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    return range.location == 0 ? range.length : 0;
}

@end
