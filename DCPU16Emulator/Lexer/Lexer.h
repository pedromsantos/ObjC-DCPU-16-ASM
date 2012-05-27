#import "TokenDefinition.h"

@interface Lexer : NSObject

@property (nonatomic, strong) NSArray *tokenDefinitions;
@property (nonatomic, strong) NSScanner *scanner;
@property (nonatomic, assign) int lineNumber;
@property (nonatomic, assign) int position;
@property (nonatomic, assign) enum LexerTokenType token;
@property (nonatomic, strong) NSString *tokenContents;
@property (nonatomic, assign) BOOL ahead;
@property (nonatomic, assign) BOOL ignoreWhiteSpace;

- (id)initWithTokenDefinitions:(NSArray*)definitions scanner:(NSScanner*)textScanner;
- (id)initWithScanner:(NSScanner *)textScanner;

- (BOOL)next;
- (BOOL)peek;

@end
