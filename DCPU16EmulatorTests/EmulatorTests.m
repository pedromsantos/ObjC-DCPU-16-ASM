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

#import "EmulatorTests.h"
#import "Emulator.h"
#import "Assembler.h"
#import "Parser.h"

@implementation EmulatorTests

- (void)testStepCalledWithEmptyProgramReturns
{
    NSString *code = @"; Try some basic stuff";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertFalse([emulator step], nil);
}

- (void)testStepCalledWithSetRegisterWithDecimalLiteralExecutesProgram
{
    NSString *code = @"SET I, 10";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForRegister:6] == 10, nil);
}

- (void)testStepCalledWithSetRegisterWithHexLiteralExecutesProgram
{
    NSString *code = @"SET A, 0x30";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForRegister:0] == 0x30, nil);
}

- (void)testStepCalledWithSetAddressWithHexLiteralExecutesProgram
{
    NSString *code = @"SET [0x1000], 0x20";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForMemory:0x1000] == 0x20, nil);
}

- (void)testStepCalledWithSetAddressPlusRegiterWithRegiterAddressExecutesProgram
{
    NSString *code = @"SET [0x2000+I], [A]";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForMemory:0x2000] == 0, nil);
}

- (void)testStepCalledWithSubOpperationExecutesProgram
{
    NSString *code = @" SET A, 0x30             ; 7c01 0030\n\
    SET [0x1000], 0x20      ; 7de1 1000 0020\n\
    SUB A, [0x1000]         ; 7803 1000\n";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForRegister:0] == 0x30, nil);
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForMemory:0x1000] == 0x20, nil);
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForRegister:0] == 0x10, nil);
}

- (void)testStepCalledWithLoopExecutesProgram
{
    NSString *code = @"\n\
    ; Do a loopy thing\n\
    SET I, 10               ; a861\n\
    SET A, 0x2000           ; 7c01 2000\n\
    :loop       SET [0x2000+I], [A]     ; 2161 2000\n\
    SUB I, 1                ; 8463\n\
    IFN I, 0                ; 806d\n\
    SET PC, loop            ; 7dc1 000d [*]\n";
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    Emulator *emulator = [[Emulator alloc] initWithProgram:(assembler.program)];
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForRegister:6] == 10, nil);
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForRegister:0] == 0x2000, nil);
    
    STAssertTrue([emulator step], nil);
    STAssertTrue([emulator getValueForMemory:0x2000+10] == 0x2000, nil);
    
    for (int i = 9; i > 0; i--) 
    {
        STAssertTrue([emulator step], nil);
        STAssertTrue([emulator getValueForRegister:6] == i, nil);
        
        STAssertTrue([emulator step], nil);
        STAssertTrue([emulator step], nil);
        STAssertTrue([emulator getProgramCounter] == 3, nil);
        
        STAssertTrue([emulator step], nil);
        STAssertTrue([emulator getValueForMemory:0x2000+i] == 0x2000, nil);
    }
}


@end
