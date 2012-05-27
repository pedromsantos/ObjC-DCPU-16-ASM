#import "AssemblerTests.h"
#import "Statment.h"
#import "Assembler.h"
#import "Parser.h"

@implementation AssemblerTests

- (void)testAssembleStatmentsCalledWithEmptySourceDoesNotGenerateProgram
{
    NSString *code = @"";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    STAssertTrue([p.statments count] == 0, nil);
}

- (void)testAssembleStatmentsCalledWithOnlyCommentsDoesNotGenerateProgram
{
    NSString *code = @"; Try some basic stuff";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    STAssertTrue([assembler.program count] == 0, nil);
}

- (void)testAssembleStatmentsCalledWithSetRegisterWithDecimalLiteralGenertesCorrectProgram
{
    NSString *code = @"SET I, 10"; //A861
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    STAssertTrue([assembler.program count] == 1, nil);
    STAssertTrue([[assembler.program objectAtIndex:0] intValue] == 0xA861, nil);
}

@end
