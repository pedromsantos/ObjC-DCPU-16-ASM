#import <Foundation/Foundation.h>

enum LexerTokenType
{
    INSTRUCTION = 0,
    REGISTER = 1,
    INT = 2,
    HEX = 3,
    STRING = 4,
    COMMA = 5,
    OPENBRACKET = 6,
    CLOSEBRACKET = 7,
    LABEL = 8,
    LABELREF = 9,
    PLUS = 10,
    WHITESPACE = 11,
    COMMENT = 12,
    ENDOFFILE = 13
};
