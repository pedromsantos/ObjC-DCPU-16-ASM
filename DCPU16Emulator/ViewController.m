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

#import "ViewController.h"
#import "InstructionCell.h"
#import "DCPU.h"
#import "Assembler.h"
#import "Parser.h"

@implementation ViewController

@synthesize emulator;
@synthesize mapRegisterNameToControl;
@synthesize currentInstructionLabel;
@synthesize currentIbstructionOpCode;
@synthesize currentIbstructionOperend1;
@synthesize currentIbstructionOperand2;
@synthesize instructionTableView;
@synthesize instructionSet;
@synthesize assembledInstructionSet;

@synthesize instructionButtonCollection;
@synthesize enterButton;
@synthesize clearButton;
@synthesize literalButton;
@synthesize labelButton;
@synthesize referenceButton;
@synthesize inputField;
@synthesize assembledCodeLabel;
@synthesize currentInstruction;

- (IBAction)instructionButtonPressed:(UIButton *)sender 
{
    [self.currentInstruction assignValue:sender.titleLabel.text];
    
    [self setProgramingKeyboardState];
    
    [self bindCurrentInstruction];
}

- (IBAction)clsButtonPressed 
{
    [self.currentInstruction reset];
    
    [self setProgramingKeyboardState];
    
    [self bindCurrentInstruction];
}

- (IBAction)enterButtonPressed 
{
    [self.instructionSet addObject:self.currentInstruction];
    [self.instructionTableView reloadData];
    
    self.currentInstruction = nil;
    self.currentInstruction = [[Instruction alloc] init];
    
    [self clearCurrentInstructionBind];
    [self setProgramingKeyboardState];
}

- (IBAction)literalButtonPressed 
{
    NSString* data = self.inputField.text;
    
    [self.currentInstruction assignValue:data];
    
    [self setProgramingKeyboardState];
    
    [self bindCurrentInstruction];
}

- (IBAction)labelButtonPresssed 
{
    NSString* data = self.inputField.text;
    
    if([data hasPrefix:@":"])
    {
        [self.currentInstruction assignLabel:data];
    }
    else 
    {
        [self.currentInstruction assignLabel:[NSString stringWithFormat:@":%@", data]];
    }
    
    [self setProgramingKeyboardState];
    
    [self bindCurrentInstruction];
}

- (IBAction)referenceButtonPressed 
{
    NSString* data = self.inputField.text;
    
    if([data hasPrefix:@"["] && [data hasSuffix:@"]"])
    {
        [self.currentInstruction assignValue:data];
    }
    else if(![data hasPrefix:@"["] && ![data hasSuffix:@"]"])
    {
        [self.currentInstruction assignValue:[NSString stringWithFormat:@"[%@]", data]];
    }
    else if([data hasPrefix:@"["] && ![data hasSuffix:@"]"])
    {
        [self.currentInstruction assignValue:[NSString stringWithFormat:@"%@]", data]];
    }
    else if(![data hasPrefix:@"["] && [data hasSuffix:@"]"])
    {
        [self.currentInstruction assignValue:[NSString stringWithFormat:@"[%@", data]];
    }
    
    [self setProgramingKeyboardState];
    
    [self bindCurrentInstruction];
}

- (IBAction)assembleButtonPressed 
{
    NSMutableString *source = [NSMutableString string];
    
    for (Instruction* instruction in self.instructionSet)
    {
        [source appendString:[NSString stringWithFormat:@"%@ %@ %@, %@\n", 
                              instruction.label != nil ? instruction.label : @"", 
                              instruction.opcode != nil ? instruction.opcode : @"", 
                              instruction.operand1 != nil ? instruction.operand1 : @"", 
                              instruction.operand2 != nil ? instruction.operand2 : @""]];
    }
    
    NSString *code = source;
    
    Parser *p = [[Parser alloc] init];
    
    [p parseSource:code];
    
    Assembler *assembler = [[Assembler alloc] init];
    
    [assembler assembleStatments:p.statments];
    
    int programInstructionSize = [assembler.program count];
    
    NSMutableString *assembledCode = [NSMutableString string];
    self.assembledInstructionSet = nil;
    
    self.assembledInstructionSet = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < programInstructionSize; i++) 
    {
        int assembledInstruction = [[assembler.program objectAtIndex:i] intValue];
        
        [self.assembledInstructionSet addObject:[assembler.program objectAtIndex:i]];
        [assembledCode appendString:[NSString stringWithFormat:@"0x%X ", assembledInstruction]];
    }
    
    assembledCodeLabel.text = assembledCode;
    assembledCodeLabel.numberOfLines = 0;
    [assembledCodeLabel sizeToFit];
    
    self.emulator = [[DCPU alloc] initWithProgram:(self.assembledInstructionSet)];
    
    self.emulator.memory.registerDidChange = ^(NSString* registerName, int value)
    {
        int regIndex = [[self.mapRegisterNameToControl objectForKey:registerName] intValue];
        
        UILabel* registerControlToUpdate = ((UILabel*)[self.view viewWithTag:regIndex + 1000]);
        
        registerControlToUpdate.text = [NSString stringWithFormat:@"0x%X", value];
    };
    
    self.emulator.memory.generalRegisterDidChange = ^(int regIndex, int value)
    {
        UILabel* registerControlToUpdate = ((UILabel*)[self.view viewWithTag:regIndex + 1003]);
        
        registerControlToUpdate.text = [NSString stringWithFormat:@"0x%X", value];
    };
}

- (IBAction)nextButtonPressed 
{
    if(self.assembledInstructionSet != nil && [self.assembledInstructionSet count] > 0 && self.emulator != nil)
    {
        [self.emulator executeInstruction];
    }
}

- (void)bindCurrentInstruction
{
    self.currentInstructionLabel.text = currentInstruction.label;
    self.currentIbstructionOpCode.text = currentInstruction.opcode;
    self.currentIbstructionOperend1.text = currentInstruction.operand1;
    self.currentIbstructionOperand2.text = currentInstruction.operand2;
}

- (void)clearCurrentInstructionBind
{
    self.currentInstructionLabel.text = @"";
    self.currentIbstructionOpCode.text = @"";
    self.currentIbstructionOperend1.text = @"";
    self.currentIbstructionOperand2.text = @"";
}

- (void)setProgramingKeyboardState
{
    NSArray* possibleNextInput = [self.currentInstruction possibleNextInput];
    
    for (UIButton* button in self.instructionButtonCollection)
    {
        [button setEnabled:NO];
    }
    
    for (UIButton* button in self.instructionButtonCollection)
    {
        for (NSString* title in possibleNextInput)
        {
            NSString* buttonLabelText = button.titleLabel.text;
            
            if ([buttonLabelText isEqualToString:title]) 
            {
                [button setEnabled:YES];
                continue;
            }
        }
    }
    
    [self.enterButton setEnabled:self.currentInstruction.state == Complete];
    [self.labelButton setEnabled:self.currentInstruction.state == WaitForOpcodeOrLabel];
    [self.literalButton setEnabled:self.currentInstruction.state == WaitForOperand1 || self.currentInstruction.state == WaitForOperand2];
    [self.referenceButton setEnabled:self.currentInstruction.state == WaitForOperand1 || self.currentInstruction.state == WaitForOperand2];
    [self.inputField setEnabled:self.currentInstruction.state == WaitForOpcodeOrLabel || self.currentInstruction.state == WaitForOperand1 || self.currentInstruction.state == WaitForOperand2];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.instructionSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"instructionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyCellIdentifier];
    }
    
    NSArray *instructionCellList = [self loadNibForCellInTable:tableView];
    
    for (id obj in instructionCellList)
    {
        if ([obj isKindOfClass:[InstructionCell class]])
        {
            Instruction *instruction = [self.instructionSet objectAtIndex:(NSUInteger)indexPath.row];
            cell = [obj drawCellForInstruction:instruction];
        }
    }
    
    return cell;
}

- (NSArray *)loadNibForCellInTable:(UITableView *)tableView
{
    return [[NSBundle mainBundle] loadNibNamed:@"instructionCell" owner:nil options:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.instructionTableView reloadData];
    
    self.instructionSet = [[NSMutableArray alloc] init];
    
    self.mapRegisterNameToControl = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"PC", [NSNumber numberWithInt:1000],
                                     @"SP", [NSNumber numberWithInt:1001],
                                     @"O", [NSNumber numberWithInt:1002],
                                     @"A", [NSNumber numberWithInt:1003],
                                     @"B", [NSNumber numberWithInt:1004],
                                     @"C", [NSNumber numberWithInt:1005],
                                     @"X", [NSNumber numberWithInt:1006],
                                     @"Y", [NSNumber numberWithInt:1007],
                                     @"Z", [NSNumber numberWithInt:1008],
                                     @"I", [NSNumber numberWithInt:1009],
                                     @"J", [NSNumber numberWithInt:1010],
                                     nil];
    
    [self setProgramingKeyboardState];
}

- (void)viewDidUnload
{
    [self setInstructionButtonCollection:nil];
    [self setInstructionTableView:nil];
    [self setCurrentInstructionLabel:nil];
    [self setCurrentIbstructionOpCode:nil];
    [self setCurrentIbstructionOperend1:nil];
    [self setCurrentIbstructionOperand2:nil];
    [self setEnterButton:nil];
    [self setClearButton:nil];
    [self setLiteralButton:nil];
    [self setLabelButton:nil];
    [self setReferenceButton:nil];
    [self setInputField:nil];
    [self setAssembledCodeLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}

@end
