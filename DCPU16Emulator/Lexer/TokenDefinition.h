#import "Matcher.h"
#import "LexerTokenType.h"

@interface TokenDefinition : NSObject

@property (nonatomic, strong) id<Matcher> matcher;
@property (nonatomic, assign) enum LexerTokenType token;

- (id)initWithToken:(enum LexerTokenType)tokenType pattern:(NSString*)pattern;

@end
