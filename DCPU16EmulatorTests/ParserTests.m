#import "ParserTests.h"
#import "Parser.h"
#import "Statment.h"

@implementation ParserTests

- (void)testParseCalledWithEmptySourceDoesNotGenerateStatments
{
    NSString *code = @"";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 0, nil);
}

- (void)testParseCalledWithOnlyCommentsDoesNotGenerateStatments
{
    NSString *code = @"; Try some basic stuff";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 0, nil);
}

- (void)testParseCalledWithSetRegisterWithDecimalLiteralGenertesCorrectStatments
{
    NSString *code = @"SET I, 10";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 1, nil);
    
    Statment* s = [p.statments lastObject];
    
    STAssertTrue(s.opcode == OP_SET, nil);
    STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
    STAssertTrue(s.firstOperand.operandType == O_REG, nil);
    STAssertTrue(s.firstOperand.registerValue == REG_I, nil);
    STAssertTrue(s.secondOperand.operandType == O_NW, nil);
    STAssertTrue(s.secondOperand.nextWord == 10, nil);
}

- (void)testParseCalledWithSetRegisterWithLiteralGenertesCorrectStatments
{
    NSString *code = @"SET A, 0x30";

    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 1, nil);
    
    Statment* s = [p.statments lastObject];
    
    STAssertTrue(s.opcode == OP_SET, nil);
    STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
    STAssertTrue(s.firstOperand.operandType == O_REG, nil);
    STAssertTrue(s.firstOperand.registerValue == REG_A, nil);
    STAssertTrue(s.secondOperand.operandType == O_NW, nil);
    STAssertTrue(s.secondOperand.nextWord == 48, nil);
}

- (void)testParseCalledWithSetMemoryAddressWithLiteralGenertesCorrectStatments
{
    NSString *code = @"SET [0x1000], 0x20";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 1, nil);
    
    Statment* s = [p.statments lastObject];
    
    STAssertTrue(s.opcode == OP_SET, nil);
    STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
    STAssertTrue(s.firstOperand.operandType == O_INDIRECT_NW, nil);
    STAssertTrue(s.firstOperand.nextWord == 4096, nil);
    STAssertTrue(s.secondOperand.operandType == O_NW, nil);
    STAssertTrue(s.secondOperand.nextWord == 32, nil);
}

- (void)testParseCalledWithSetSPRegisterWithLabelRefGenertesCorrectStatments
{
    NSString *code = @"SET PC, crash";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 1, nil);
    
    Statment* s = [p.statments lastObject];
    
    STAssertTrue(s.opcode == OP_SET, nil);
    STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
    STAssertTrue(s.firstOperand.operandType == O_PC, nil);
    STAssertTrue(s.secondOperand.operandType == O_NW, nil);
    STAssertTrue([s.secondOperand.label isEqualToString:@"crash"], nil);
    STAssertTrue(s.secondOperand.nextWord == 0, nil);
}

- (void)testParseCalledWithJSRandLabelRefGenertesCorrectStatments
{
    NSString *code = @"JSR testsub";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 1, nil);
    
    Statment* s = [p.statments lastObject];
    
    STAssertTrue(s.opcode == 0, nil);
    STAssertTrue(s.opcodeNonBasic == OP_JSR, nil);
    STAssertTrue([s.menemonic isEqualToString:@"JSR"], nil);
    STAssertTrue(s.firstOperand.operandType == O_NW, nil);
    STAssertTrue([s.firstOperand.label isEqualToString:@"testsub"], nil);
    STAssertTrue(s.firstOperand.nextWord == 0, nil);
}

- (void)testParseCalledWithInvalidInstructionThrows
{
    NSString *code = @"JSM testsub";
    
    Parser *p = [[Parser alloc] init];
    
    STAssertThrows([p parseSource:code], nil);
}

- (void)testParseCalledWithInvalidOperandThrows
{
    NSString *code = @"JSR \"testsub\"";
    
    Parser *p = [[Parser alloc] init];
    
    STAssertThrows([p parseSource:code], nil);
}

- (void)testParseCalledWithUnclosedBracketThrows
{
    NSString *code = @"SET [0x1000, 0x20";
    
    Parser *p = [[Parser alloc] init];
    
    STAssertThrows([p parseSource:code], nil);
}


@end
