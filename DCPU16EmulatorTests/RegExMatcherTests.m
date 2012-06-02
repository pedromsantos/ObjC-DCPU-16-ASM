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

#import "RegExMatcherTests.h"
#import "RegexMatcher.h"

@implementation RegExMatcherTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testMatchCanMatchWhiteSpace
{
    NSString *pattern = @"(\\r\\n|\\s+)";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@" "];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchComment
{
    NSString *pattern = @";.*$";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"; Try some basic stuff"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchLabel
{
    NSString *pattern = @":\\w+";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@":label"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchHex
{
    NSString *pattern = @"(0x[0-9a-fA-F]+)";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"0xFF"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchInt
{
    NSString *pattern = @"[0-9]+";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"21"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchPlus
{
    NSString *pattern = @"\\+";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"+"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchComa
{
    NSString *pattern = @",";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@","];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchOpenBracket
{
    NSString *pattern = @"[\\[\\(]";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"["];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchCloseBracket
{
    NSString *pattern = @"[\\]\\)]";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"]"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchInstruction
{
    NSString *pattern = @"\\b(((?i)dat)|((?i)set)|((?i)add)|((?i)sub)|((?i)mul)|((?i)div)|((?i)mod)|((?i)shl)|((?i)shr)|((?i)and)|((?i)bor)|((?i)xor)|((?i)ife)|((?i)ifn)|((?i)ifg)|((?i)ifb)|((?i)jsr))\\b";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"Set"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchRegister
{
    NSString *pattern = @"\\b(((?i)a)|((?i)b)|((?i)c)|((?i)x)|((?i)y)|((?i)z)|((?i)i)|((?i)j)|((?i)pop)|((?i)push)|((?i)peek)|((?i)pc)|((?i)sp)|((?i)o))\\b";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"x"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchString
{
    NSString *pattern = @"@?\"(\"\"|[^\"])*\"";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"\"string\""];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchLabelRef
{
    NSString *pattern = @"[a-zA-Z0-9_]+";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"labelref"];
    
    STAssertTrue(index > 0, nil);
}

@end
