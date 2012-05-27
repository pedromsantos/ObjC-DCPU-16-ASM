@interface Assembler : NSObject

@property (nonatomic, strong) NSMutableDictionary* labelDef;
@property (nonatomic, strong) NSMutableDictionary* labelRef;
@property (nonatomic, strong) NSMutableArray* program;

- (void)assembleStatments:(NSArray*)statments;

@end
