#import "TokenDefinition.h"
#import "RegexMatcher.h"

@implementation TokenDefinition

@synthesize matcher;
@synthesize token;

- (id)initWithToken:(enum LexerTokenType)tokenType pattern:(NSString*)pattern
{
    self = [super init];
    
    if(self==nil)
    {
        return nil;
    }
    
    RegexMatcher *regexMatcher = [[RegexMatcher alloc] initWithPattern:pattern];
    self.matcher = regexMatcher;
    
    self.token = tokenType;
    
    return self;
}

@end
