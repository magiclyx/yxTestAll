//
//  errInfo.c
//  360ClientUI
//
//  Created by Yuxi Liu on 10/31/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#include <stdio.h>
#include <errno.h>
#include <MacTypes.h>
//#include <CoreServices/CoreServices.h>


#include "errInfo.h"


int OSStatusToErrno(OSStatus_dummy errNum)
{
//	int retval;
//    
//#define CASE(ident)         \
//case k ## ident ## Err: \
//retval = ident;     \
//break
//    switch (errNum) {
//		case noErr:
//			retval = 0;
//			break;
//        case kENORSRCErr:
//            retval = ESRCH;                 // no ENORSRC on Mac OS X, so use ESRCH. this fucking stuff is reference the apple sample.
//            break;
//        case memFullErr:
//            retval = ENOMEM;
//            break;
//            CASE(EDEADLK);
//            CASE(EAGAIN);
//		case kEOPNOTSUPPErr:
//			retval = ENOTSUP;
//			break;
//            CASE(EPROTO);
//            CASE(ETIME);
//            CASE(ENOSR);
//            CASE(EBADMSG);
//        case kECANCELErr:
//            retval = ECANCELED;             // note spelling difference
//            break;
//            CASE(ENOSTR);
//            CASE(ENODATA);
//            CASE(EINPROGRESS);
//            CASE(ESRCH);
//            CASE(ENOMSG);
//        default:
//            
//#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_7
//            if ( (errNum <= kEPERMErr) && (errNum >= kENOMSGErr) ) {
//				retval = (-3200 - errNum) + 1;				// OT based error
//#ifdef errSecErrnoBase
//            } else if ( (errNum >= errSecErrnoBase) && (errNum <= (errSecErrnoBase + ELAST)) ) {
//                retval = (int) errNum - errSecErrnoBase;	// POSIX based error
//#endif //errSecErrnoBase
//            } else {
//				retval = (int) errNum;						// just return the value unmodified
//			}
//#else
//            retval = (int) errNum;	
//#endif //__MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_7
//    }
//#undef CASE
    return 0;
}
;