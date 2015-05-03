//
//  cfgManager.m
//  clilib
//
//  Created by Yuxi Liu on 1/4/13.
//
//

#import "cfgManager.h"


@implementation cfgManager


const static unsigned int default_base = 11;
const static unsigned int default_level = 11;

static NSString* const keyLinkedCfgFile = @"keyReplaceCfgFile";
static NSString* const BundleIDIndicator = @"BundleIDIndicator";  //if the path ID is a "BundleIDIndicator", just searh the key from the bundle




-(cfgManager*) initWithDefaultConfigFile:(NSString*)filePath  errInfo:(cfgManagerErr*)pErr
{
        if(nil != (self = [super init])){
                _cfgArray = [[NSMutableArray alloc] initWithCapacity:2];
                
                
                NSString* path = filePath;
                while (NULL != path) {
                        
                        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile : path];
                        
                        
                        //NSMutableDictionary* dict = [NSMutableDictionary dictionaryWitFilePack:hPack];
                        
                        if(dict)
                        {
                        
                                [_cfgArray insertObject:dict atIndex:0]; //always insert at the first position.
                                path = [dict objectForKey:keyLinkedCfgFile];
                                
                                if(NO == [path isKindOfClass:[NSString class]])
                                        path = nil;
                        }else
                        {
                                path = nil;
                        }
                }
                
                
                if([_cfgArray count] == 0){
                        *pErr = cfgManager_err_noValidate;
                }
                
        }
        
        
        return self;
        
}


-(NSString*) getConfigFilePath:(NSString*)key{
    
    NSString* path = nil;
        
    for(NSDictionary* dict in _cfgArray)
    {
            path = [dict objectForKey:key];

            if(nil != path)
            {
                    break;
            }
    }
        
    return path;
}





-(void)dealloc{
    
    
    [_cfgArray release];
    _cfgArray = nil;
    
    [super dealloc];
}

@end
