/*
 * Copyright (C) 2012 Pedro Santos
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
 * SOFTWARE.
 */

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
@synthesize ahead;
@synthesize ignoreWhiteSpace;

@synthesize lineRemaining;

- (id)initWithScanner:(NSScanner *)textScanner
{
    NSArray* definitions = [NSArray arrayWithObjects:
                            [[TokenDefinition alloc] initWithToken:WHITESPACE pattern:@"(\\r\\n|\\s+)"],
                            [[TokenDefinition alloc] initWithToken:COMMENT pattern:@";.*$"],
                            [[TokenDefinition alloc] initWithToken:LABEL pattern:@":\\w+"],
                            [[TokenDefinition alloc] initWithToken:HEX pattern:@"(0x[0-9a-fA-F]+)"],
                            [[TokenDefinition alloc] initWithToken:INT pattern:@"[0-9]+"],
                            [[TokenDefinition alloc] initWithToken:PLUS pattern:@"\\+"],
                            [[TokenDefinition alloc] initWithToken:COMMA pattern:@","],
                            [[TokenDefinition alloc] initWithToken:OPENBRACKET pattern:@"[\\[\\(]"],
                            [[TokenDefinition alloc] initWithToken:CLOSEBRACKET pattern:@"[\\]\\)]"],
                            [[TokenDefinition alloc] initWithToken:INSTRUCTION pattern:@"\\b(((?i)dat)|((?i)set)|((?i)add)|((?i)sub)|((?i)mul)|((?i)div)|((?i)mod)|((?i)shl)|((?i)shr)|((?i)and)|((?i)bor)|((?i)xor)|((?i)ife)|((?i)ifn)|((?i)ifg)|((?i)ifb)|((?i)jsr))\\b"],
                            [[TokenDefinition alloc] initWithToken:REGISTER pattern:@"\\b(((?i)a)|((?i)b)|((?i)c)|((?i)x)|((?i)y)|((?i)z)|((?i)i)|((?i)j)|((?i)pop)|((?i)push)|((?i)peek)|((?i)pc)|((?i)sp)|((?i)o))\\b"],
                            [[TokenDefinition alloc] initWithToken:STRING pattern:@"@?\"(\"\"|[^\"])*\""],
                            [[TokenDefinition alloc] initWithToken:LABELREF pattern:@"[a-zA-Z0-9_]+"],
                            nil];
    
    return [self initWithTokenDefinitions:definitions scanner:textScanner];
}

- (id)initWithTokenDefinitions:(NSArray*)definitions scanner:(NSScanner*)textScanner
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    self.tokenDefinitions = definitions;
    self.scanner = textScanner;
    self.ignoreWhiteSpace = NO;
    
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

- (BOOL)peek
{
    self.ahead = YES;
    
    BOOL result = [self next];
    
    self.ahead = NO;
    
    return result;
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
            
            if(!self.ahead || (def.token == WHITESPACE && ignoreWhiteSpace))
            {
                self.tokenContents = [self.lineRemaining  substringWithRange:NSMakeRange(0, matched)];
                self.lineRemaining = [self.lineRemaining substringFromIndex:matched];
                
                if ([self.lineRemaining length] == 0)
                {
                    [self nextLine];
                }
            }
            
            if(ignoreWhiteSpace && def.token == WHITESPACE)
            {
                continue;
            }
            
            return true;
        }
    }
    
    return NO;
}

@end
