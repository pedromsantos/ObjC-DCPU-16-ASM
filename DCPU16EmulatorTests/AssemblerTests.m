/*
 * Copyright (C) 2012 Pedro Santos
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
    NSString *code = @"SET I, 10";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    STAssertTrue([assembler.program count] == 1, nil);
    STAssertTrue([[assembler.program objectAtIndex:0] intValue] == 0xA861, nil);
}

- (void)testAssembleStatmentsCalledWithSetRegisterWithHexLiteralGenertesCorrectProgram
{
    NSString *code = @"SET A, 0x30";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    STAssertTrue([assembler.program count] == 2, nil);
    STAssertTrue([[assembler.program objectAtIndex:0] intValue] == 0x7C01, nil);
    STAssertTrue([[assembler.program objectAtIndex:1] intValue] == 0x0030, nil);
}

- (void)testAssembleStatmentsCalledWithSetAddressWithHexLiteralGenertesCorrectProgram
{
    NSString *code = @"SET [0x1000], 0x20";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    STAssertTrue([assembler.program count] == 3, nil);
    STAssertTrue([[assembler.program objectAtIndex:0] intValue] == 0x7DE1, nil);
    STAssertTrue([[assembler.program objectAtIndex:1] intValue] == 0x1000, nil);
    STAssertTrue([[assembler.program objectAtIndex:2] intValue] == 0x0020, nil);
}

- (void)testAssembleStatmentsCalledWithSetAddressPlusRegiterWithRegiterAddressGenertesCorrectProgram
{
    NSString *code = @"SET [0x2000+I], [A]";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    STAssertTrue([assembler.program count] == 2, nil);
    STAssertTrue([[assembler.program objectAtIndex:0] intValue] == 0x2161, nil);
    STAssertTrue([[assembler.program objectAtIndex:1] intValue] == 0x2000, nil);
}

- (void)testAssembleStatmentsCalledWithNotchSampleGenertesCorrectProgram
{
    NSString *code = @"\n\
; Try some basic stuff\n\
            SET A, 0x30             ; 7c01 0030\n\
            SET [0x1000], 0x20      ; 7de1 1000 0020\n\
            SUB A, [0x1000]         ; 7803 1000\n\
            IFN A, 0x10             ; c00d\n\
            SET PC, crash           ; 7dc1 001a [*]\n\
\n\
; Do a loopy thing\n\
            SET I, 10               ; a861\n\
            SET A, 0x2000           ; 7c01 2000\n\
:loop       SET [0x2000+I], [A]     ; 2161 2000\n\
            SUB I, 1                ; 8463\n\
            IFN I, 0                ; 806d\n\
            SET PC, loop            ; 7dc1 000d [*]\n\
\n\
; Call a subroutine\n\
            SET X, 0x4              ; 9031\n\
            JSR testsub             ; 7c10 0018 [*]\n\
            SET PC, crash           ; 7dc1 001a [*]\n\
\n\
:testsub    SHL X, 4                ; 9037\n\
            SET PC, POP             ; 61c1\n\
\n\
; Hang forever. X should now be 0x40 if everything went right.\n\
:crash      SET PC, crash           ; 7dc1 001a [*]";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    NSLog(@"Parser statments = %d", [p.statments count]);
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    NSLog(@"Program instructions = %d", [assembler.program count]);
    STAssertTrue([assembler.program count] == 28, nil);
    
    int expectedInstructions[28] = {
        0x7c01, 0x0030, 0x7de1, 0x1000, 0x0020, 0x7803, 0x1000, 0xc00d,
        0x7dc1, 0x001a, 0xa861, 0x7c01, 0x2000, 0x2161, 0x2000, 0x8463,
        0x806d, 0x7dc1, 0x000d, 0x9031, 0x7c10, 0x0018, 0x7dc1, 0x001a,
        0x9037, 0x61c1, 0x7dc1, 0x001a};
    
    for (int i = 0; i < 28; i++) 
    {
        NSLog(@"Expected:0x%x Instruction:0x%x", expectedInstructions[i], [[assembler.program objectAtIndex:i] intValue]);
        STAssertTrue([[assembler.program objectAtIndex:i] intValue] == expectedInstructions[i], nil);
    }
}

@end
