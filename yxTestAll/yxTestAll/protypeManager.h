//
//  protypeManager.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/13/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface protypeInfo : NSObject

@property (readwrite, retain, nonatomic) id data;
@property (readwrite, retain, nonatomic) NSString *title;
@property (readwrite, retain, nonatomic) NSString *subTitle;
@property (readwrite, assign) Class cls;

@property (readonly, retain, nonatomic) NSString *category;
@property (readonly, retain, nonatomic) NSString *key;
@property (readonly, retain, nonatomic) NSMutableArray *subProtypeInfo;
@property (readonly, retain, nonatomic) protypeInfo* parentInfo;


- (id)initShowcaseWithTitle:(NSString *)title class:(Class)cls;
+ (id)showcaseInfoWithTitle:(NSString *)title class:(Class)cls;

- (id)initMenuInfoWithTitle:(NSString *)title;
+ (id)menuInfoWithTitle:(NSString *)title;


@end


@interface protypePage : NSObject<NSFastEnumeration>

@property (readwrite, assign) protypePage* parentPage;

@property (readwrite, retain, nonatomic) NSMutableArray *infoList;

@end



extern NSString* const protypeCategory_base;


@interface protypeManager : NSObject <NSFastEnumeration>

/*working on category*/
@property (readwrite, retain, nonatomic) NSString* currentCategory;
- (NSArray*)allCategory;


/*regist an item*/
+ (id)sharedManager;
- (void)registRootInfo:(protypeInfo*)info withCategory:(NSString *)category andKey:(NSString *)key;
- (BOOL)registInfo:(protypeInfo*)info withParentKey:(NSString*)parentKey andKey:(NSString *)key;


/*working on current category*/
- (NSUInteger)count;
- (protypeInfo *)protypeAtIndex:(NSUInteger)index;
- (protypeInfo *)protypeForKey:(NSString*)key;
- (protypeInfo *)rootProtypeInfo;


- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;
- (NSEnumerator *)keyEnumerator;

@end




