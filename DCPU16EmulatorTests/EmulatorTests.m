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

@end
