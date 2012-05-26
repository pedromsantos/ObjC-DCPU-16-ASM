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
    NSString *pattern = @"\\b(\\bdat\\b|\\bset\\b|\\badd\\b|\\bsub\\b|\\bmul\\b|\\bdiv\\b|\\bmod\\b|\\bshl\\b|\\bshr\\b|\\band\\b|\\bbor\\b|\\bxor\\b|\\bife\\b|\\bifn\\b|\\bifg\\b|\\bifb\\b|\\bjsr\\b|\\b\\bSET\\b|\\bADD\\b|\\bSUB\\b|\\bMUL\\b|\\bDIV\\b|\\bMOD\\b|\\bSHL\\b|\\bSHR\\b|\\bAND\\b|\\bBOR\\b|\\bXOR\\b|\\bIFE\\b|\\bIFN\\b|\\bIFG\\b|\\bIFB\\b|\\bJSR\\b|\\bDAT\\b)";
    
    RegexMatcher *matcher = [[RegexMatcher alloc] initWithPattern:pattern];
    
    int index = [matcher match:@"set"];
    
    STAssertTrue(index > 0, nil);
}

- (void)testMatchCanMatchRegister
{
    NSString *pattern = @"(\\ba\\b|\\bb\\b|\\bc\\b|\\bx\\b|\\by\\b|\\bz\\b|\\bi\\b|\\bj\\b|\\bpop\\b|\\bpush\\b|\\bpeek\\b|\\bpc\\b|\\bsp|\\bo\\b|\\bA\\b|\\bB\\b|\\bC\\b|\\bX\\b|\\bY\\b|\\bZ\\b|\\bI\\b|\\bJ\\b|\\bPOP\\b|\\bPUSH\\b|\\bPEEK\\b|\\bPC\\b|\\bSP\\b|\\bO\\b)";
    
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
