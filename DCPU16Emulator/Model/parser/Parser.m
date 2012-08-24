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
#import "LexerProtocol.h"
#import "Statment.h"
#import "PeekToken.h"
#import "NSString+ParseHex_ParseInt.h"
#import "IndirectNextWordOffsetOperandBuilder.h"

@interface Parser ()

@property(nonatomic, strong) id <LexerProtocol> lexer;
@property(nonatomic, strong) id <ConsumeTokenStrategy> peekToken;
@property(nonatomic, strong) id <OperandFactoryProtocol> operandFactory;

@end

@implementation Parser

@synthesize lexer;
@synthesize statments;

@synthesize peekToken;
@synthesize operandFactory;

@synthesize didFinishParsingSuccessfully;
@synthesize didFinishParsingWithError;

- (id)initWithOperandFactory:(id <OperandFactoryProtocol>)factory
{
	self = [super init];

	self.operandFactory = factory;

	return self;
}

- (void)parseSource:(NSString *)source withLexer:(id<LexerProtocol>)theLexer
{
	self.lexer = theLexer;
	self.peekToken = [[PeekToken alloc] init];
	self.statments = [[NSMutableArray alloc] init];

	[self.lexer lexSource:source];

	@try
	{
		while([self parseStatment])
		{
		}

		if(self.didFinishParsingSuccessfully)
		{
			self.didFinishParsingSuccessfully();
		}
	}
	@catch(NSString *message)
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

	BOOL canKeepLexing = [self.lexer nextTokenUsingStrategy:(self.peekToken)];

	if(!canKeepLexing)
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
	[self.lexer nextTokenUsingStrategy:(self.peekToken)];
	BOOL canKeepLexing = true;

	while((self.lexer.token == COMMENT || self.lexer.token == WHITESPACE) && canKeepLexing)
	{
		[self.lexer nextTokenUsingStrategy:(self.peekToken)];

		if(self.lexer.token == COMMENT || self.lexer.token == WHITESPACE)
		{
			canKeepLexing = [self.lexer nextToken];
		}
		else
		{
			canKeepLexing = NO;
		}
	}
}

- (void)parseComments
{
	[self.lexer nextTokenUsingStrategy:(self.peekToken)];

	if(self.lexer.token == COMMENT)
	{
		[self.lexer nextToken];
	}
}

- (void)parseLabelForStatment:(Statment *)statment
{
	if(self.lexer.token == LABEL)
	{
		[self.lexer nextToken];
		statment.label = self.lexer.tokenContents;
	}
}

- (void)parseMenemonicForStatment:(Statment *)statment
{
	[self.lexer nextToken];

	if(self.lexer.token != INSTRUCTION)
	{
		@throw [NSString stringWithFormat:@"Expected INSTRUCTION at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
	}

	statment.menemonic = [self.lexer.tokenContents uppercaseString];
}

- (void)parseOperandsForStatment:(Statment *)statment
{
	statment.firstOperand = [self parseOperand];

	[self.lexer nextToken];

	if(self.lexer.token == COMMA)
	{
		statment.secondOperand = [self parseOperand];
	}
	else
	{
		statment.secondOperand = [Operand newOperand:O_NULL];
	}
}

- (Operand *)parseOperand
{
	[self.lexer nextToken];

	if(self.lexer.token == OPENBRACKET)
	{
		return [self parseIndirectOperand];
	}

	Operand *operand = [self.operandFactory createDirectOperandForMatch:self.lexer.match];

	if(operand == nil)
	{
		@throw [NSString stringWithFormat:@"Expected operand at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
	}

	return operand;

}

- (Operand *)parseIndirectOperand
{
	[self.lexer nextToken];

	Match *leftToken = [[Match alloc] init];
	leftToken.token = self.lexer.token;
	leftToken.content = [self.lexer.tokenContents copy];

	Operand *operand;

	[self.lexer nextTokenUsingStrategy:(self.peekToken)];

	if(self.lexer.token == PLUS)
	{
		[self.lexer nextToken];
		operand = [self parseIndirectOffsetOperand:leftToken];
	}
	else
	{
		operand = [self.operandFactory createIndirectOperandForMatch:leftToken];
	}

	[self assertIndirectOperandIsTerminatedWithACloseBracketToken];

	return operand;

}

- (Operand *)parseIndirectOffsetOperand:(Match *)previousMatch
{
	[self.lexer nextToken];

	return [[[IndirectNextWordOffsetOperandBuilder alloc] initWithLeftToken:previousMatch]
												   buildFromMatch:self.lexer.match];
}

- (void)assertIndirectOperandIsTerminatedWithACloseBracketToken
{
	[self.lexer nextToken];

	if(self.lexer.token != CLOSEBRACKET)
	{
		@throw [NSString stringWithFormat:@"Expected CLOSEBRACKET or PLUS at line %d:%d found '%@'", self.lexer.lineNumber, self.lexer.columnNumber, self.lexer.tokenContents];
	}
}

- (void)parseData:(Statment *)statment
{
	do
	{
		if(self.lexer.token == COMMA)
		{
			[self.lexer nextToken];
		}

		[self.lexer nextToken];

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
				[statment addDat:(UInt16) current];
			}
		}

		[self.lexer nextTokenUsingStrategy:(self.peekToken)];

	} while(self.lexer.token == COMMA);
}

@end
