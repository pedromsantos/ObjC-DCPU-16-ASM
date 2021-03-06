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

#import "Memory.h"

@interface Memory ()
{
	dispatch_queue_t q_default;
}

@property(nonatomic, strong) NSMutableDictionary *ram;
@property(nonatomic, assign) int startAddressOfData;

@end

@implementation Memory

@synthesize ram;
@synthesize startAddressOfData;
@synthesize memoryWillChange;
@synthesize memoryDidChange;
@synthesize registerDidChange;
@synthesize registerWillChange;
@synthesize generalRegisterWillChange;
@synthesize generalRegisterDidChange;

- (id)init
{
    self = [super init];
    
	ram = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithInt:0], PC,
			[NSNumber numberWithInt:0], SP,
			[NSNumber numberWithInt:0], OV,
			[[NSMutableArray alloc] initWithCapacity:NUM_REGISTERS], REG,
			[[NSMutableArray alloc] initWithCapacity:NUM_ITERALS], LIT,
			[[NSMutableArray alloc] initWithCapacity:MEMORY_SIZE], MEM,
			nil];

	startAddressOfData = 0;

	NSMutableArray *literals = [ram objectForKey:LIT];

	for(NSUInteger i = 0; i < NUM_ITERALS; i++)
	{
		[literals insertObject:[NSNumber numberWithInt:i] atIndex:i];
	}

	NSMutableArray *registers = [ram objectForKey:REG];
	NSNumber *initValue = [NSNumber numberWithInt:0];

	for(NSUInteger i = 0; i < NUM_REGISTERS; i++)
	{
		[registers insertObject:initValue atIndex:i];
	}

	NSMutableArray *memory = [ram objectForKey:MEM];

	for(NSUInteger i = 0; i < MEMORY_SIZE; i++)
	{
		[memory insertObject:initValue atIndex:i];
	}

	q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	return self;
}

- (void)load:(NSArray *)values
{
	int programSize = [values count];

	for(NSInteger i = 0; i < programSize; i++)
	{
		[self setMemoryValue:[[values objectAtIndex:(NSUInteger) i] intValue] atIndex:i];
	}

	startAddressOfData = programSize + 1;
}

- (void)setMemoryValue:(int)value atIndex:(int)index inMemoryArea:(NSString *)area
{
	NSMutableArray *memoryArea = [ram objectForKey:area];

	if(self.memoryWillChange != nil && [area isEqualToString:@"MEM"])
	{
		int oldValue = [self getMemoryValueAtIndex:index inMemoryArea:area];

		self.memoryWillChange(area, index, oldValue);
		//dispatch_async(q_default, ^{ self.memoryWillChange(area, index, oldValue); });
	}

	if(self.generalRegisterWillChange != nil && [area isEqualToString:@"REG"])
	{
		int oldValue = [self getMemoryValueAtIndex:index inMemoryArea:area];

		self.generalRegisterWillChange(index, oldValue);
		//dispatch_async(q_default, ^{ self.generalRegisterWillChange(index, oldValue); });
	}

	[memoryArea replaceObjectAtIndex:(NSUInteger) index withObject:[NSNumber numberWithInt:value]];

	if(self.memoryDidChange != nil && [area isEqualToString:@"MEM"])
	{
		self.memoryWillChange(area, index, value);
		//dispatch_async(q_default, ^{ self.memoryWillChange(area, index, value); });
	}

	if(self.generalRegisterDidChange != nil && [area isEqualToString:@"REG"])
	{
		self.generalRegisterDidChange(index, value);
		//dispatch_async(q_default, ^{ self.generalRegisterDidChange(index, value); });
	}
}

- (void)setRegister:(NSString *)registerKey value:(int)newValue
{
	if(self.registerWillChange != nil)
	{
		int oldValue = [[ram valueForKey:registerKey] intValue];

		self.registerWillChange(registerKey, oldValue);
		//dispatch_async(q_default, ^{ self.registerWillChange(registerKey, oldValue); });
	}

	[ram setValue:[NSNumber numberWithInt:newValue] forKey:registerKey];

	if(self.registerDidChange != nil)
	{
		self.registerDidChange(registerKey, newValue);
		//dispatch_async(q_default, ^{ self.registerDidChange(registerKey, newValue); });
	}
}

- (void)setMemoryValue:(int)value atIndex:(int)index
{
	[self setMemoryValue:value atIndex:index inMemoryArea:MEM];
}

- (void)setOverflowRegisterToValue:(int)value
{
	[self setRegister:OV value:value];
}

- (void)setProgramCounter:(int)value
{
	[self setRegister:PC value:value];
}

- (void)setStackPointer:(int)value
{
	[self setRegister:SP value:value];
}

- (void)setOverflow:(int)value
{
	[self setRegister:OV value:value];
}

- (void)incrementProgramCounter
{
	int actualValue = [[ram objectForKey:PC] intValue];
	[self setRegister:PC value:++actualValue];
}

- (void)incrementStackPointer:(int)value
{
	int actualValue = [[ram objectForKey:SP] intValue];
	[self setRegister:SP value:actualValue + value];
}

- (int)readInstructionAtProgramCounter
{
	int value = [self peekInstructionAtProgramCounter];
	return value;
}

- (int)pop
{
	int value = [self peek];
	[self incrementStackPointer:1];
	return value;
}

- (int)pushAddress
{
	[self incrementStackPointer:-1];
	return [self peek];
}

- (void)push:(int)value
{
	[self incrementStackPointer:-1];
	[self setMemoryValue:value atIndex:[self peek]];
}

- (int)getMemoryValueAtIndex:(int)index inMemoryArea:(NSString *)area
{
	NSMutableArray *memory = [ram objectForKey:area];

	return [[memory objectAtIndex:(NSUInteger) index] intValue];
}

- (int)getMemoryValueAtIndex:(int)index
{
	NSMutableArray *memory = [ram objectForKey:MEM];

	return [[memory objectAtIndex:(NSUInteger) index] intValue];
}

- (int)getValueForRegister:(int)reg
{
	NSMutableArray *registers = [ram objectForKey:REG];

	int value = [[registers objectAtIndex:(NSUInteger) reg] intValue];

	return value;
}

- (int)setValueForGeneralRegister:(int)reg value:(ushort)value
{
	NSMutableArray *registers = [ram objectForKey:REG];

	[registers replaceObjectAtIndex:(NSUInteger) reg withObject:[NSNumber numberWithInt:value]];

	return value;
}

- (int)getLiteralAtIndex:(int)index
{
	NSMutableArray *literals = [ram objectForKey:LIT];

	return [[literals objectAtIndex:(NSUInteger) index] intValue];
}

- (int)peekInstructionAtProgramCounter
{
	NSMutableArray *memory = [ram objectForKey:MEM];

	if([memory count] == 0)
	{
		return 0;
	}

	return [[memory objectAtIndex:(NSUInteger) [[ram objectForKey:PC] intValue]] intValue];
}

- (int)peek
{
	NSMutableArray *memory = [ram objectForKey:MEM];

	return [[memory objectAtIndex:(NSUInteger) [[ram objectForKey:SP] intValue]] intValue];
}

- (int)getProgramCounter
{
	int value = [[ram objectForKey:PC] intValue];
	return value;
}

- (int)getStacPointer
{
	int value = [[ram objectForKey:SP] intValue];
	return value;
}

- (int)getOverflow
{
	int value = [[ram objectForKey:OV] intValue];
	return value;
}

@end
