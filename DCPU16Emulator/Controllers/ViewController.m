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

@interface ViewController ()

@property (strong, nonatomic) NSArray* possibleNextInput;
@property (strong, nonatomic) NSDictionary* instructionData;
@property (strong, nonatomic) NSDictionary *mapRegisterNameToControl;
@property (strong, nonatomic) NSArray *instructionSet;
@property (strong, nonatomic) Program *program;
@property (strong, nonatomic) DCPU *emulator;

@end

@implementation ViewController

@synthesize program;
@synthesize emulator;
@synthesize instructionSet;
@synthesize instructionData;
@synthesize possibleNextInput;
@synthesize mapRegisterNameToControl;

@synthesize currentInstructionLabel;
@synthesize currentIbstructionOpCode;
@synthesize currentIbstructionOperend1;
@synthesize currentIbstructionOperand2;
@synthesize instructionTableView;

@synthesize instructionButtonCollection;
@synthesize enterButton;
@synthesize clearButton;
@synthesize literalButton;
@synthesize labelButton;
@synthesize referenceButton;
@synthesize inputField;
@synthesize assembledCodeLabel;

- (IBAction)instructionButtonPressed:(UIButton *)sender 
{
    [self.program assignValueToCurrentInstruction:sender.titleLabel.text];
}

- (IBAction)clsButtonPressed 
{
    [self.program resetCurrentInstruction];
}

- (IBAction)enterButtonPressed 
{
    [self.program FinishedInstructionEdit];
    [self.instructionTableView reloadData];
}

- (IBAction)literalButtonPressed 
{
    NSString* data = self.inputField.text;
    [self.program assignValueToCurrentInstruction:data];
}

- (IBAction)labelButtonPresssed 
{
    NSString* data = self.inputField.text;
    
    if([data hasPrefix:@":"])
    {
        [self.program assignLabelToCurrentInstruction:data];
    }
    else 
    {
        [self.program assignLabelToCurrentInstruction:[NSString stringWithFormat:@":%@", data]];
    }
}

- (IBAction)referenceButtonPressed 
{
    NSString* data = self.inputField.text;
    
    if([data hasPrefix:@"["] && [data hasSuffix:@"]"])
    {
        [self.program assignValueToCurrentInstruction:data];
    }
    else if(![data hasPrefix:@"["] && ![data hasSuffix:@"]"])
    {
        [self.program assignValueToCurrentInstruction:[NSString stringWithFormat:@"[%@]", data]];
    }
    else if([data hasPrefix:@"["] && ![data hasSuffix:@"]"])
    {
        [self.program assignValueToCurrentInstruction:[NSString stringWithFormat:@"%@]", data]];
    }
    else if(![data hasPrefix:@"["] && [data hasSuffix:@"]"])
    {
        [self.program assignValueToCurrentInstruction:[NSString stringWithFormat:@"[%@", data]];
    }
}

- (IBAction)nextButtonPressed 
{
    [self.emulator executeInstruction];
}

- (void)resetEmulator
{
    self.emulator = [[DCPU alloc] initWithProgram:(self.program.assembledInstructionSet)];
    
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

- (IBAction)assembleButtonPressed 
{
    assembledCodeLabel.text = [self.program assemble];
    assembledCodeLabel.numberOfLines = 0;
    [assembledCodeLabel sizeToFit];
    
    [self resetEmulator];
    [self resetCPULabels];
}

- (void)resetCPULabels
{
    for(int i = 1000; i <= 1010; i++)
    {
        UILabel* registerControlToUpdate = ((UILabel*)[self.view viewWithTag:i]);
        registerControlToUpdate.text = @"0x0";
    }
}

- (void)bindCurrentInstruction
{
    self.currentInstructionLabel.text = [self.instructionData objectForKey:@"label"];
    self.currentIbstructionOpCode.text = [self.instructionData objectForKey:@"opcode"];
    self.currentIbstructionOperend1.text = [self.instructionData objectForKey:@"operand1"];
    self.currentIbstructionOperand2.text = [self.instructionData objectForKey:@"operand2"];
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
    for (UIButton* button in self.instructionButtonCollection)
    {
        [button setEnabled:NO];
    }
    
    for (UIButton* button in self.instructionButtonCollection)
    {
        for (NSString* title in self.possibleNextInput)
        {
            NSString* buttonLabelText = button.titleLabel.text;
            
            if ([buttonLabelText isEqualToString:title]) 
            {
                [button setEnabled:YES];
                continue;
            }
        }
    }
    
    [self.enterButton setEnabled:[self instructionState] == Complete];
    [self.labelButton setEnabled:[self instructionState] == WaitForOpcodeOrLabel];
    [self.literalButton setEnabled:[self instructionState] == WaitForOperand1 || [self instructionState] == WaitForOperand2];
    [self.referenceButton setEnabled:[self instructionState] == WaitForOperand1 || [self instructionState] == WaitForOperand2];
    [self.inputField setEnabled:[self instructionState] == WaitForOpcodeOrLabel || [self instructionState] == WaitForOperand1 || [self instructionState] == WaitForOperand2];
}

- (int)instructionState
{
    return [[self.instructionData objectForKey:@"state"] intValue];
}

- (void) editStateChanged:(NSNotification *) notification
{
    self.possibleNextInput = [notification object];
    [self setProgramingKeyboardState];
}

- (void) instructionChanged:(NSNotification *) notification
{
    self.instructionData = [notification object];
    [self setProgramingKeyboardState];
    [self bindCurrentInstruction];
}

- (void) instructionSetChanged:(NSNotification *) notification
{
    self.instructionSet = [notification object];
    [self.instructionTableView reloadData];
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
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(editStateChanged:) name:@"EditStateChanged" object:nil];
    [center addObserver:self selector:@selector(instructionChanged:) name:@"InstructionChanged" object:nil];
    [center addObserver:self selector:@selector(instructionSetChanged:) name:@"InstructionSetChanged" object:nil];
    
    self.program = [[Program alloc] init];
    
    [self.instructionTableView reloadData];
    
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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
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
    
    [self setProgram:nil];
    
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
