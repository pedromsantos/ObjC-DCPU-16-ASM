#import "LexerTests.h"
#import "TokenDefinition.h"
#import "LexerTokenType.h"
#import "Lexer.h"

@implementation LexerTests

@synthesize tokenDefinitions;

- (void)setUp
{
    self.tokenDefinitions = [NSArray arrayWithObjects:
                             [[TokenDefinition alloc] initWithToken:WHITESPACE pattern:@"(\\r\\n|\\s+)"],
                             [[TokenDefinition alloc] initWithToken:COMMENT pattern:@";.*$"],
                             [[TokenDefinition alloc] initWithToken:LABEL pattern:@":\\w+"],
                             [[TokenDefinition alloc] initWithToken:HEX pattern:@"(0x[0-9a-fA-F]+)"],
                             [[TokenDefinition alloc] initWithToken:INT pattern:@"[0-9]+"],
                             [[TokenDefinition alloc] initWithToken:PLUS pattern:@"\\+"],
                             [[TokenDefinition alloc] initWithToken:COMMA pattern:@","],
                             [[TokenDefinition alloc] initWithToken:OPENBRACKET pattern:@"[\\[\\(]"],
                             [[TokenDefinition alloc] initWithToken:CLOSEBRACKET pattern:@"[\\]\\)]"],
                             [[TokenDefinition alloc] initWithToken:INSTRUCTION pattern:@"\\b(\\bdat\\b|\\bset\\b|\\badd\\b|\\bsub\\b|\\bmul\\b|\\bdiv\\b|\\bmod\\b|\\bshl\\b|\\bshr\\b|\\band\\b|\\bbor\\b|\\bxor\\b|\\bife\\b|\\bifn\\b|\\bifg\\b|\\bifb\\b|\\bjsr\\b|\\b\\bSET\\b|\\bADD\\b|\\bSUB\\b|\\bMUL\\b|\\bDIV\\b|\\bMOD\\b|\\bSHL\\b|\\bSHR\\b|\\bAND\\b|\\bBOR\\b|\\bXOR\\b|\\bIFE\\b|\\bIFN\\b|\\bIFG\\b|\\bIFB\\b|\\bJSR\\b|\\bDAT\\b)"],
                             [[TokenDefinition alloc] initWithToken:REGISTER pattern:@"(\\ba\\b|\\bb\\b|\\bc\\b|\\bx\\b|\\by\\b|\\bz\\b|\\bi\\b|\\bj\\b|\\bpop\\b|\\bpush\\b|\\bpeek\\b|\\bpc\\b|\\bsp|\\bo\\b|\\bA\\b|\\bB\\b|\\bC\\b|\\bX\\b|\\bY\\b|\\bZ\\b|\\bI\\b|\\bJ\\b|\\bPOP\\b|\\bPUSH\\b|\\bPEEK\\b|\\bPC\\b|\\bSP\\b|\\bO\\b)"],
                             [[TokenDefinition alloc] initWithToken:STRING pattern:@"@?\"(\"\"|[^\"])*\""],
                             [[TokenDefinition alloc] initWithToken:LABELREF pattern:@"[a-zA-Z0-9_]+"],
                             nil];
    
    [super setUp];
}

- (void)testNextCalledWithEmptySourceDoesNotGenerateCorrectTokens
{
    NSString *code = @"";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    [lexer next];
    
    STAssertNil(lexer.tokenContents, nil);
}

- (void)testNextCalledWithCommentOnlyDoesNotGenerateCorrectTokens
{
    NSString *code = @"; Try some basic stuff";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    [lexer next];
    
    STAssertTrue(lexer.token == COMMENT, nil);
}

- (void)testNextCalledWithSetRegisterWithLiteralGenertesCorrectTokens
{
    NSString *code = @"SET A, 0x30";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    int expectedTokens[6] = { INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX };
    
    for (int i = 0; i < 6; i++) 
    {
        [lexer next];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetMemoryAddressWithLiteralGenertesCorrectInstructionSet
{
    NSString *code = @"SET [0x1000], 0x20";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    int expectedTokens[8] = { INSTRUCTION, WHITESPACE, OPENBRACKET, HEX, CLOSEBRACKET, COMMA, WHITESPACE, HEX };
    
    for (int i = 0; i < 8; i++) 
    {
        [lexer next];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetRegisterWithDecimalLiteralGenertesCorrectInstructionSet
{
    NSString *code = @"SET I 10";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    int expectedTokens[5] = { INSTRUCTION, WHITESPACE, REGISTER, WHITESPACE, INT };
    
    for (int i = 0; i < 5; i++) 
    {
        [lexer next];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetRegisterWithHexLiteralGenertesCorrectInstructionSet
{
    NSString *code = @"SET A 0x2000";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    int expectedTokens[5] = { INSTRUCTION, WHITESPACE, REGISTER, WHITESPACE, HEX };
    
    for (int i = 0; i < 5; i++) 
    {
        [lexer next];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetRegisterWithLabelRefGenertesCorrectInstructionSet
{
    NSString *code = @"SET PC, crash";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];

    int expectedTokens[6] = { INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF };
        
    for (int i = 0; i < 6; i++) 
    {
        [lexer next];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextNextCalledWithNotchSampleGenertesCorrectInstructionSet
{
    NSString *code = @"\n\
    ; Try some basic stuff\n\
    SET A, 0x30              ; 7c01 0030\n\
    SET [0x1000], 0x20       ; 7de1 1000 0020\n\
    SUB A, [0x1000]          ; 7803 1000\n\
    IFN A, 0x10              ; c00d\n\
    SET PC, crash            ; 7dc1 001a [*]\n\
    \n\
    ; Do a loopy thing\n\
    SET I, 10                ; a861\n\
    SET A, 0x2000            ; 7c01 2000\n\
    :loop         SET [0x2000+I], [A]      ; 2161 2000\n\
    SUB I, 1                 ; 8463\n\
    IFN I, 0                 ; 806d\n\
    SET PC, loop             ; 7dc1 000d [*]\n\
    \n\
    ; Call a subroutine\n\
    SET X, 0x4               ; 9031\n\
    JSR testsub              ; 7c10 0018 [*]\n\
    SET PC, crash            ; 7dc1 001a [*]\n\
    \n\
    :testsub      SHL X, 4   ; 9037\n\
    SET PC, POP              ; 61c1\n\
    \n\
    ; Hang forever. X should now be 0x40 if everything went right.\n\
    :crash        SET PC, crash            ; 7dc1 001a [*]\n\
    \n\
    ; [*]: Note that these can be one word shorter and one cycle faster by using the short form (0x00-0x1f) of literals,\n\
    ;      but my assembler doesn't support short form labels yet.";
    
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenDefinitions:self.tokenDefinitions scanner:codeScanner];
    
    int expectedTokens[155] = {
        COMMENT, 
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, OPENBRACKET, HEX, CLOSEBRACKET, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, OPENBRACKET, HEX, CLOSEBRACKET, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        
        COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        LABEL, WHITESPACE, INSTRUCTION, WHITESPACE, OPENBRACKET, HEX, PLUS, REGISTER, CLOSEBRACKET, COMMA, WHITESPACE, OPENBRACKET, REGISTER, CLOSEBRACKET, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        
        COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        LABEL, WHITESPACE, INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, REGISTER, WHITESPACE, COMMENT,
        
        COMMENT,
        LABEL, WHITESPACE, INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        COMMENT,
        COMMENT
    };
    
    for (int i = 0; i < 155; i++) 
    {
        [lexer next];
        NSLog(@"token: %d expected: %d", lexer.token, expectedTokens[i]);
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

@end
