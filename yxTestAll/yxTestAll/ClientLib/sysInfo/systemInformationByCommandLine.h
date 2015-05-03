//
//  systemInformation.h
//  sytemReport
//
//  Created by Yuxi Liu on 10/30/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
//:~ TODO using the IOKIT to instead

//:~ TODO need refactoring
//Because of the naming chaos !!!!!!!!!!
//Because of the codes chaos !!!!!!!!!!
@interface systemInformationByCommandLine : NSObject{
    
    NSDictionary* _hardWareInfoDict;
    NSArray* _memoryInfoDict;
    NSArray* _graphicsAndDisplayInfoDict;
    NSArray* _burningDicts;
    NSMutableArray* _displayInfoDicts;
    //NSHost* _host;
    NSMutableArray* _partitions;
    NSDictionary* _blueToothDict;
    
    NSMutableArray* _diskInfo;
    NSMutableArray* _FreeDiskSizeFixed;  //fix a bug on device
    
    NSDictionary* _softwareDict;
    
    
    NSDictionary* _pixelDepthMap;
    
}

/*host name*/
//-(NSString*) hostName;


/*************************************************************************/
/* systemProfiler cmd */
/*************************************************************************/



-(BOOL)scanSystemProfiler;
-(BOOL)loadSystemProfiler:(NSString*)path;


/*get hardware overview info*/
-(NSString*) overview_ModelName;
-(NSString*) overview_ModelIdentifier;
-(NSString*) overview_ProcessorName;
-(NSString*) overview_ProcessorSpeed;
-(int)       overview_ProcessorNum;
-(int)       overview_ProcessorCores;
-(NSString*) overview_CacheL2;
-(NSString*) overview_CacheL3;
-(NSString*) overview_memorySize;
-(NSString*) overview_SerialNumber;
-(NSString*) overview_HardwareUUID;





/*get memory info*/
-(int)       memory_SlotsNum;
-(NSString*) memory_SlotName:(int)index;
-(NSString*) memory_size:(int)index;
-(NSString*) memory_type:(int)index;
-(NSString*) memory_speed:(int)index;
-(NSString*) memory_status:(int)index;
-(NSString*) memory_manufacturer:(int)index;
-(NSString*) memory_partNum:(int)index;
-(NSString*) memory_Serial:(int)index;



/*get Graphics info*/
-(int)       graphics_Num;
-(NSString*) graphics_ChipsetModel:(int)index;
-(NSString*) graphics_Vendor:(int)index;
-(NSString*) graphics_vram:(int)index;
-(NSString*) graphics_type:(int)index;
-(NSString*) graphics_deviceID:(int)index;
-(NSString*) graphics_RevisionID:(int)index;



/*get Display info*/
-(int)display_Num;
-(NSString*) display_Name:(int)index;
-(NSString*) display_Type:(int)index;
-(NSString*) display_Year:(int)index;
-(NSString*) display_Week:(int)index;
-(NSString*) display_Resolution:(int)index;
-(NSString*) display_PixelDepth:(int)index;
-(BOOL) display_IsMainDisplay:(int)index;
-(BOOL) display_IsBuiltIn:(int)index;
-(BOOL) display_IsOnline:(int)index;
-(BOOL) display_isRotationSupport:(int)index;
-(BOOL) display_isRetina:(int)index;
-(NSString*) display_SerialNumber:(int)index;







/*get Disk Info*/
-(int)AtaDevice_Num;
-(NSString*)AtaDevice_Name:(int)index;
-(NSString*)AtaDevice_model:(int)index;
-(NSString*)AtaDevice_Serial:(int)index;
-(NSNumber*)AtaDevice_size:(int)index;
-(NSNumber*)AtaDevice_freeSize:(int)index;
-(NSString*)AtaDevice_sizeDescription:(int)index;
-(NSString*)AtaDevice_rotationalRate:(int)index;
-(NSString*)AtaDevice_MediumType:(int)index;
-(NSString*)AtaDevice_BSDName:(int)index;
-(NSString*)AtaDevice_isPowerOff:(int)index;





/*blue tooth*/
-(NSString*) blueTooth_name;
-(NSString*) blueTooth_address;
-(NSString*) blueTooth_manufacturer;
-(BOOL) blueTooth_isPowerOn;
-(BOOL) blueTooth_isDiscoverable;


/*software info*/
-(NSString*)software_userName;
-(NSString*)software_OSVersion;
-(NSString*)software_bootVolume;
-(NSString*)software_hostName;




/*burning info*/
-(int)burning_num;
-(NSString*)burning_name:(int)index;
-(NSString*)burning_cache:(int)index;
-(BOOL)burning_canReadDVD:(int)index;
-(NSString*)burning_dvdWrite:(int)index;
-(NSString*)burning_cdWrite:(int)index;

/*************************************************************************/
/* diskutil cmd */
/*************************************************************************/


-(BOOL)scanDiskInfo;

/*get partition info*/
//a bug here
-(int)disk_partitionNum;
-(NSNumber*)disk_partitionSize:(int)index;
-(NSString*)disk_partitionName:(int)index;
-(NSString*)disk_partitionPath:(int)index;
-(NSString*)disk_partitionidentifier:(int)index;
-(NSString*)disk_partitionContent:(int)index;

//:~ TODO
//using diskutil info [path] get the partition detail info



/*************************************************************************/
/* drutil cmd */
/*************************************************************************/
//-(BOOL)scanDriveInfo;

@end












