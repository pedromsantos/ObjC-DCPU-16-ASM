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

#import "OperandFactory.h"
#import "RegisterOperandBuilder.h"
#import "LabelReferenceOperandBuilder.h"
#import "NextWordOperandBuilder.h"
#import "IndirectRegisterOperandBuilder.h"
#import "IndirectNextWordOperandBuilder.h"

typedef Operand *(^creationStrategy)(Match *);

@implementation OperandFactory

@synthesize directOperandCreationStrategyMapper;
@synthesize indirectOperandCreationStrategyMapper;

- (id)init
{
    self = [super init];

    self.directOperandCreationStrategyMapper = [NSDictionary dictionaryWithObjectsAndKeys:
            (Operand *) ^(Match *m)
            {
                return [[[RegisterOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:REGISTER],
            (Operand *) ^(Match *m)
            {
                return [[[LabelReferenceOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:LABELREF],
            (Operand *) ^(Match *m)
            {
                return [[[NextWordOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:HEX],
            (Operand *) ^(Match *m)
            {
                return [[[NextWordOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:INT],
            nil];

    self.indirectOperandCreationStrategyMapper = [NSDictionary dictionaryWithObjectsAndKeys:
            (Operand *) ^(Match *m)
            {
                return [[[IndirectRegisterOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:REGISTER],
            (Operand *) ^(Match *m)
            {
                return [[[LabelReferenceOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:LABELREF],
            (Operand *) ^(Match *m)
            {
                return [[[IndirectNextWordOperandBuilder alloc] init] buildFromMatch:m];
            },
            [NSNumber numberWithInt:HEX],
            nil];

    return self;
}

- (Operand *)createDirectOperandForMatch:(Match *)match
{
    creationStrategy strategy = [directOperandCreationStrategyMapper objectForKey:[NSNumber numberWithInt:match.token]];

    if (strategy == nil)
    {
        return nil;
    }

    return strategy(match);
}

- (Operand *)createIndirectOperandForMatch:(Match *)match
{
    creationStrategy strategy = [indirectOperandCreationStrategyMapper objectForKey:[NSNumber numberWithInt:match.token]];

    if (strategy == nil)
    {
        return nil;
    }

    return strategy(match);
}

@end
