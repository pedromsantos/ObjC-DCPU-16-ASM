//
//  IgnoreWhiteSpaceTokenStrategy.m
//  DCPU16Emulator
//
//  Created by Jordi Plana on 6/13/12.
//  Copyright (c) 2012 Spenta Consulting SL. All rights reserved.
//

#import "IgnoreWhiteSpaceTokenStrategy.h"

@implementation IgnoreWhiteSpaceTokenStrategy

- (bool)isTokenToBeIgnored:(enum LexerTokenType)token
{
    return token == WHITESPACE;
}

@end
