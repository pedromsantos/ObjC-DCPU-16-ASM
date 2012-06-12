//
//  IndirectRegisterOperand.m
//  DCPU16Emulator
//
//  Created by Jordi Plana on 6/10/12.
//  Copyright (c) 2012 Spenta Consulting SL. All rights reserved.
//

#import "IndirectRegisterOperand.h"

@implementation IndirectRegisterOperand

- (int)assembleWithShift:(int)shift
{
    return (O_INDIRECT_REG + self.registerValue) << shift;
}

@end
