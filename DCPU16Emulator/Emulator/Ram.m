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

#import "Ram.h"
#import "Emulator.h"

@interface Ram()

@property (nonatomic, strong) NSMutableDictionary *ram;

@end

@implementation Ram

@synthesize ram;

- (id)init
{
    ram = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
           [NSNumber numberWithInt:0], PC,
           [NSNumber numberWithInt:0], SP,
           [NSNumber numberWithInt:0], OV,
           [[NSMutableArray alloc] initWithCapacity:NUM_REGISTERS], REG,
           [[NSMutableArray alloc] initWithCapacity:NUM_ITERALS], LIT,
           [[NSMutableArray alloc] initWithCapacity:MEMORY_SIZE], MEM,
           nil];
    
    return self;
}

- (void)assignResultOfOperation:(memoryOperation)block 
         usingOperand1AtAddress:(int)address1 
                   inMemoryArea:(NSString*)area1
           andOperand2AtAddress:(int)address2
                   inMemoryArea:(NSString*)area2
                      toAddress:(int)address
                   inMemoryArea:(NSString*)area
{
    int a;
    int b;
    
    if([area1 isEqualToString:REG] || [area1 isEqualToString:LIT] || [area1 isEqualToString:MEM])
    {
        a = [self getMemoryValueAtIndex:address1 inMemoryArea:area1];
    }
    else 
    {
        a = address1;
    }
    
    if([area2 isEqualToString:REG] || [area2 isEqualToString:LIT] || [area2 isEqualToString:MEM])
    {
        b = [self getMemoryValueAtIndex:address2 inMemoryArea:area2];
    }
    else 
    {
        b = address2;
    }
    
    if([area1 isEqualToString:@"PC"])
    {
        [self setProgramCounter:a];
    }
    else
    {
        [self setMemoryValue:block(a, b) atIndex:address inMemoryArea:area];
    }
}

- (int)getMemoryValueAtIndex:(int)index inMemoryArea:(NSString*)area
{
    NSMutableArray *memory = [ram objectForKey:area];
    
    return [[memory objectAtIndex:index] intValue];
}

- (void)setMemoryValue:(int)value atIndex:(int)index inMemoryArea:(NSString*)area
{
    NSMutableArray *memory = [ram objectForKey:area];
    
    if ([memory count] > index) 
    {
        [memory replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:value]];
    }
    else 
    {
        [memory insertObject:[NSNumber numberWithInt:value] atIndex:index];
    }
}

- (int)getMemoryValueAtIndex:(int)index
{
    NSMutableArray *memory = [ram objectForKey:MEM];
    
    return [[memory objectAtIndex:index] intValue];
}

- (void)setMemoryValue:(int)value atIndex:(int)index
{
    [self setMemoryValue:value atIndex:index inMemoryArea:MEM];
}

- (void)setLiteral:(int)literal atIndex:(int)index
{
    NSMutableArray *literals = [ram objectForKey:LIT];
    
    if ([literals count] > index) 
    {
        [literals replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:literal]];
    }
    else 
    {
        [literals insertObject:[NSNumber numberWithInt:literal] atIndex:index];
    }
}

- (void)setOverflowRegisterToValue:(int)value
{
    [self setValue:[NSNumber numberWithInt:value] forKey:OV];
}

- (int)getValueForRegister:(int)reg
{
    NSMutableArray *registers = [ram objectForKey:REG];
    
    int value = [[registers objectAtIndex:reg] intValue];
    
    return value;
}

- (int)getLiteralAtIndex:(int)index
{
    NSMutableArray *literals = [ram objectForKey:LIT];
    
    return [[literals objectAtIndex:index] intValue];
}

- (int)peekInstructionAtProgramCounter
{
    NSMutableArray *memory = [ram objectForKey:MEM];
    
    if([memory count] == 0)
    {
        return 0;
    }
    
    return [[memory objectAtIndex:[[ram objectForKey:PC] intValue]] intValue];
}

- (int)readInstructionAtProgramCounter
{
    int value = [self peekInstructionAtProgramCounter];
    [self incrementProgramCounter];
    return value;
}

- (void)incrementProgramCounter
{
    int actualValue = [[ram objectForKey:PC] intValue];
    [ram setValue:[NSNumber numberWithInt:++actualValue] forKey:PC];
}

- (void)setProgramCounter:(int)value
{
    [ram setValue:[NSNumber numberWithInt:value] forKey:PC];
}

- (int)peekInstructionAtStackPointer
{
    NSMutableArray *memory = [ram objectForKey:MEM];
    
    return [[memory objectAtIndex:[[ram objectForKey:SP] intValue]] intValue];
}

- (int)readInstructionAtStackPointer
{
    int value = [self peekInstructionAtStackPointer];
    [self incrementStackPointer:1];
    return value;
}

- (int)decrementAndReadInstructionAtStackPointer
{
    [self incrementStackPointer:-1];
    int value = [self peekInstructionAtStackPointer];
    return value;
}

- (void)incrementStackPointer:(int)value
{
    int actualValue = [[ram objectForKey:SP] intValue];
    [ram setValue:[NSNumber numberWithInt:(actualValue+value)] forKey:SP];
}

- (void)stackPush:(int)value
{
    [self incrementStackPointer:-1];
    [self setMemoryValue:value atIndex:[self peekInstructionAtStackPointer]];
}

- (int)getProgramCounter
{
    int value = [[ram objectForKey:PC] intValue];
    
    return value;
}

@end
