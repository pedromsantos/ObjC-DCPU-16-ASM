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

#import "InstructionBuilder.h"
#import "CPUInstruction.h"
#import "Statment.h"

@interface InstructionBuilder()
{
    CPUOperation* operationA;
    CPUOperation* operationB;
    short opcode;
}

@end

@implementation InstructionBuilder

@synthesize operandFactory;
@synthesize instructionMapper;

-(id)initWithInstructionOperandFactory:(id<InstructionOperandFactoryProtocol>)factory
{
    self = [super init];
    
    self.operandFactory = factory;
    
    self.instructionMapper = [NSDictionary dictionaryWithObjectsAndKeys:
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_SET],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_ADD],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_SUB],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_MUL],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_DIV],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_MOD],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_SHL],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_SHR],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_AND],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_BOR],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_XOR],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_IFE],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_IFN],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_IFG],
                              (CPUInstruction *) ^()
                              {
                                  return [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
                              },
                              [NSNumber numberWithInt:OP_IFB],
                              nil];
    
    return self;
}

-(CPUInstruction*)buildFromMachineCode:(ushort)code usingCpuState:(id<DCPUProtocol>)cpuStateOperations
{
    opcode = code & OpMask;
    
    if(opcode == 0)
    {
        ushort op = (code >> OperandAShift) & OperandAMask;
        
        if(op == 0x01)
        {
            ushort operandValue = (code >> OperandBShift) & OperandBMask;
            
            operationA = [[CPUOperation alloc] initWithOperand:[self.operandFactory createFromInstructionOperandValue:operandValue] cpuStateOperations:cpuStateOperations];
            operationB = nil;
            
            CPUInstruction* jsrInstruction = [[CPUInstruction alloc] initWithOperationA:operationA andOperationB:operationB];
            
            return jsrInstruction;
        }
    }
    
    ushort operandAValue = (code >> OperandAShift) & OperandAMask;
    ushort operandBValue = (code >> OperandBShift) & OperandBMask;
    
    operationA = [[CPUOperation alloc] initWithOperand:[self.operandFactory createFromInstructionOperandValue:operandAValue] cpuStateOperations:cpuStateOperations];
    operationB = [[CPUOperation alloc] initWithOperand:[self.operandFactory createFromInstructionOperandValue:operandBValue] cpuStateOperations:cpuStateOperations];

    return [instructionMapper objectForKey:[NSNumber numberWithInt:opcode]];
}

@end
