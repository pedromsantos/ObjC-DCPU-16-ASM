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
#import "IgnoreWhiteSpaceTokenStrategy.h"

#import "NextWordOperandBuilder.h"
#import "RegisterOperandBuilder.h"
#import "LabelReferenceOperandBuilder.h"
#import "IndirectRegisterOperandBuilder.h"
#import "IndirectNextWordOperandBuilder.h"
#import "IndirectNextWordOffsetOperandBuilder.h"

typedef Operand*(^creationStrategy)(Match*);

@interface Parser()
{
    NSDictionary* operandCreationStrategyMapper;
    NSDictionary* indirectOperandCreationStrategyMapper;
}

@property (nonatomic, strong) id<ConsumeTokenStrategy> peekToken;

@end

@implementation Parser

@synthesize lexer;
@synthesize statments;

@synthesize peekToken;

@synthesize didFinishParsingSuccessfully;
@synthesize didFinishParsingWithError;

- (id)init
{
    self = [super init];
    
    operandCreationStrategyMapper = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (Operand*)^(Match* m){ return [[[RegisterOperandBuilder alloc] init] buildFromMatch:m]; },
                                     [NSNumber numberWithInt:REGISTER],
                                     (Operand*)^(Match* m){ return [[[LabelReferenceOperandBuilder alloc] init] buildFromMatch:m]; },
                                     [NSNumber numberWithInt:LABELREF],
                                     (Operand*)^(Match* m){ return [[[NextWordOperandBuilder alloc] init] buildFromMatch:m]; },
                                     [NSNumber numberWithInt:HEX],
                                     (Operand*)^(Match* m){ return [[[NextWordOperandBuilder alloc] init] buildFromMatch:m]; },
                                     [NSNumber numberWithInt:INT],
                                     (Operand*)^(Match* m){ return [self parseIndirectOperand]; },
                                     [NSNumber numberWithInt:OPENBRACKET],
                                     nil];
    
    indirectOperandCreationStrategyMapper = [NSDictionary dictionaryWithObjectsAndKeys:
                                             (Operand*)^(Match* m){ return [[[IndirectRegisterOperandBuilder alloc] init] buildFromMatch:m]; },
                                             [NSNumber numberWithInt:REGISTER],
                                             (Operand*)^(Match* m){ return [[[LabelReferenceOperandBuilder alloc] init] buildFromMatch:m]; },
                                             [NSNumber numberWithInt:LABELREF],
                                             (Operand*)^(Match* m){ return [[[IndirectNextWordOperandBuilder alloc] init] buildFromMatch:m]; },
                                             [NSNumber numberWithInt:HEX],
                                             nil];
    
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
    [self parseOperandsForStatment:statment];
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
    
    creationStrategy strategy = [operandCreationStrategyMapper objectForKey:[NSNumber numberWithInt:self.lexer.token]];
    
    if(strategy == nil)
    {
        @throw [NSString stringWithFormat:@"Expected operand at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
    }
    
    return strategy(self.lexer.match);

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
        creationStrategy strategy = [indirectOperandCreationStrategyMapper 
                                     objectForKey:[NSNumber numberWithInt:leftToken.token]];
        
        operand = strategy(leftToken);
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

@end
