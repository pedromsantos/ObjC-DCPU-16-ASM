//
//  InstructionIntegrationTests.m
//  DCPU16Emulator
//
//  Created by Administrator on 7/30/12.
//  Copyright (c) 2012 Spenta Consulting SL. All rights reserved.
//

#import "InstructionIntegrationTests.h"
#import "InstructionBuilder.h"
#import "CPUInstruction.h"
#import "InstructionOperandFactory.h"
#import "Add.h"
#import "And.h"
#import "Bor.h"
#import "Div.h"
#import "Ifb.h"
#import "Ife.h"
#import "Ifg.h"
#import "Ifn.h"
#import "Jsr.h"
#import "Mod.h"
#import "Mul.h"
#import "Set.h"
#import "Shl.h"
#import "Shr.h"
#import "Sub.h"
#import "Xor.h"

@implementation InstructionIntegrationTests


@synthesize expectedInstructionType;
@synthesize inputValue;

- (id)initWithInvocation:(NSInvocation *)anInvocation inputValue:(short)value expectedInstructionType:(Class)expectedOprnd
{
    self = [super initWithInvocation:anInvocation];
    
    if (self)
    {
        self.expectedInstructionType = expectedOprnd;
        self.inputValue = value;
    }
    
    return self;
}

- (void)testBuildWhenCalledForRawInstructionBuildsExpectedInstructionInstance
{
    InstructionOperandFactory *factory = [[InstructionOperandFactory alloc] init];
    InstructionBuilder *builder = [[InstructionBuilder alloc] initWithInstructionOperandFactory:factory];
    
    CPUInstruction *instruction = [builder buildFromMachineCode:self.inputValue usingCpuState:nil];
    
    STAssertTrue([instruction isKindOfClass:self.expectedInstructionType], nil);
}

+ (void)addTestCreateWhenCalledWithValueinput:(ushort)inputValue createsExpectedInstructionType:(Class)expectedInstruction
                                         toTestSuite:(SenTestSuite *)testSuite
{
    NSArray *testInvocations = [self testInvocations];
    
    for (NSInvocation *testInvocation in testInvocations)
    {
        SenTestCase *test = [[InstructionIntegrationTests alloc]
                             initWithInvocation:testInvocation
                             inputValue:inputValue
                             expectedInstructionType:expectedInstruction];
        
        [testSuite addTest:test];
    }
}

+ (id)defaultTestSuite
{
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];
    
    [self addTestCreateWhenCalledWithValueinput:0x7c01 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0x7de1 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0xA861 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0x9031 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0x8463 createsExpectedInstructionType:[Sub class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0x8463 createsExpectedInstructionType:[Sub class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0x7803 createsExpectedInstructionType:[Sub class] toTestSuite:testSuite];
    [self addTestCreateWhenCalledWithValueinput:0x9037 createsExpectedInstructionType:[Shl class] toTestSuite:testSuite];
    
    return testSuite;
}

@end
