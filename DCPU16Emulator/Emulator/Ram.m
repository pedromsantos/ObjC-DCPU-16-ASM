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
    NSArray *registers = [[NSMutableArray alloc] initWithCapacity:NUM_REGISTERS];
    NSArray *iterals = [[NSMutableArray alloc] initWithCapacity:NUM_ITERALS];
    NSArray *memory = [[NSMutableArray alloc] initWithCapacity:MEMORY_SIZE];
    
    ram = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
           [NSNumber numberWithInt:0], PC,
           [NSNumber numberWithInt:0], SP,
           [NSNumber numberWithInt:0], OV,
           registers, REG,
           iterals, LIT,
           memory, MEM,
           nil];
    
    return self;
}

- (void)setLiteral:(int)literal atIndex:(int)index
{
    NSMutableArray *literals = [ram objectForKey:LIT];
    
    [literals insertObject:[NSNumber numberWithInt:literal] atIndex:index];
}

- (void)setMemoryValue:(NSNumber*)value atIndex:(int)index
{
    NSMutableArray *memory = [ram objectForKey:MEM];
    
    [memory insertObject:value atIndex:index];
}

- (int)getLiteralAtIndex:(int)index
{
    NSMutableArray *literals = [ram objectForKey:LIT];
    
    return [[literals objectAtIndex:index] intValue];
}

- (int)getMemoryValueAtIndex:(int)index
{
    NSMutableArray *memory = [ram objectForKey:MEM];

    return [[memory objectAtIndex:index] intValue];
}

@end
