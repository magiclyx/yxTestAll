//
//  systemInformation.m
//  sytemReport
//
//  Created by Yuxi Liu on 10/30/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//



#include <limits.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include <pwd.h>
#include <sys/stat.h>

#include <unistd.h>
#include <dirent.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/sysctl.h>
//#include <servers/bootstrap.h>
#include <mach/mach.h>
#include <libproc.h>
#include <Security/Security.h>
//#include <CoreServices/CoreServices.h>
//#include <DirectoryService/DirectoryService.h>

#import <regex.h>
#import <dirent.h>

#import "systemInformationByCommandLine.h"
#import "posix_popen.h"
#import "cmMem.h"
#import "errInfo.h"

static const int max_buff_on_system_profiler = 1024*1024; //1 kb

//datatype
static const NSString* system_info_type_hardware = @"SPHardwareDataType";
static const NSString* system_info_type_memory = @"SPMemoryDataType";
static const NSString* system_info_type_display = @"SPDisplaysDataType";
static const NSString* system_info_type_disk = @"SPSerialATADataType";
static const NSString* system_info_type_blueTooth = @"SPBluetoothDataType";
static const NSString* system_info_type_software = @"SPSoftwareDataType";
static const NSString* system_info_type_burning = @"SPDiscBurningDataType";


@interface systemInformationByCommandLine()

-(NSArray*) createArrayByBuff:(const void*)buf :(int)size;


-(void) clearInfo;

-(id) getOverViewInfo:(NSString*)key;
-(id) getMemoryInfo:(NSString*)key :(int)index;
-(int)_diskIndexOfName:(NSString*)bsdName;
-(NSNumber*) _walkingTheMountPointForFreeDiskIndex:(NSString*)bsdName;

@end


@implementation systemInformationByCommandLine


-(NSString*) hostName{
    
    NSString* info = nil;
    
//    if(nil != _host){
//        info = [_host localizedName];
//    }
    
    return info;
}

-(BOOL)scanSystemProfiler{

    char* buff = NULL;
    HPOPOPEN hpopen = NULL;
    int rt = 0;
    static const char* command = "system_profiler -xml SPHardwareDataType SPMemoryDataType SPDisplaysDataType SPSerialATADataType SPBluetoothDataType SPDiscBurningDataType SPSoftwareDataType -detailLevel basic";
//    static const char* command = "system_profiler -xml SPHardwareDataType SPMemoryDataType SPDisplaysDataType SPSerialATADataType SPBluetoothDataType SPDiscBurningDataType SPSoftwareDataType";
    
    
    
    if(NULL == (buff = (char*)MALLOC(sizeof(char)*max_buff_on_system_profiler + 1)))
        goto errout;
    
//    /*get host info*/
//    if(nil == (_host = [[NSHost currentHost] retain]))
//        goto errout;
    
    /*read info from system_profile*/
    if(NULL == (hpopen = posix_popen(command, "r")))
        goto errout;
    
    size_t byteReads;
    rt = posix_pread(hpopen, buff, max_buff_on_system_profiler, &byteReads);
    if(0 != rt && rt != EPIPE)
        goto errout;
    posix_pclose(&hpopen);
    
    buff[max_buff_on_system_profiler] = '\0';
    
    NSArray* infoArray = nil;
    if(nil == (infoArray = [self createArrayByBuff:buff:(int)byteReads]))
        goto errout;
    
    
    if(NO == [infoArray isKindOfClass:[NSArray class]]){
        assert(0);
        goto errout;
    }
    
    
    for(NSDictionary* info in infoArray){
         if(nil != info  &&  NO == [info isKindOfClass:[NSDictionary class]]){
            assert(0); //what's the fucking stuff ?
            continue;
        }
        
        NSString* dataType = [info objectForKey:@"_dataType"];
        if(nil != dataType  &&  NO == [dataType isKindOfClass:[NSString class]]){
            assert(0); //what's the fucking stuff ?
            continue;
        }
        
        
        NSArray* items = [info objectForKey:@"_items"];
        if(nil != items  &&  NO == [items isKindOfClass:[NSArray class]]){
            assert(0); //what's the fucking stuff ?
            continue;
        }
        if(0 == [items count])
            continue;
        
        
        if([dataType isEqualToString:(NSString*)system_info_type_hardware]){
            assert([items count] == 1);
            NSDictionary* hardwareDict = [items objectAtIndex:0];
            if(nil != hardwareDict  &&  NO == [hardwareDict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            _hardWareInfoDict = [hardwareDict retain];
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_memory]){
            NSDictionary* dict = [items objectAtIndex:0];
            if(nil != dict  &&  NO == [dict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            
            NSArray* memList = [dict objectForKey:@"_items"];
            if(nil != memList  &&  NO == [memList isKindOfClass:[NSArray class]]){
                assert(0);
                continue;
            }
            
            _memoryInfoDict = [memList retain];
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_display]){
            _graphicsAndDisplayInfoDict = [items retain];
            
            _displayInfoDicts = [[NSMutableArray alloc] init];
            for(NSDictionary* displayInfo in _graphicsAndDisplayInfoDict){
                NSArray* displayArr = [displayInfo objectForKey:@"spdisplays_ndrvs"];
                for(NSDictionary* displayDict in displayArr){
                    NSString* displayName = [displayDict objectForKey:@"_name"];
                    NSString* displayState = [displayDict objectForKey:@"spdisplays_status"];
                    
                    if((YES == [displayName isEqualToString:@"spdisplays_display_connector"])  &&  (YES == [displayState isEqualToString:@"spdisplays_not_connected"]) )
                        continue;
                    
                    [_displayInfoDicts addObject:displayDict];
                }
                
                //[_displayInfoDicts addObjectsFromArray:displayArr];
            }
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_disk]){
            
            _diskInfo = [[NSMutableArray alloc] init];
            
            for(NSDictionary* item in items){
                NSArray* diskArray = [item objectForKey:@"_items"];
                if(nil == diskArray  ||  NO == [diskArray isKindOfClass:[NSArray class]])
                    continue;
                
                if(0 == [diskArray count])
                    continue;
                
                
                NSDictionary* dict = [diskArray objectAtIndex:0];
                if(NO == [dict isKindOfClass:[NSDictionary class]]){
                    assert(0);
                    continue;
                }
                
            [_diskInfo addObject:dict];
                
            }
            
            
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_blueTooth]){
            NSDictionary* dict = [items objectAtIndex:0];
            if(nil != dict  &&  NO == [dict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            
            
            _blueToothDict = [dict objectForKey:@"local_device_title"];
            NSDictionary* localDeviceTitle = [dict objectForKey:@"local_device_title"];
            if(nil == localDeviceTitle  ||  NO == [localDeviceTitle isKindOfClass:[NSDictionary class]])
                continue;
            
            
            _blueToothDict = [localDeviceTitle retain];
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_software]){
            NSDictionary* dict = [items objectAtIndex:0];
            if(nil != dict  &&  NO == [dict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            
            
            _softwareDict = [dict retain];
            
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_burning]){
            _burningDicts = [items retain];
        }
        
        
//        static const NSString* system_info_type_software;
//        static const NSString* system_info_type_burning;
//        
        
    }
    
    
    FREE(buff);
    buff = NULL;
    
    return YES;
    
errout:
    
    if(NULL != buff)
        FREE(buff);
    
    if(NULL != hpopen)
        posix_pclose(&hpopen);
    
//    if(nil != _host)
//        [_host release];
    
    
    return NO;
}



-(BOOL)loadSystemProfiler:(NSString*)path{
    
    
    assert(nil != path);
    
    NSData* data = [NSData dataWithContentsOfFile:path];
    
    NSArray* infoArray = [self createArrayByBuff:[data bytes] :(int)[data length]];
    
//    
//    NSDictionary* cfgDict = [NSDictionary dictionaryWithContentsOfFile:path];
//    if(nil == cfgDict)
//        goto errout;
//    
//    if(NO  == [cfgDict isKindOfClass:[NSDictionary class]])
//        goto errout;
//    
//    
//    NSArray* infoArray  = [cfgDict objectForKey:@"Root"];
    if(nil == infoArray)
        goto errout;
    
    if(NO == [infoArray isKindOfClass:[NSArray class]])
        goto errout;
    
    
    for(NSDictionary* info in infoArray){
        if(nil != info  &&  NO == [info isKindOfClass:[NSDictionary class]]){
            assert(0); //what's the fucking stuff ?
            continue;
        }
        
        NSString* dataType = [info objectForKey:@"_dataType"];
        if(nil != dataType  &&  NO == [dataType isKindOfClass:[NSString class]]){
            assert(0); //what's the fucking stuff ?
            continue;
        }
        
        
        NSArray* items = [info objectForKey:@"_items"];
        if(nil != items  &&  NO == [items isKindOfClass:[NSArray class]]){
            assert(0); //what's the fucking stuff ?
            continue;
        }
        if(0 == [items count])
            continue;
        
        
        if([dataType isEqualToString:(NSString*)system_info_type_hardware]){
            assert([items count] == 1);
            NSDictionary* hardwareDict = [items objectAtIndex:0];
            if(nil != hardwareDict  &&  NO == [hardwareDict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            _hardWareInfoDict = [hardwareDict retain];
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_memory]){
            NSDictionary* dict = [items objectAtIndex:0];
            if(nil != dict  &&  NO == [dict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            
            NSArray* memList = [dict objectForKey:@"_items"];
            if(nil != memList  &&  NO == [memList isKindOfClass:[NSArray class]]){
                assert(0);
                continue;
            }
            
            _memoryInfoDict = [memList retain];
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_display]){
            _graphicsAndDisplayInfoDict = [items retain];
            
            _displayInfoDicts = [[NSMutableArray alloc] init];
            for(NSDictionary* displayInfo in _graphicsAndDisplayInfoDict){
                NSArray* displayArr = [displayInfo objectForKey:@"spdisplays_ndrvs"];
                for(NSDictionary* displayDict in displayArr){
                    NSString* displayName = [displayDict objectForKey:@"_name"];
                    NSString* displayState = [displayDict objectForKey:@"spdisplays_status"];
                    
                    if((YES == [displayName isEqualToString:@"spdisplays_display_connector"])  &&  (YES == [displayState isEqualToString:@"spdisplays_not_connected"]) )
                        continue;
                    
                    [_displayInfoDicts addObject:displayDict];
                }
                
                //[_displayInfoDicts addObjectsFromArray:displayArr];
            }
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_disk]){
            
            _diskInfo = [[NSMutableArray alloc] init];
            
            for(NSDictionary* item in items){
                NSArray* diskArray = [item objectForKey:@"_items"];
                if(nil == diskArray  ||  NO == [diskArray isKindOfClass:[NSArray class]])
                    continue;
                
                if(0 == [diskArray count])
                    continue;
                
                
                NSDictionary* dict = [diskArray objectAtIndex:0];
                if(NO == [dict isKindOfClass:[NSDictionary class]]){
                    assert(0);
                    continue;
                }
                
                [_diskInfo addObject:dict];
                
            }
            
            
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_blueTooth]){
            NSDictionary* dict = [items objectAtIndex:0];
            if(nil != dict  &&  NO == [dict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            
            
            _blueToothDict = [dict objectForKey:@"local_device_title"];
            NSDictionary* localDeviceTitle = [dict objectForKey:@"local_device_title"];
            if(nil == localDeviceTitle  ||  NO == [localDeviceTitle isKindOfClass:[NSDictionary class]])
                continue;
            
            
            _blueToothDict = [localDeviceTitle retain];
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_software]){
            NSDictionary* dict = [items objectAtIndex:0];
            if(nil != dict  &&  NO == [dict isKindOfClass:[NSDictionary class]]){
                assert(0);
                continue;
            }
            
            
            _softwareDict = [dict retain];
            
        }
        else if([dataType isEqualToString:(NSString*)system_info_type_burning]){
            _burningDicts = [items retain];
        }
        
        
        //        static const NSString* system_info_type_software;
        //        static const NSString* system_info_type_burning;
        //
        
    }
    
    
    return YES;
    
errout:
    
    
    return NO;
}





-(BOOL) scanDiskInfo{
    char* buff = NULL;
    HPOPOPEN hpopen = NULL;
    int rt = 0;
    static const char* command = "diskutil list -plist";
    
    
    
    if(NULL == (buff = (char*)MALLOC(sizeof(char)*max_buff_on_system_profiler + 1)))
        goto errout;
    
    /*get host info*/
//    if(nil == (_host = [[NSHost currentHost] retain]))
//        goto errout;
    
    /*read info from system_profile*/
    if(NULL == (hpopen = posix_popen(command, "r")))
        goto errout;
    
    size_t byteReads;
    rt = posix_pread(hpopen, buff, max_buff_on_system_profiler, &byteReads);
    if(0 != rt && rt != EPIPE)
        goto errout;
    posix_pclose(&hpopen);
    
    buff[max_buff_on_system_profiler] = '\0';
    
    NSDictionary* infoDict = nil;
    if(nil == (infoDict = [self createDictByBuff:buff:(int)byteReads]))
        goto errout;
    
    
    if(NO == [infoDict isKindOfClass:[NSDictionary class]]){
        assert(0);
        goto errout;
    }

    
    NSArray* AllDisksAndPartitions = [infoDict objectForKey:@"AllDisksAndPartitions"];
    if(NO == [AllDisksAndPartitions isKindOfClass:[NSArray class]]){
        assert(0);
        goto errout;
    }
    
    
    _partitions = [[NSMutableArray alloc] init];
    for(NSDictionary* disk in AllDisksAndPartitions){
        NSArray* partions = [disk objectForKey:@"Partitions"];
        for(NSDictionary* partion in partions){
            
            NSString* mountPoint = [partion objectForKey:@"MountPoint"];
            if(nil != mountPoint)
                [_partitions addObject:partion];
            
        }
    }
    
    
    FREE(buff);
    buff = NULL;
    
    return YES;
    
errout:
    
    if(NULL != buff)
        FREE(buff);
    
    if(NULL != hpopen)
        posix_pclose(&hpopen);
    
    
    return NO;
}





-(id) getOverViewInfo:(NSString*)key{
    NSObject* info = nil;
    
    if(nil != _hardWareInfoDict){
        info = [_hardWareInfoDict objectForKey:key];
    }
    
    return info;
}



/*get overview info*/
-(NSString*) overview_ModelName{   
    return [self getOverViewInfo:@"machine_name"];
}
-(NSString*) overview_ModelIdentifier{
    return [self getOverViewInfo:@"machine_model"];
}
-(NSString*) overview_ProcessorName{
    return [self getOverViewInfo:@"cpu_type"];
}
-(NSString*) overview_ProcessorSpeed{
    return [self getOverViewInfo:@"current_processor_speed"];  
}
-(int) overview_ProcessorNum{
    int rtNum = -1;
    NSNumber* num = [self getOverViewInfo:@"packages"];
    if(nil != num && YES == [num isKindOfClass:[NSNumber class]]){
        rtNum = [num intValue];
    }
    return rtNum;  
}
-(int) overview_ProcessorCores{
    int rtNum = -1;
    NSNumber* num = [self getOverViewInfo:@"number_processors"];
    if(nil != num && YES == [num isKindOfClass:[NSNumber class]]){
        rtNum = [num intValue];
    }
    return rtNum;
}
-(NSString*) overview_CacheL2{
    return [self getOverViewInfo:@"l2_cache_core"];     
}
-(NSString*) overview_CacheL3{
     return [self getOverViewInfo:@"l3_cache"];    
}
-(NSString*) overview_memorySize{
      return [self getOverViewInfo:@"physical_memory"];   
}
-(NSString*) overview_SerialNumber{
        return [self getOverViewInfo:@"serial_number"]; 
}
-(NSString*) overview_HardwareUUID{
        return [self getOverViewInfo:@"platform_UUID"]; 
}



-(id) getMemoryInfo:(NSString*)key :(int)index{
    
    NSObject* info = nil;
    
    if(nil != _memoryInfoDict){
        NSDictionary* dict = [_memoryInfoDict objectAtIndex:index];
        if(nil != dict && YES == [dict isKindOfClass:[NSDictionary class]]){
            info = [dict objectForKey:key];
        }
    }
    
    return info;
}

-(int)_diskIndexOfName:(NSString*)bsdName{
    if(nil == bsdName  ||  [bsdName length] < 5)
        goto errout;
    
    static const size_t nmatch = 3;
    static const char* reg = "disk([0-9]+)(s[0-9]+)*";
    const char* cstring_bsdname = [bsdName UTF8String];
    if(NULL == cstring_bsdname)
        goto errout;
    
    regex_t rexgex;
    regmatch_t pm[3];
    
    
    /*This function just called in special situation, Do not take a re-compile in the class initialization*/
    if(0 != regcomp(&rexgex, reg, REG_EXTENDED)){
        goto errout;
    }
    
    int rt = regexec(&rexgex, cstring_bsdname, nmatch, pm, 0);
    if(REG_NOMATCH == rt  ||  0 != rt)
        goto errout;
    
    if(-1 == pm[1].rm_so)
        goto errout;
    
    NSRange range = NSMakeRange((NSInteger)(pm[1].rm_so), (NSInteger)(pm[1].rm_eo - pm[1].rm_so));
    
    return [[bsdName substringWithRange:range] intValue];
    
errout:
    return -1;
}

-(NSNumber*) _walkingTheMountPointForFreeDiskIndex:(NSString*)bsdName{

    
    int wantBSDIndex = [self _diskIndexOfName:bsdName];
    
    
    if(nil == _FreeDiskSizeFixed){
        
        _FreeDiskSizeFixed = [[NSMutableArray alloc] init];
        
        static const char* mountPath = "/Volumes";
        DIR* dp;
        struct dirent* dirp;
        
        if((dp = opendir(mountPath)) == NULL){
            return nil;
        }
        
        
        char mountName[1024+1];
        char mountPoint[1024+1];
        while((dirp = readdir(dp)) != NULL)
        {
            /*dot & dot-dot*/
            if( (strcmp(dirp->d_name, ".") == 0) || (strcmp(dirp->d_name, "..") == 0) || (strcmp(dirp->d_name, ".DS_Store") == 0))
                continue;
            
            /*appending name after slash*/
            strcpy(mountName, dirp->d_name);
            mountName[1024] = '\0';
            
            sprintf(mountPoint, "/Volumes/%s/", mountName);
            
            struct statfs stat;
            if(statfs(mountPoint, &stat) >= 0){
                
                char statMountName[MNAMELEN+1];
                unsigned long long freeSize = 0L;
                
                strcpy(statMountName, (char*)(stat.f_mntfromname));
                statMountName[MNAMELEN] = '\0';
                freeSize = (long long)stat.f_bsize * stat.f_bfree;
                
                
                NSString* ocStatMountName = [NSString stringWithUTF8String:statMountName];
                if(nil == ocStatMountName)
                    continue;
                
                ocStatMountName = [ocStatMountName lastPathComponent];
                

                
                int index = [self _diskIndexOfName:ocStatMountName];
                if(-1 == index)
                    continue;
                
                if([_FreeDiskSizeFixed count] < index+1){
                    int fillCount = index+1 - (int)_FreeDiskSizeFixed.count;
                    
                    for(int i=0; i<fillCount; i++)
                        [_FreeDiskSizeFixed addObject:[NSNumber numberWithUnsignedLongLong:0L]];
                }
                
                NSNumber* obj = [_FreeDiskSizeFixed objectAtIndex:index];
                freeSize += [obj unsignedLongValue];
                [_FreeDiskSizeFixed replaceObjectAtIndex:index withObject:[NSNumber numberWithUnsignedLongLong:freeSize]];
                
                
                
            }

        }
        
    }
    
    
    if(wantBSDIndex + 1 <= [_FreeDiskSizeFixed count]){
        return [_FreeDiskSizeFixed objectAtIndex:wantBSDIndex];
    }
    else{
        return nil;
    }
    
}

/*get memory info*/
-(int) memory_SlotsNum{
    int rtVal = -1;
    
    if(nil != _memoryInfoDict){
        rtVal = (int)[_memoryInfoDict count];
    }
    
    return rtVal;
}

-(NSString*) memory_SlotName:(int)index{
    return [self getMemoryInfo:@"_name" :index];
}

-(NSString*) memory_size:(int)index{
    return [self getMemoryInfo:@"dimm_size" :index];
}
-(NSString*) memory_type:(int)index{
    return [self getMemoryInfo:@"dimm_type" :index];
}
-(NSString*) memory_speed:(int)index{
    return [self getMemoryInfo:@"dimm_speed" :index];
}

-(NSString*) memory_status:(int)index{
    return [self getMemoryInfo:@"dimm_status" :index];
}

-(NSString*) memory_manufacturer:(int)index{
    return [self getMemoryInfo:@"dimm_manufacturer" :index];
}

-(NSString*) memory_partNum:(int)index{
    return [self getMemoryInfo:@"dimm_part_number" :index];
}
-(NSString*) memory_Serial:(int)index{
    return [self getMemoryInfo:@"dimm_serial_number" :index];
}


/*get Graphics info*/

-(id) getGraphInfo:(NSString*)key :(int)index{
    
    NSObject* info = nil;
    
    if(nil != _graphicsAndDisplayInfoDict){
        NSDictionary* dict = [_graphicsAndDisplayInfoDict objectAtIndex:index];
        if(nil != dict && YES == [dict isKindOfClass:[NSDictionary class]]){
            info = [dict objectForKey:key];
        }
    }
    
    
    return info;
}

-(int)graphics_Num{
    if(nil == _graphicsAndDisplayInfoDict)
        return 0;
    else
        return (int)[_graphicsAndDisplayInfoDict count];
}
-(NSString*) graphics_ChipsetModel:(int)index{
    return [self getGraphInfo:@"sppci_model" :index];
}
-(NSString*) graphics_Vendor:(int)index{
    return [self getGraphInfo:@"spdisplays_vendor" :index];  
}
-(NSString*) graphics_vram:(int)index{
    return [self getGraphInfo:@"spdisplays_vram" :index];
}

-(NSString*) graphics_type:(int)index{
    
    NSString* typeString = [self getGraphInfo:@"sppci_device_type" :index];
    
    if(nil != typeString)
        typeString = [typeString stringByReplacingOccurrencesOfString:@"spdisplays_" withString:@""];
    
    return typeString;
}

-(NSString*) graphics_deviceID:(int)index{
    return [self getGraphInfo:@"spdisplays_device-id" :index];
}

-(NSString*) graphics_RevisionID:(int)index{
    return [self getGraphInfo:@"spdisplays_revision-id" :index];
}


/*get Display info*/
-(id)getDisplayInfo:(NSString*)key :(int)index{
    
    NSObject* info = nil;
    
    if(nil != _displayInfoDicts){
        NSDictionary* dict = [_displayInfoDicts objectAtIndex:index];
        if(nil != dict && YES == [dict isKindOfClass:[NSDictionary class]]){
            info = [dict objectForKey:key];
        }
    }
    
    
    return info;
}

-(int)display_Num{
    if(nil == _displayInfoDicts)
        return 0;
    else
        return (int)[_displayInfoDicts count];
}
-(NSString*) display_Name:(int)index{
    return [self getDisplayInfo:@"_name" :index];
}
-(NSString*) display_Type:(int)index{    
    NSString* typeString = [self getDisplayInfo:@"spdisplays_display_type" :index];
    
    if(nil != typeString)
        typeString = [typeString stringByReplacingOccurrencesOfString:@"spdisplays_" withString:@""];
    
    return typeString;
    
}

-(NSString*) display_Year:(int)index{
    return [self getDisplayInfo:@"_spdisplays_display-year" :index];
}

-(NSString*) display_Week:(int)index{
    return [self getDisplayInfo:@"_spdisplays_display-week" :index];
}

-(NSString*) display_Resolution:(int)index{
    return [self getDisplayInfo:@"_spdisplays_pixels" :index];
}
-(NSString*) display_PixelDepth:(int)index{
 
    NSString* depthKey = [self getDisplayInfo:@"spdisplays_depth" :index];
    
    return [_pixelDepthMap objectForKey:depthKey];
}
-(BOOL) display_IsMainDisplay:(int)index{
    NSString* manDisplayFlag = [self getDisplayInfo:@"spdisplays_main" :index];
    if(nil != manDisplayFlag  &&  [manDisplayFlag isEqualToString:@"spdisplays_yes"])
        return YES;
    else
        return NO;
}
-(BOOL) display_IsBuiltIn:(int)index{
    NSString* buildInFlag = [self getDisplayInfo:@"spdisplays_builtin" :index];
    if(nil != buildInFlag  &&  [buildInFlag isEqualToString:@"spdisplays_yes"])
        return YES;
    else
        return NO;
}

-(BOOL) display_IsOnline:(int)index{
    NSString* onlineFlag = [self getDisplayInfo:@"spdisplays_online" :index];
    if(nil != onlineFlag  &&  [onlineFlag isEqualToString:@"spdisplays_yes"])
        return YES;
    else
        return NO;
}

-(BOOL) display_isRotationSupport:(int)index{
    NSString* rotaionFlag = [self getDisplayInfo:@"spdisplays_rotation" :index];
    if(nil != rotaionFlag  &&  [rotaionFlag isEqualToString:@"spdisplays_supported"])
        return YES;
    else
        return NO;
}

-(BOOL) display_isRetina:(int)index{
    NSString* retinaFlag = [self getDisplayInfo:@"spdisplays_retina" :index];
    if(nil != retinaFlag  &&  [retinaFlag isEqualToString:@"spdisplays_yes"])
        return YES;
    else
        return NO;
}



-(NSString*) display_SerialNumber:(int)index{
    return [self getDisplayInfo:@"_spdisplays_display-serial-number" :index];
}




-(id)getdiskInfo:(NSString*)key :(int)index{
    
    NSObject* info = nil;
    
    NSDictionary* dict = [_partitions objectAtIndex:index];
    if(nil != dict && YES == [dict isKindOfClass:[NSDictionary class]]){
        info = [dict objectForKey:key];
    }
    
    
    return info;
}

-(int)disk_partitionNum{
    if(nil == _partitions)
        return 0;
    else
        return (int)[_partitions count];
}


-(NSNumber*)disk_partitionSize:(int)index{
    return [self getdiskInfo:@"Size" :index];
}

-(NSString*)disk_partitionName:(int)index{
    return [self getdiskInfo:@"VolumeName" :index];
}

-(NSString*)disk_partitionPath:(int)index{
    return [self getdiskInfo:@"MountPoint" :index];
}

-(NSString*)disk_partitionidentifier:(int)index{
    return [self getdiskInfo:@"DeviceIdentifier" :index];
}

-(NSString*)disk_partitionContent:(int)index{
    return [self getdiskInfo:@"Content" :index];
}






-(id)getAtaInfo:(NSString*)key :(int)index{
    
    NSObject* info = nil;
    
    if(nil != _diskInfo){
        NSDictionary* dict = [_diskInfo objectAtIndex:index];
        if(nil != dict && YES == [dict isKindOfClass:[NSDictionary class]]){
            info = [dict objectForKey:key];
        }
    }
    
    return info;
}


-(int)AtaDevice_Num{
    
    if(nil == _diskInfo)
        return 0;
    else
        return (int)[_diskInfo count];
}


-(NSString*)AtaDevice_Name:(int)index{
    return [self getAtaInfo:@"_name" :index];
}


-(NSString*)AtaDevice_model:(int)index{
    return [self getAtaInfo:@"device_model" :index];
}


-(NSString*)AtaDevice_Serial:(int)index{
    return [self getAtaInfo:@"device_serial" :index];
}


-(NSNumber*)AtaDevice_size:(int)index{
    return [self getAtaInfo:@"size_in_bytes" :index];
}

-(NSNumber*)AtaDevice_freeSize:(int)index{
    
    unsigned long long freeSize = 0;
    
    NSArray* partArr = [self getAtaInfo:@"volumes" :index];
    if(nil == partArr  ||  NO == [partArr isKindOfClass:[NSArray class]])
        return nil;
    
    for(NSDictionary* partInfoDict in partArr){
        if(NO == [partInfoDict isKindOfClass:[NSDictionary class]])
            continue;
        
        NSNumber* num = [partInfoDict objectForKey:@"free_space_in_bytes"];
        if(nil == num   ||  NO == [num isKindOfClass:[NSNumber class]]){
            continue;
        }
        
        freeSize += [num unsignedLongLongValue];
    }
    
    /*fix a bug here*/
    if(0 == freeSize){
        NSNumber* num = [self _walkingTheMountPointForFreeDiskIndex:[self AtaDevice_BSDName:index]];
        
        if(0 != num)
            freeSize = [num unsignedLongLongValue];
    }
    
    
    return [NSNumber numberWithUnsignedLongLong:freeSize];
}


-(NSString*)AtaDevice_sizeDescription:(int)index{
    return [self getAtaInfo:@"size" :index];
}


-(NSString*)AtaDevice_rotationalRate:(int)index{
    return [self getAtaInfo:@"spsata_rotational_rate" :index];
}


-(NSString*)AtaDevice_MediumType:(int)index{
    return [self getAtaInfo:@"spsata_medium_type" :index];
}

-(NSString*)AtaDevice_BSDName:(int)index{
    return [self getAtaInfo:@"bsd_name" :index];
}


-(NSString*)AtaDevice_isPowerOff:(int)index{
    return [self getAtaInfo:@"spsata_power_off" :index];
    
}




-(id)getBlueToothInfo:(NSString*)key{
    
    NSObject* info = nil;
    
    if(nil != _blueToothDict){
        info = [_blueToothDict objectForKey:key];
    }
    
    
    return info;
}



-(NSString*) blueTooth_name{
    NSString* name = [self getBlueToothInfo:@"general_name"];
    if(nil == name)
        name = [self getBlueToothInfo:@"device_name"];
    
    return name;
}

-(NSString*) blueTooth_address{
    return [self getBlueToothInfo:@"general_address"];
}


-(NSString*) blueTooth_manufacturer{
    return [self getBlueToothInfo:@"general_mfg"];
}



-(BOOL) blueTooth_isPowerOn{
    NSString* attribute = [self getBlueToothInfo:@"general_power"];
    
    if(nil == attribute)
        attribute = [self getBlueToothInfo:@"device_power"];
    
    if(nil != attribute  &&  YES == [attribute isEqualToString:@"attrib_On"])
        return YES;
    else 
        return NO;
    
    
}



-(BOOL) blueTooth_isDiscoverable{
    NSString* attribute =  [self getBlueToothInfo:@"general_discoverable"];
    if(nil == attribute)
        attribute =  [self getBlueToothInfo:@"device_discoverable"];
    
    if(nil != attribute  &&  YES == [attribute isEqualToString:@"attrib_Yes"])
        return YES;
    else 
        return NO;
}



//_softwareDict

-(id)getSoftwareInfo:(NSString*)key{
    
    NSObject* info = nil;
    
    if(nil != _softwareDict){
        info = [_softwareDict objectForKey:key];
    }
    
    
    return info;
}

-(NSString*)software_userName{
    return [self getSoftwareInfo:@"user_name"];
}

-(NSString*)software_OSVersion{
    return [self getSoftwareInfo:@"os_version"];
}

-(NSString*)software_bootVolume{
    return [self getSoftwareInfo:@"boot_volume"];
}


-(NSString*)software_hostName{
    return [self getSoftwareInfo:@"local_host_name"];
}



//burning


-(id)getBurningInfo:(NSString*)key :(int)index{
    
    NSObject* info = nil;
    
    if(nil != _burningDicts){
        
        NSDictionary* dict = [_burningDicts objectAtIndex:index];
        if(nil != dict && YES == [dict isKindOfClass:[NSDictionary class]]){
            info = [dict objectForKey:key];
        }
        
    }

    
    return info;
}

-(int)burning_num{
    if(nil == _burningDicts)
        return 0;
    else
        return (int)[_burningDicts count];
}

-(NSString*)burning_name:(int)index{
    return [self getBurningInfo:@"_name" :index];
}

-(NSString*)burning_cache:(int)index{
    return [self getBurningInfo:@"device_cache" :index];
}


-(BOOL)burning_canReadDVD:(int)index{
    NSString* readFlagString = [self getBurningInfo:@"device_readdvd" :index];
    
    if(nil == readFlagString  ||  [readFlagString isEqualToString:@"no"])
        return NO;
    else
        return YES;
}


-(NSString*)burning_dvdWrite:(int)index{
    return [self getBurningInfo:@"device_dvdwrite" :index];
}


-(NSString*)burning_cdWrite:(int)index{
    return [self getBurningInfo:@"device_cdwrite" :index];
}



//
//
//#if 0 //comment out
//-(BOOL)scanDriveInfo{
//    char* buff = NULL;
//    HPOPOPEN hpopen = NULL;
//    int rt = 0;
//    static const char* command = "drutil info";
//    
//    
//    
//    if(NULL == (buff = (char*)MALLOC(sizeof(char)*max_buff_on_system_profiler + 1)))
//        goto errout;
//    
//    /*get host info*/
//    if(nil == (_host = [[NSHost currentHost] retain]))
//        goto errout;
//    
//    /*read info from system_profile*/
//    if(NULL == (hpopen = posix_popen(command, "r")))
//        goto errout;
//    
//    size_t byteReads;
//    rt = posix_pread(hpopen, buff, max_buff_on_system_profiler, &byteReads);
//    if(0 != rt && rt != EPIPE)
//        goto errout;
//    posix_pclose(&hpopen);
//    
//    buff[max_buff_on_system_profiler] = '\0';
//    
//    NSLog(@"%s", buff);
//    NSString* str = [NSString stringWithUTF8String:buff];
//    
////    NSDictionary* infoDict = nil;
////    if(nil == (infoDict = [self createDictByBuff:buff:(int)byteReads]))
////        goto errout;
////    
//    
//    NSError *error = NULL;
//    NSRegularExpression* regex = NULL;
//    NSTextCheckingResult* match = NULL;
//    
//    
//    
//    
//    regex = [NSRegularExpression regularExpressionWithPattern:@"(^\\s*Vendor\\s*Product\\s*Rev\\s*$)(.*)"
//                                                      options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
//                                                        error:&error];
//    
//    match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
//    
//    
//    
//    NSString* name = [str substringWithRange:[match rangeAtIndex:2]];
//    NSLog(@"->%@", name);
//    
//    
//    
//    
//    
//    
//    
//    
//    regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*Cache:\\s*(.*)\\s*$"
//                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
//                                                                             error:&error];
//
//    match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
//     
//    
//    
//    NSString* cacheInfo = [str substringWithRange:[match rangeAtIndex:1]];
//    NSLog(@"->%@", cacheInfo);
//    
//    
//    
//    
//    /**/
//    regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*CD-Write:\\s*(.*)\\s*$"
//                                                                                options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
//                                                                                  error:&error];
//    
//    match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
//    
//    NSString* CDWriteInfo = [str substringWithRange:[match rangeAtIndex:1]];
//    NSLog(@"->%@", CDWriteInfo);
//    
//    
//    
//    
//    
//    /**/
//    regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*DVD-Write:\\s*(.*)\\s*$"
//                                                      options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
//                                                        error:&error];
//    
//    match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
//    
//    NSString* DVDWriteInfo = [str substringWithRange:[match rangeAtIndex:1]];
//    NSLog(@"->%@", DVDWriteInfo);
//    
//    
//    
//    /**/
//    regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*Strategies:\\s*(.*)\\s*$"
//                                                      options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
//                                                        error:&error];
//    
//    match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
//    
//    NSString* Strategies = [str substringWithRange:[match rangeAtIndex:1]];
//    NSLog(@"->%@", Strategies);
//    
//    
//    
//    FREE(buff);
//    buff = NULL;
//    
//    return YES;
//    
//errout:
//    
//    if(NULL != buff)
//        FREE(buff);
//    
//    if(NULL != hpopen)
//        posix_pclose(&hpopen);
//    
//    
//    return NO;
//}
//
//#endif






-(void) clearInfo{
    if(nil != _hardWareInfoDict){
        assert(1 == [_hardWareInfoDict retainCount]);
        [_hardWareInfoDict release];
        _hardWareInfoDict = nil;
    }
    
    if(nil != _memoryInfoDict){
        assert(1 == [_memoryInfoDict retainCount]);
        [_memoryInfoDict release];
        _memoryInfoDict = nil;
    }
    
    if(nil != _graphicsAndDisplayInfoDict){
        assert(1 == [_graphicsAndDisplayInfoDict retainCount]);
        [_graphicsAndDisplayInfoDict release];
        _graphicsAndDisplayInfoDict = nil;
    }
    
    if(nil != _displayInfoDicts){
        assert(1 == [_displayInfoDicts retainCount]);
        [_displayInfoDicts release];
        _displayInfoDicts = nil;
    }
    
    
//    if(nil != _host){
//        assert(1 == [_host retainCount]);
//        [_host release];
//        _host = nil;
//    }
    
    if(nil != _partitions){
        assert(1 == [_partitions retainCount]);
        [_partitions release];
        _partitions = nil;
    }
    
    if(nil != _blueToothDict){
        assert(1 == [_blueToothDict retainCount]);
        [_blueToothDict release];
        _blueToothDict = nil;
    }
    
    if(nil != _diskInfo){
        assert(1 == [_diskInfo retainCount]);
        [_diskInfo release];
        _diskInfo = nil;
    }
    
    if(nil != _softwareDict){
        assert(1 == [_softwareDict retainCount]);
        [_softwareDict release];
        _softwareDict = nil;
    }

    
}











-(id)init{
    if(nil != (self = [super init])){       
        
        _hardWareInfoDict = nil;
        _memoryInfoDict = nil;
        _graphicsAndDisplayInfoDict = nil;
        _displayInfoDicts = nil;
        _burningDicts = nil;
//        _host = nil;
        _partitions = nil;
        _blueToothDict = nil;
        
        _diskInfo = nil;
        _FreeDiskSizeFixed = nil;
        
        _softwareDict = nil;
        
        
        _pixelDepthMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"8-Bit Gray", @"CGSEightBitGray",
                                       @"8-Bit Color", @"CGSEightBitColor",
                                       @"16-Bit Color", @"CGSSixteenBitColor",
                                       @"32-Bit Color", @"CGSThirtytwoBitColor",
                                       @"64-Bit Color", @"CGSSixtyfourBitColor"
                                       , nil];
        
    }
    
    
    return self;
}



-(void)dealloc{

    
    [self clearInfo];
    
    
    [_hardWareInfoDict release];
    _hardWareInfoDict = nil;
    
    [_memoryInfoDict release];
    _memoryInfoDict = nil;
    
    [_graphicsAndDisplayInfoDict release];
    _graphicsAndDisplayInfoDict = nil;
    
    [_displayInfoDicts release];
    _displayInfoDicts = nil;
    
//    [_host release];
//    _host = nil;
    
    [_partitions release];
    _partitions = nil;
    
    [_blueToothDict release];
    _blueToothDict = nil;
    
    [_diskInfo release];
    _diskInfo = nil;
    
    [_FreeDiskSizeFixed release];
    _FreeDiskSizeFixed = nil;
    
    
    [_softwareDict release];
    _softwareDict = nil;
    
    [_pixelDepthMap release];
    _pixelDepthMap = nil;
    
    
    [_burningDicts release];
    _burningDicts = nil;

    
    [_burningDicts release];
    _burningDicts = nil;
    

    
    [super dealloc];
}




//pirvate function
-(NSArray*) createArrayByBuff:(const void*)buf :(int)size{
    
    int err = 0;
    CFDataRef dictData = NULL;
    CFArrayRef 	arr = NULL;
    
    do {
        
        assert(NULL != buf);
        assert(size >= 0);
        
        //Must find a way to do this here
        //veriry the buff
        //        if([self isBinaryPropertyListData:buf :size] == NO){
        //            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
        //            break;
        //        }
        
        
        if(NULL == (dictData = CFDataCreateWithBytesNoCopy(NULL, buf, size, kCFAllocatorNull))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
            break;
        }
        
        
        if(NULL == (arr = CFPropertyListCreateFromXMLData(NULL, dictData, kCFPropertyListImmutable, NULL))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
        }
        
        
    } while (0);
    
    
    if(0 != err)
    {
        if(NULL != arr){
            CFRelease(arr);
            arr = NULL;
        }
    }
    
    if(NULL != dictData)
        CFRelease(dictData);
    
    return [(NSArray*)(CFArrayRef)(arr) autorelease];
}


-(NSDictionary*) createDictByBuff:(const void*)buf :(int)size{
    
    int err = 0;
    CFDataRef dictData = NULL;
    CFDictionaryRef dict = NULL;
    
    do {
        
        assert(NULL != buf);
        assert(size >= 0);
        
        //Must find a way to do this here
        //veriry the buff
        //        if([self isBinaryPropertyListData:buf :size] == NO){
        //            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
        //            break;
        //        }
        
        
        if(NULL == (dictData = CFDataCreateWithBytesNoCopy(NULL, buf, size, kCFAllocatorNull))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
            break;
        }
        
        
        if(NULL == (dict = CFPropertyListCreateFromXMLData(NULL, dictData, kCFPropertyListImmutable, NULL))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
        }
        
        
    } while (0);
    
    
    if(0 != err)
    {
        if(NULL != dict){
            CFRelease(dict);
            dict = NULL;
        }
    }
    
    if(NULL != dictData)
        CFRelease(dictData);
    
    return [(NSDictionary*)(CFDictionaryRef)(dict) autorelease];
}

@end



