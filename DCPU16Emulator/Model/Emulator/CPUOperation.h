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

#import "Operand.h"
#import "DCPUProtocol.h"

@interface CPUOperation : NSObject

@property(nonatomic, retain, readonly) Operand *operand;
@property(nonatomic, readonly) ushort read;
@property(nonatomic, assign, readonly) ushort write;
@property(nonatomic, strong, readonly) id <DCPUProtocol> cpuOperations;

@property(nonatomic, assign) BOOL ignoreInstruction;
@property(nonatomic, assign) ushort overflowRegister;

- (id)initWithOperand:(Operand *)operand cpuStateOperations:(id <DCPUProtocol>)cpuStateOperations;

- (void)process;

- (void)noOp;

- (ushort)read;

- (void)write:(ushort)value;

- (void)jumpSubRoutine:(ushort)subRoutineAddress;

@end
