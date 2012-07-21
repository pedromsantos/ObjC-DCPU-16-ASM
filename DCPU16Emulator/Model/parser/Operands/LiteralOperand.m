//
//  LiteralOperand.m
//  DCPU16Emulator
//
//  Created by Jordi Plana on 6/10/12.
//  Copyright (c) 2012 Spenta Consulting SL. All rights reserved.
//

#import "LiteralOperand.h"

@implementation LiteralOperand

- (ushort)read
{
    return self.value - 0x20 % NUMBER_OF_LITERALS;
}

@end
