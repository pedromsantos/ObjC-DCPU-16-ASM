/*
 * Copyright (C) 2012 Pedro Santos @pedromsantos
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

#import "IndirectNextWordOperand.h"
#import "IndirectNextWordOperandBuilder.h"

@implementation IndirectNextWordOperandBuilder

- (Operand*)CreateOperandFromMatch:(Match*)match
{
    return [[IndirectNextWordOperand alloc] init];
}

- (void)setNextWordValue:(Match*)match
{
    if(match.token == HEX)
    {
        self.operand.nextWord = [self parseHexLiteral:match.content];
    }
    else if (match.token == INT)
    {
        self.operand.nextWord = [self parseDecimalLiteral:match.content];
    }
}

- (uint16_t)parseHexLiteral:(NSString*)textLiteral
{
    uint outVal;
    NSScanner* scanner = [NSScanner scannerWithString:textLiteral];
    [scanner scanHexInt:&outVal];
    
    return (uint16_t)outVal;
}

- (uint16_t)parseDecimalLiteral:(NSString*)textLiteral
{
    int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:textLiteral];
    [scanner scanInt:&outVal];
    
    return (uint16_t)outVal;
}

@end