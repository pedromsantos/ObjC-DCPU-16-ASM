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

#import <UIKit/UIKit.h>
#import "Instruction.h"
#import "DCPU.h"
#import "Program.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(weak, nonatomic) IBOutlet UILabel *currentInstructionLabel;
@property(weak, nonatomic) IBOutlet UILabel *currentInstructionOpCode;
@property(weak, nonatomic) IBOutlet UILabel *currentInstructingOperand1;
@property(weak, nonatomic) IBOutlet UILabel *currentInstructingOperand2;
@property(weak, nonatomic) IBOutlet UITableView *instructionTableView;
@property(weak, nonatomic) IBOutlet UIButton *enterButton;
@property(weak, nonatomic) IBOutlet UIButton *clearButton;
@property(weak, nonatomic) IBOutlet UIButton *literalButton;
@property(weak, nonatomic) IBOutlet UIButton *labelButton;
@property(weak, nonatomic) IBOutlet UIButton *referenceButton;
@property(weak, nonatomic) IBOutlet UITextField *inputField;
@property(weak, nonatomic) IBOutlet UILabel *assembledCodeLabel;
@property(weak, nonatomic) IBOutletCollection(UIButton) NSArray *instructionButtonCollection;

- (IBAction)instructionButtonPressed:(UIButton *)sender;

- (IBAction)clsButtonPressed;

- (IBAction)enterButtonPressed;

- (IBAction)literalButtonPressed;

- (IBAction)labelButtonPressed;

- (IBAction)referenceButtonPressed;

- (IBAction)assembleButtonPressed;

- (IBAction)nextButtonPressed;

@end
