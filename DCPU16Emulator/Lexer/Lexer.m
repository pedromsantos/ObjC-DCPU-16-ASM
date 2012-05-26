#import "Lexer.h"

@interface Lexer()

@property (nonatomic, strong) NSString *lineRemaining;

@end

@implementation Lexer


@synthesize tokenDefinitions;
@synthesize scanner;
@synthesize position;
@synthesize lineNumber;
@synthesize token;
@synthesize tokenContents;

@synthesize lineRemaining;

- (id)initWithTokenDefinitions:(NSArray*)definitions scanner:(NSScanner*)textScanner
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    self.tokenDefinitions = definitions;
    self.scanner = textScanner;
    
    [self nextLine];
    
    return self;
}

- (void)nextLine
{
    NSString *matchedNewlines = nil;
    
    do {
        [self.scanner
         scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
         intoString:&matchedNewlines];
        ++self.lineNumber;
        self.position = 0;
        
        self.lineRemaining = matchedNewlines;
        
    } while (self.lineRemaining != nil && [self.lineRemaining length] == 0);
}

- (BOOL)next
{
    if (lineRemaining == nil)
    {
        return NO;
    }
    
    for (TokenDefinition *def in self.tokenDefinitions)
    {
        int matched = [def.matcher match:self.lineRemaining];
        
        if (matched > 0)
        {
            self.position += matched;
            self.token = def.token;
            
            self.tokenContents = [self.lineRemaining  substringWithRange:NSMakeRange(0, matched)];
            self.lineRemaining = [self.lineRemaining substringFromIndex:matched];
            
            if ([self.lineRemaining length] == 0)
            {
                [self nextLine];
            }
            
            return true;
        }
    }
    
    return NO;
}

@end
