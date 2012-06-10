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
#import "Lexer.h"
#import "Statment.h"
#import "Operand.h"

@implementation Parser

@synthesize lexer;
@synthesize statments;

@synthesize didFinishParsingSuccessfully;
@synthesize didFinishParsingWithError;

- (void)parseSource:(NSString*)source
{    
    NSScanner *codeScanner = [NSScanner scannerWithString:source];
    self.lexer = [[Lexer alloc] initWithScanner:codeScanner];
    self.lexer.ignoreWhiteSpace = YES;
    
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
    
    BOOL canKeepLexing = [self.lexer peekNextToken];
    
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
    [self.lexer peekNextToken];
    BOOL canKeepLexing = true;
    
    while ((self.lexer.token == COMMENT || self.lexer.token == WHITESPACE) && canKeepLexing) 
    {
        [self.lexer peekNextToken];
        
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
    [self.lexer peekNextToken];
    
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
    [self parseOperand:statment.firstOperand forStatment:statment];
    
    [self.lexer consumeNextToken];
    
    if (self.lexer.token == COMMA)
    {
        [self parseOperand:statment.secondOperand forStatment:statment];
    }
    else 
    {
        statment.secondOperand.operandType = O_NULL;
    }
}

- (void)parseOperand:(Operand*)operand forStatment:(Statment*)stament
{
    [self.lexer consumeNextToken];
    
    switch (self.lexer.token)
    {
        case OPENBRACKET:
        {
            [self parseIndirectOperand:operand forStatment:stament];
            break;
        }   
        case REGISTER:
        case LABELREF:
        {
            operand.operandType = [Operand operandTypeForName:self.lexer.tokenContents];
            
            if(operand.operandType == O_REG)
            {
                [operand setRegisterValueForName:self.lexer.tokenContents];
            }
            else if (operand.operandType == O_NW)
            {
                operand.label = self.lexer.tokenContents;
                operand.nextWord = 0;
            }
            break;
        }   
        case HEX:
        {
            operand.operandType = O_NW;
            operand.nextWord = [self parseHexLiteral];
            break;
        }   
        case INT:
        {
            operand.operandType = O_NW;
            operand.nextWord = [self parseDecimalLiteral];
            break;
        }
        default:
        {
            @throw [NSString stringWithFormat:@"Expected operand at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
            break;
        }
    }
}

- (uint16_t)parseHexLiteral
{
    uint outVal;
    NSScanner* scanner = [NSScanner scannerWithString:self.lexer.tokenContents];
    [scanner scanHexInt:&outVal];
    
    return (uint16_t)outVal;
}

- (uint16_t)parseDecimalLiteral
{
    int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:self.lexer.tokenContents];
    [scanner scanInt:&outVal];
    
    return (uint16_t)outVal;
}

- (void)parseIndirectOperand:(Operand*)operand forStatment:(Statment*)stament
{
    [self.lexer consumeNextToken];
    
    switch (self.lexer.token)
    {
        case REGISTER:
        {
            [self.lexer consumeNextToken];
            
            if (self.lexer.token != CLOSEBRACKET)
            {
                @throw [NSString stringWithFormat:@"Expected CLOSEBRACKET at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
            }
            
            operand.operandType = O_INDIRECT_REG;
            break;
        }
        case LABELREF:
        {
            // TODO could this be a labelref???
            break;
        }   
        case HEX:
        {
            operand.nextWord = [self parseHexLiteral];
            
            [self.lexer consumeNextToken];
            
            switch (self.lexer.token)
            {
                case CLOSEBRACKET:
                {
                    operand.operandType = O_INDIRECT_NW;
                    break;
                }
                case PLUS:
                {
                    [self.lexer consumeNextToken];
                    
                    operand.operandType = O_INDIRECT_NW_OFFSET;
                    [operand setRegisterValueForName:self.lexer.tokenContents];
                    
                    [self.lexer consumeNextToken];
                    
                    if (self.lexer.token != CLOSEBRACKET)
                    {
                        @throw [NSString stringWithFormat:@"Expected CLOSEBRACKET at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
                    }
                    
                    break;
                }   
                default:
                {
                    @throw [NSString stringWithFormat:@"Expected CLOSEBRACKET or PLUS at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
                    break;
                }
            }
            
            break;
        } 
        default:
        {
            @throw [NSString stringWithFormat:@"Expected REGISTER, LITERAL or LABELREF at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
            break;
        }
    }
}

@end
