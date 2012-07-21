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
    ushort address = [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
    return [self.cpuOperations readMemoryValueAtAddress:address];
}

- (void)writeValue:(ushort)value
{
    ushort address = [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
    [self.cpuOperations writeMemoryAtAddress:address withValue:value];
}

- (void)process
{
    [self.cpuOperations incrementProgramCounter];
    int programCounter = [self.cpuOperations programCounter];
    self.nextWord = [self.cpuOperations readMemoryValueAtAddress:programCounter];
    self.registerValue = [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
}

- (int)assembleWithShift:(int)shift
{
    return (O_INDIRECT_REG + self.registerValue) << shift;
}

@end
