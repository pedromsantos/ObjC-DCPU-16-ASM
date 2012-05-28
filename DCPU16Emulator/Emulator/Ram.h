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

// Size variables to define the environment.
#define MEMORY_SIZE     65536
#define NUM_ITERALS     32
#define NUM_REGISTERS   8

// Indices for the RAM
#define PC              @"PC" // program counter
#define SP              @"SP" // stack pointer
#define OV              @"OV" // overflow
#define REG             @"REG" // register
#define LIT             @"LIT" // literals
#define MEM             @"MEM" // memory

@interface Ram : NSObject

- (id)init;

- (void)setLiteral:(int)literal atIndex:(int)index;
- (void)setMemoryValue:(NSNumber*)value atIndex:(int)index;

- (int)getLiteralAtIndex:(int)index;
- (int)getMemoryValueAtIndex:(int)index;

@end
