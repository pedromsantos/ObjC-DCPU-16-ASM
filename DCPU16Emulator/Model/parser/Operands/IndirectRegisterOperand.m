//
//  IndirectRegisterOperand.m
//  DCPU16Emulator
//
//  Created by Jordi Plana on 6/10/12.
//  Copyright (c) 2012 Spenta Consulting SL. All rights reserved.
//

#import "IndirectRegisterOperand.h"

@implementation IndirectRegisterOperand

- (ushort)read
{
    ushort address = (ushort) [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
    return (ushort) [self.cpuOperations readMemoryValueAtAddress:address];
}

- (void)writeValue:(ushort)value
{
    ushort address = (ushort) [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
    [self.cpuOperations writeMemoryAtAddress:address withValue:value];
}

- (void)process
{
    [self.cpuOperations incrementProgramCounter];
    int programCounter = [self.cpuOperations programCounter];
    self.nextWord = (uint16_t) [self.cpuOperations readMemoryValueAtAddress:programCounter];
    self.registerValue = (enum operand_register_value) [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
}

- (int)assembleWithShift:(int)shift
{
    return (O_INDIRECT_REG + self.registerValue) << shift;
}

@end
