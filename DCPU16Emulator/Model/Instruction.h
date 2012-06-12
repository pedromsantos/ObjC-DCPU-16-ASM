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

#import <UIKit/UIKit.h>

enum InstructionInputState
{
    WaitForOpcodeOrLabel,
    WaitForOpcode,
    WaitForOperand1,
    WaitForOperand2,
    Complete
};

@interface Instruction : NSObject
{
    enum InstructionInputState instructionState;
}

@property (nonatomic, readonly) enum InstructionInputState state;
@property (nonatomic, strong) NSString* label;
@property (nonatomic, strong) NSString* opcode;
@property (nonatomic, strong) NSString* operand1;
@property (nonatomic, strong) NSString* operand2;

- (void)reset;
- (void)assignValue:(NSString*)value;
- (void)assignLabel:(NSString*)value;

- (NSArray*)possibleNextInput;

@end
