//
//  common_remoteCall.h
//  clilib
//
//  Created by Yuxi Liu on 1/6/13.
//
//

#ifndef clilib_common_remoteCall_h
#define clilib_common_remoteCall_h

#import <Foundation/Foundation.h>


typedef enum{
    remoteCall_err_success = 0, //must be zero
    remoteCall_err_unknown = 1,
    remoteCall_err_timeout = 2,
    remoteCall_err_param = 3,
}remoteCallErr;


typedef enum{
    remoteCall_logLevel_emerg,
    remoteCall_logLevel_alert,
    remoteCall_logLevel_crit,
    remoteCall_logLevel_err,
    remoteCall_logLevel_warning,
    remoteCall_logLevel_notice,
    remoteCall_logLevel_info,
    remoteCall_logLevel_debug
}remoteCall_logLevel;




/*
 these key using for the connection.
 search it in socket pack. it's a kind of xml file.
 */




extern const NSString* remoteKeyType;


/**/extern const NSString* remoteMsgRegister;
/*--*/extern const NSString* remoteKeyClientName;
/*--*/extern const NSString* remoteKeyClientProcessID;

/**/extern const NSString* rmoteMsgRegisterResponds;
/*--*/extern const NSString* remoteKeyRegisterResult;



/**/extern const NSString* remoteMsgFunCall;
/*--*/extern const NSString* remoteKeyFunName; 
/*--*/extern const NSString* remoteKeyWait;
/*--*/extern const NSString* remoteKeyIndex; 
/*--*/extern const NSString* remoteKeyErrNum;
/*--*/extern const NSString* remoteKeyParamFormat;

/**/extern const NSString* remoteMsgFunReturn;
/*--*/extern const NSString* remoteKeyReturnVal;





#endif

















