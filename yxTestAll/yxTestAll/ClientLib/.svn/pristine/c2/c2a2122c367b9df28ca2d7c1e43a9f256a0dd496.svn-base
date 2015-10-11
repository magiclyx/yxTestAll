//
//  cfgManager.h
//  clilib
//
//  Created by Yuxi Liu on 1/4/13.
//
//

#import <Foundation/Foundation.h>


typedef enum{
    cfgManager_err_success = 0,
    cfgManager_err_md5,
    cfgManager_err_noValidate
}cfgManagerErr;



@interface cfgManager : NSObject{
    
    @private
    NSMutableArray* _cfgArray;
}

-(cfgManager*) initWithDefaultConfigFile:(NSString*)filePath errInfo:(cfgManagerErr*)pErr;


-(NSString*) getConfigFilePath:(NSString*)key;
@end
