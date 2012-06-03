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

@implementation ViewController

@synthesize currentInstructionLabel;
@synthesize currentIbstructionOpCode;
@synthesize currentIbstructionOperend1;
@synthesize currentIbstructionOperand2;
@synthesize instructionTableView;
@synthesize instructionSet;

@synthesize instructionButtonCollection;
@synthesize enterButton;
@synthesize clearButton;
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
