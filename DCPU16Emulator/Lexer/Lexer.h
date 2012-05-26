#import <Foundation/Foundation.h>
#import "TokenDefinition.h"

@interface Lexer : NSObject

@property (nonatomic, strong) NSArray *tokenDefinitions;
@property (nonatomic, strong) NSScanner *scanner;
@property (nonatomic, assign) int lineNumber;
@property (nonatomic, assign) int position;
@property (nonatomic, assign) enum LexerTokenType token;
@property (nonatomic, strong) NSString *tokenContents;

- (id)initWithTokenDefinitions:(NSArray*)definitions scanner:(NSScanner*)textScanner;

- (BOOL)next;

@end
