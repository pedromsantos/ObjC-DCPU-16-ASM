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

#import "Program.h"
#import "Parser.h"
#import "Assembler.h"

@implementation Program

@synthesize instructionSet;
@synthesize currentInstruction;
@synthesize assembledInstructionSet;

- (id)init
{
    self = [super init];
    
    self.currentInstruction = [[Instruction alloc] init];
    self.instructionSet = [[NSMutableArray alloc] init];
    
    [self notifyEditStateChanged];
    [self notifyInstructionChanged];
    [self notifyinstructionSetChanged];
    
    return self;
}

- (void)notifyEditStateChanged
{
    NSArray* availableStates = [self.currentInstruction possibleNextInput];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EditStateChanged" object:availableStates];
}

- (void)notifyInstructionChanged
{
    // TODO Investigate this:
    /*
     NSDictionary* instructionData = [NSDictionary dictionaryWithObjectsAndKeys:
      self.currentInstruction.label != nil ? self.currentInstruction.label : @"", @"label",
     self.currentInstruction.opcode != nil ? self.currentInstruction.opcode : @"", @"opcode",
     self.currentInstruction.operand1 != nil ? self.currentInstruction.operand1 : @"", @"operand1",
     self.currentInstruction.operand2 != nil ? self.currentInstruction.operand2 : @"", @"operand2",
     [NSNumber numberWithInt:self.currentInstruction.state], @"state",nil];
    */
    
    NSDictionary* instructionData = [[NSMutableDictionary alloc] init];
    [instructionData setValue:self.currentInstruction.label != nil ? self.currentInstruction.label : @"" forKey:@"label"];
    [instructionData setValue:self.currentInstruction.opcode != nil ? self.currentInstruction.opcode : @"" forKey:@"opcode"];
    [instructionData setValue:self.self.currentInstruction.operand1 != nil ? self.currentInstruction.operand1 : @"" forKey:@"operand1"];
    [instructionData setValue:self.self.currentInstruction.operand2 != nil ? self.currentInstruction.operand2 : @"" forKey:@"operand2"];
    [instructionData setValue:[NSNumber numberWithInt:self.currentInstruction.state] forKey:@"state"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InstructionChanged" object:instructionData];
}

- (void)notifyinstructionSetChanged
{
    NSArray* instructionSetData = self.instructionSet;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InstructionSetChanged" object:instructionSetData];
}

- (void)assignLabelToCurrentInstruction:(NSString*)value
{
    [self.currentInstruction assignLabel:value];
    [self notifyEditStateChanged];
    [self notifyInstructionChanged];
}

- (void)assignValueToCurrentInstruction:(NSString*)value
{
    [self.currentInstruction assignValue:value];
    [self notifyEditStateChanged];
    [self notifyInstructionChanged];
}

- (void)resetCurrentInstruction
{
    [self.currentInstruction reset];
    [self notifyEditStateChanged];
    [self notifyInstructionChanged];
}

- (void)FinishedInstructionEdit
{
    [self.instructionSet addObject:self.currentInstruction];
    
    self.currentInstruction = nil;
    self.currentInstruction = [[Instruction alloc] init];
    
    [self notifyEditStateChanged];
    [self notifyInstructionChanged];
    [self notifyinstructionSetChanged];
}

- (NSString*)assemble
{
    NSMutableString *source;
    source = [self generateSourceFromInstructions];
    
    NSString *code = source;
    
    Parser *p = [[Parser alloc] init];
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    [assembler assembleStatments:p.statments];
    
    int programInstructionSize = [assembler.program count];
    
    NSMutableString *assembledCode = [NSMutableString string];
    [self.assembledInstructionSet removeAllObjects];
    
    for (NSUInteger i = 0; i < programInstructionSize; i++)
    {
        int assembledInstruction = [[assembler.program objectAtIndex:i] intValue];
        
        [self.assembledInstructionSet addObject:[assembler.program objectAtIndex:i]];
        [assembledCode appendString:[NSString stringWithFormat:@"0x%X ", assembledInstruction]];
    }

    return (NSString*)assembledCode;
}

- (NSMutableString *)generateSourceFromInstructions
{
    NSMutableString *source = [NSMutableString string];
    
    for (Instruction* instruction in self.instructionSet)
    {
        [source appendString:[NSString stringWithFormat:@"%@ %@ %@, %@\n", 
                              instruction.label != nil ? instruction.label : @"", 
                              instruction.opcode != nil ? instruction.opcode : @"", 
                              instruction.operand1 != nil ? instruction.operand1 : @"", 
                              instruction.operand2 != nil ? instruction.operand2 : @""]];
    }
    return source;
}

@end
