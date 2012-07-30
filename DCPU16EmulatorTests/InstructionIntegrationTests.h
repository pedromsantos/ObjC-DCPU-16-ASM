//
//  InstructionIntegrationTests.h
//  DCPU16Emulator
//
//  Created by Administrator on 7/30/12.
//  Copyright (c) 2012 Spenta Consulting SL. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface InstructionIntegrationTests : SenTestCase

@property(nonatomic, assign) Class expectedInstructionType;
@property(nonatomic, assign) short inputValue;

- (id)initWithInvocation:(NSInvocation *)anInvocation inputValue:(ushort)value expectedInstructionType:(Class)expectedOprnd;

@end
