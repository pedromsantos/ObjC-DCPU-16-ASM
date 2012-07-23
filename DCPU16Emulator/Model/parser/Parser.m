/*
 * Copyright (C) 2012 Pedro Santos @pedromsantos
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights 
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

#import "Parser.h"
#import "Statment.h"
#import "PeekToken.h"
#import "ConsumeToken.h"
#import "NSString+ParseHex_ParseInt.h"
#import "IgnoreWhiteSpaceTokenStrategy.h"

#import "IndirectNextWordOffsetOperandBuilder.h"
#import "OperandFactoryProtocol.h"
#import "OperandFactory.h"

@interface Parser()

@property (nonatomic, strong) id<ConsumeTokenStrategy> peekToken;
@property (nonatomic, strong) id<OperandFactoryProtocol> operandFactory;

@end

@implementation Parser

@synthesize lexer;
@synthesize statments;

@synthesize peekToken;
@synthesize operandFactory;

@synthesize didFinishParsingSuccessfully;
@synthesize didFinishParsingWithError;

- (id)init
{
    self = [super init];
    
    self.operandFactory = [[OperandFactory alloc] init];
    
    return self;
}

- (id)initWithOperandFcatory:(id<OperandFactoryProtocol>)factory
{
    self = [super init];
    
    self.operandFactory = factory;
    
    return self;
}

- (void)parseSource:(NSString*)source
{
    NSScanner *codeScanner = [NSScanner scannerWithString:source];
    self.lexer = [[Lexer alloc] initWithScanner:codeScanner];
    
    self.lexer.ignoreTokenStrategy = [[IgnoreWhiteSpaceTokenStrategy alloc] init];
    self.lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    self.peekToken = [[PeekToken alloc] init];
    
    self.statments = [[NSMutableArray alloc] init];
    
    @try 
    {
        while ([self parseStatment])
            ;
        
        if(self.didFinishParsingSuccessfully)
        {
            self.didFinishParsingSuccessfully();
        }
    }
    @catch (NSString* message) 
    {
        if(self.didFinishParsingWithError)
        {
            self.didFinishParsingWithError(message);
        }
        else
        {
            @throw;
        }
    }
}

- (BOOL)parseStatment
{
    Statment *statment = [[Statment alloc] init];
    
    [self parseEmptyLines];
    
    BOOL canKeepLexing = [self.lexer consumeNextTokenUsingStrategy:(self.peekToken)];
    
    if (!canKeepLexing)
    {
        return NO;
    }
    
    [self parseLabelForStatment:statment];
    [self parseMenemonicForStatment:statment];
    
    if([statment.menemonic isEqualToString:@"DAT"])
    {
        [self parseData:statment];
    }
    else 
    {
        [self parseOperandsForStatment:statment];
    }
    
    [self.statments addObject:statment];
    
    [self parseComments];
    
    return YES;
}

- (void)parseEmptyLines
{
    [self.lexer consumeNextTokenUsingStrategy:(self.peekToken)];
    BOOL canKeepLexing = true;
    
    while ((self.lexer.token == COMMENT || self.lexer.token == WHITESPACE) && canKeepLexing) 
    {
        [self.lexer consumeNextTokenUsingStrategy:(self.peekToken)];
        
        if(self.lexer.token == COMMENT || self.lexer.token == WHITESPACE)
        {
            canKeepLexing = [self.lexer consumeNextToken];
        }
        else 
        {
            canKeepLexing = NO;
        }
    }
}

- (void)parseComments
{
    [self.lexer consumeNextTokenUsingStrategy:(self.peekToken)];
    
    if(self.lexer.token == COMMENT)
    {
        [self.lexer consumeNextToken];
    }
}

- (void)parseLabelForStatment:(Statment*)statment
{
    if(self.lexer.token == LABEL)
    {
        [self.lexer consumeNextToken];
        statment.label = self.lexer.tokenContents;
    }
}

- (void)parseMenemonicForStatment:(Statment*)statment
{
    [self.lexer consumeNextToken];
    
    if(self.lexer.token != INSTRUCTION)
    {
        @throw [NSString stringWithFormat:@"Expected INSTRUCTION at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
    }
    
    statment.menemonic = self.lexer.tokenContents;
}

- (void)parseOperandsForStatment:(Statment*)statment
{
    statment.firstOperand = [self parseOperand];
    
    [self.lexer consumeNextToken];
    
    if (self.lexer.token == COMMA)
    {
        statment.secondOperand = [self parseOperand];
    }
    else 
    {
        statment.secondOperand = [Operand newOperand:O_NULL];
    }
}

- (Operand*)parseOperand
{
    [self.lexer consumeNextToken];
    
    if (self.lexer.token == OPENBRACKET)
    {
        return [self parseIndirectOperand];
    }
    
    Operand* operand = [self.operandFactory createDirectOperandForMatch:self.lexer.match];
    
    if(operand == nil)
    {
        @throw [NSString stringWithFormat:@"Expected operand at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
    }
    
    return operand;

}

- (Operand*)parseIndirectOperand
{
    [self.lexer consumeNextToken];
    
    Match* leftToken = [[Match alloc] init];
    leftToken.token = self.lexer.token;
    leftToken.content = [self.lexer.tokenContents copy]; 
    
    Operand* operand;
    
    [self.lexer consumeNextTokenUsingStrategy:(self.peekToken)];
    
    if(self.lexer.token == PLUS)
    {
        [self.lexer consumeNextToken];
        operand = [self parseIndirectOffsetOperand:leftToken];
    }
    else 
    {
        operand = [self.operandFactory createIndirectOperandForMatch:leftToken];
    }
    
    [self assertIndirectOperandIsTerminatedWithACloseBracketToken];
    
    return operand;

}

- (Operand*)parseIndirectOffsetOperand:(Match*)previousMatch
{
    [self.lexer consumeNextToken];
    
    return [[[IndirectNextWordOffsetOperandBuilder alloc] initWithLeftToken:previousMatch] 
            buildFromMatch:self.lexer.match];
}

- (void)assertIndirectOperandIsTerminatedWithACloseBracketToken
{
    [self.lexer consumeNextToken];
    
    if (self.lexer.token != CLOSEBRACKET)
    {
        @throw [NSString stringWithFormat:@"Expected CLOSEBRACKET or PLUS at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
    }
}

- (void)parseData:(Statment*)statment
{
    do 
    {
        if(self.lexer.token == COMMA)
        {
            [self.lexer consumeNextToken];
        }
        
        [self.lexer consumeNextToken];
        
        if(self.lexer.token == HEX)
        {
            [statment addDat:[self.lexer.tokenContents parseHexLiteral]];
        }
        else if(self.lexer.token == INT)
        {
            [statment addDat:[self.lexer.tokenContents parseDecimalLiteral]];
        }
        else if(self.lexer.token == STRING)
        {
            int len = [self.lexer.tokenContents length];
            unichar buffer[len];
            [self.lexer.tokenContents getCharacters:buffer range:NSMakeRange(0, (NSUInteger) len)];
            
            for(int i = 0; i < len; ++i) 
            {
                char current = (char) buffer[i];
                
                if(current == ' ')
                {
                    continue;
                }
                
                [statment addDat:(UInt16) current];
            }
        }
        
    } while (self.lexer.token == COMMA);
}

@end
