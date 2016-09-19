//
//  DatabaseHelper.h
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 22/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#ifndef foo_DatabaseHelper_h
#define foo_DatabaseHelper_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "EmbeddedLocation.h"


@interface DatabaseHelper : NSObject
{
    sqlite3 *database;
}

-(bool)queryRead:(NSString *)sql;
-(bool)queryExecute:(NSString *)sql statement:(sqlite3_stmt **)statement;
+(DatabaseHelper *)getInstance;

-(bool) insertLocationIntoDatabase: (EmbeddedLocation*)location;
-(bool) insertMessageIntoDatabase: (NSString*)textMessage;

-(bool) setUserId:(NSString*) userid phoneModel:(NSString*)phoneModel phoneOS:(NSString*)phoneOs;
-(bool) updateIsServiceRunning: (bool) newValue;

-(bool) updateUploadedLocations;
-(NSString*) getLocationsForUpload;

-(NSString*) getAllMessages;
-(bool) deleteUploadedLogs;


-(int) getUserId;
-(bool) getIsServiceRunning;

-(void) closeDatabase;

- (NSArray *)executeJSONQuery:(NSString *)query;

@end

#endif
