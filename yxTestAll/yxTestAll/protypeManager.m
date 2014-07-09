//
//  protypeManager.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/13/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "protypeManager.h"
#import "rootTableController.h"

@interface protypeInfo(){
}
@property (readwrite, retain, nonatomic) NSString *category;
@property (readwrite, retain, nonatomic) NSString *key;
@property (readwrite, retain, nonatomic) NSMutableArray *subProtypeInfo;
@property (readwrite, retain, nonatomic) protypeInfo* parentInfo;
@end



NSString* const protypeCategory_base = @"basic_control";

@interface protypeManager(){
    NSMutableDictionary *_categorys;
    NSString *_currentCategory;
    
    NSMutableDictionary *_currentCategoryMapping;
    NSMutableArray *_currentCategoryArray;
    
}

@property (readwrite, retain, nonatomic) NSMutableDictionary* currentCategoryMapping;
@property (readwrite, retain, nonatomic) NSMutableArray *currentCategoryArray;

- (void)_setUpMappingWithProtypeInfo:(protypeInfo *)info;
- (void)_loadConfigure;
- (void)_regist_ProtypeWithDict:(NSDictionary*)dict andParentKey:(NSString*)parentKey;

@end

@implementation protypeManager

@synthesize currentCategoryMapping = _currentCategoryMapping;
@synthesize currentCategoryArray = _currentCategoryArray;

- (id)init{
    self = [super init];
    if (self) {
        _categorys = [[NSMutableDictionary dictionary] retain];
        _currentCategoryMapping = [[NSMutableDictionary dictionary] retain];
        _currentCategoryArray = [[NSMutableArray array] retain];
        
        [self setCurrentCategory:nil];
        
        [self _loadConfigure];
    }
    
    return self;
}

-(void)dealloc{
    
    [_currentCategory release], _currentCategory = nil;
    [_categorys release], _categorys = nil;
    
    [_currentCategoryArray release], _currentCategoryArray = nil;
    [_currentCategoryMapping release], _currentCategoryMapping = nil;
    
    [super dealloc];
}

- (NSString *)currentCategory{
    return _currentCategory;
}

- (void)setCurrentCategory:(NSString *)currentCategory{
    
    /*...*/
    if (nil == currentCategory)
        return;
    
    /*如果相同，不进行赋值操作*/
    if (YES == [_currentCategory isEqualToString:currentCategory])
        return;
    
    /*赋值*/
    [currentCategory retain];
    [_currentCategory release];
    _currentCategory = currentCategory;
    
    
    /*获取当前Category*/
    protypeInfo *rootPage = [_categorys objectForKey:currentCategory];
    if (nil == rootPage) {
        rootPage = [protypeInfo menuInfoWithTitle:[NSString stringWithFormat:@"[root]%@", currentCategory]];
        
        [rootPage setData:[NSMutableDictionary dictionary]];
        
        [_categorys setObject:rootPage forKey:currentCategory];
    }
    
    /*mapping dict 是引用*/
    [self setCurrentCategoryMapping:rootPage.data];
    
    
    /*mapping array 是 一个新的array*/
    NSMutableArray* infoArray = [NSMutableArray arrayWithArray:[rootPage.data allValues]];
    [self setCurrentCategoryArray:infoArray];
}

+ (id)sharedManager
{
    static dispatch_once_t  onceToken;
    static id sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


- (void)registRootInfo:(protypeInfo*)info withCategory:(NSString *)category andKey:(NSString *)key{
    
    assert(nil != info);
    assert(nil != category);
    assert(nil != key);
    
    
    /*init info*/
    [info setCategory:category];
    [info setKey:key];
    [info setParentInfo:nil];
    [info setSubProtypeInfo:nil];
    
    
    protypeInfo* rootPage = [_categorys objectForKey:category];
    if (nil == rootPage) {
        //rootPage = [protypeInfo menuInfoWithTitle:[NSString stringWithFormat:@"[root]%@", category]];
        rootPage = [protypeInfo menuInfoWithTitle:info.title];
        [rootPage setKey:category];
        [rootPage setParentInfo:nil];
        [rootPage setData:[NSMutableDictionary dictionary]];
        [_categorys setObject:rootPage forKey:category];
    }
    
    
    /*插入root字典*/
    [[rootPage data] setObject:info forKey:info.key];
    
    /*加入子info*/
    NSMutableArray* infoArray = [rootPage subProtypeInfo];
    if (nil == infoArray) {
        infoArray = [NSMutableArray array];
        [rootPage setSubProtypeInfo:infoArray];
    }
    [infoArray addObject:info];
    
    
    if ([category isEqualToString:[self currentCategory]]) {
        [_currentCategoryArray addObject:info];
    }
}

- (BOOL)registInfo:(protypeInfo*)info withParentKey:(NSString*)parentKey andKey:(NSString *)key{
    
    BOOL done = NO;
    NSArray* allRootPageKey = [_categorys allKeys];
    for (NSString* rootPageKey in allRootPageKey) {
        
        protypeInfo* rootPage = [_categorys objectForKey:rootPageKey];
        
        NSMutableDictionary* mapping = rootPage.data;
        protypeInfo* parentInfo = [mapping objectForKey:parentKey];
        
        if (nil != parentInfo) {
            
            /*init info*/
            [info setCategory:rootPage.category];
            [info setKey:key];
            [info setParentInfo:parentInfo];
            [info setSubProtypeInfo:nil];
            
            
            /*add to root map*/
            [mapping setObject:info forKey:info.key];
            
            /*add to parent info*/
            NSMutableArray* subInfoArray = [parentInfo subProtypeInfo];
            if (nil == subInfoArray) {
                subInfoArray = [NSMutableArray array];
                [parentInfo setSubProtypeInfo:subInfoArray];
            }
            
            [subInfoArray addObject:info];
            
            /*done*/
            done = YES;
        }
    }
    
    return done;
}

- (NSArray*)allCategory{
    return [_categorys allValues];
}

- (NSUInteger)count{
    return [_currentCategoryArray count];
}
- (protypeInfo *)protypeAtIndex:(NSUInteger)index{
    return [_currentCategoryArray objectAtIndex:index];
}
- (protypeInfo *)protypeForKey:(NSString*)key{
    return [_currentCategoryMapping objectForKey:key];
}
- (protypeInfo *)rootProtypeInfo{
    protypeInfo* root = [_categorys objectForKey:self.currentCategory];
    
    assert(nil != root);
    assert(0 != [[root subProtypeInfo] count]);
    
    return [[root subProtypeInfo] objectAtIndex:0];
}


#pragma Enumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len{
    return [_currentCategoryArray countByEnumeratingWithState:state objects:buffer count:len];
}

- (NSEnumerator *)objectEnumerator{
    return [_currentCategoryArray objectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator{
    return [_currentCategoryArray reverseObjectEnumerator];
}

- (NSEnumerator *)keyEnumerator{
    return [_currentCategoryMapping keyEnumerator];
}

#pragma private
- (void)_setUpMappingWithProtypeInfo:(protypeInfo *)info{
    [_currentCategoryMapping setObject:info forKey:info.key];
    [_currentCategoryArray addObject:info];
    
    NSArray* allSubInfo = [info subProtypeInfo];
    if (nil != allSubInfo) {
        for (protypeInfo* info in allSubInfo) {
            [self _setUpMappingWithProtypeInfo:info];
        }
    }
}


- (void)_regist_ProtypeWithDict:(NSDictionary*)dict andParentKey:(NSString*)parentKey{
    NSString *type = [dict objectForKey:@"type"];
    NSString *title = [dict objectForKey:@"title"];
    NSString *key = [dict objectForKey:@"key"];
    NSArray* allSubInfo = [dict objectForKey:@"subProTypes"];
    
    if (nil == type  ||  nil == title || nil == key)
        return;
    
    if ([type isEqualToString:@"category"]) {
        
        NSString* category = [dict objectForKey:@"category"];
        if (nil == category)
            return;
        
        protypeInfo* info = [protypeInfo menuInfoWithTitle:title];
        [self registRootInfo:info withCategory:category andKey:key];
    }
    else if([type isEqualToString:@"menu"]){
        
        if (nil == parentKey)
            return;
        
        protypeInfo* info = [protypeInfo menuInfoWithTitle:title];
        [self registInfo:info withParentKey:parentKey andKey:key];
    }
    else if([type isEqualToString:@"showcase"]){
        
        if (nil == parentKey)
            return;
        
        NSString* clasName = [dict objectForKey:@"class"];
        if (nil == clasName)
            return;
        
        Class cls = NSClassFromString(clasName);
        if (NULL == cls)
            return;
        
        protypeInfo* info = [protypeInfo showcaseInfoWithTitle:title class:cls];
        [self registInfo:info withParentKey:parentKey andKey:key];
    }
    
    
    
    if (nil != allSubInfo  &&  [allSubInfo isKindOfClass:[NSArray class]]) {
        for (NSDictionary* subInfoDict in allSubInfo){
            if (nil != subInfoDict  &&  YES == [subInfoDict isKindOfClass:[NSDictionary class]]) {
                [self _regist_ProtypeWithDict:(NSDictionary*)subInfoDict andParentKey:key];
            }
            
        }
    }
    
    
    
}

- (void)_loadConfigure{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"moduleList" ofType:@"plist"];
    if (nil == path)
        return;
    
    
    NSDictionary* config = [NSDictionary dictionaryWithContentsOfFile:path];
    if (nil == config)
        return;
    
    /*取出东西*/
    NSString* defaultCategory = [config objectForKey:@"defaultCategory"];
    NSDictionary* tree = [config objectForKey:@"tree"];
    
    
    /*注册所有protype*/
    NSArray* allItemKeys = [tree allKeys];
    for (NSString* key in allItemKeys) {
        /*取出一个CategoryDict*/
        
        id<NSObject> obj = [tree objectForKey:key];
        if (NO == [obj isKindOfClass:[NSDictionary class]])
            continue;
        
        [self _regist_ProtypeWithDict:(NSDictionary*)obj andParentKey:nil];
    }
    
    
    
    if (nil != defaultCategory) {
        [self setCurrentCategory:defaultCategory];
    }
}



@end
////////////////////////////////////////////////////////////////////////////////
@implementation protypeInfo

- (id)init{
    self = [super init];
    if (self) {
        [self setTitle:nil];
        [self setCls:NULL];
        [self setSubTitle:nil];
        [self setKey:nil];
        [self setCategory:nil];
        [self setSubProtypeInfo:nil];
        [self setParentInfo:nil];
    }
    
    return self;
}

- (void)dealloc
{
    
    [_title release], _title = nil;
    [_subTitle release], _subTitle = nil;
    [_category release], _category = nil;
    [_key release], _key = nil;
    [_subProtypeInfo release], _subProtypeInfo = nil;
    [_parentInfo release], _parentInfo = nil;
    
    [super dealloc];
}


+ (id)showcaseInfoWithTitle:(NSString *)title class:(Class)cls{
    protypeInfo* inst = (protypeInfo *)[[[[self class] alloc] initShowcaseWithTitle:title class:cls] autorelease];
    
    return  inst;
}

- (id)initShowcaseWithTitle:(NSString *)title class:(Class)cls{
    protypeInfo* inst = (protypeInfo *)[self init];
    [inst setTitle:title];
    [inst setCls:cls];
    
    return inst;
}


- (id)initMenuInfoWithTitle:(NSString *)title{
    return [self initShowcaseWithTitle:title class:[rootTableController class]];
}
+ (id)menuInfoWithTitle:(NSString *)title{
    return [self showcaseInfoWithTitle:title class:[rootTableController class]];
}


@end






