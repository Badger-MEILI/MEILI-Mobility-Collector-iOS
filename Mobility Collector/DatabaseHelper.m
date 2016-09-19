//
//  DatabaseHelper.m
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 22/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "DatabaseHelper.h"

@implementation DatabaseHelper

-(id)init
{
    if ((self = [super init]))
    {
        /*
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains
                              (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [cacheDir
                            stringByAppendingPathComponent:@"Mobility_collector.sql"];
        
        if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        else {
            NSLog(@"Opened the database!");
        }
         */
        
        // Get the documents directory
        NSString *docsDir;
        NSArray *dirPaths;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        
        // Build the path to the database file
        
        NSString* databasePath = [[NSString alloc]
                         initWithString: [docsDir stringByAppendingPathComponent:
                                          @"mobility_collector.db"]];
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        const char *dbpath = [databasePath UTF8String];

        if ([filemgr fileExistsAtPath: databasePath ] == NO)
        {
            
            if (sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
               // NSLog(@"Sucess open/create database");

                char *errMsg;
                const char *sql_stmt =
                "CREATE TABLE if not exists location_table (time_ bigint, userid integer, latitude double precision, longitude double precision, speed_ double precision, altitude double precision, bearing double precision, accuracy double precision, satellites_ integer, xMean double precision, yMean double precision, zMean double precision, totalMean double precision, xStdDev double precision, yStdDev double precision, zStdDev double precision, totalStdDev double precision, xMin double precision, yMin double precision, zMin double precision, totalMin double precision, xMax double precision, yMax double precision, zMax double precision, totalMax double precision, xNumberOfPeaks int, yNumberOfPeask int, zNumberOfPeaks int, totalNumberOfPeaks int, totalNumberOfSteps int, xIsMoving boolean, yIsMoving boolean, zIsMoving boolean, totalIsMoving boolean, size integer, upload boolean); CREATE TABLE if not exists admin_table (userid integer, phone_model text, phone_os text, isServiceOn boolean); Create table if not exists log_table(log_time text, log_message text)";
                
                if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                else{
                    NSLog(@"Sucess create table");
                
                }
                //sqlite3_close(database);
            } else {
                NSLog(@"Failed to open/create database");
            }
        }
        else {
            NSLog(@"Database exists");
            if (sqlite3_open(dbpath, &database) == SQLITE_OK){
                NSLog(@"Opened database");
            }
            else NSLog(@"Couldn't open database");


        }
        
         }
    return self;
}



+(DatabaseHelper *)getInstance
{
    static DatabaseHelper* instance;
    @synchronized(self) {
        if(instance==nil)
            instance = [[DatabaseHelper alloc] init];
    }
    return instance;
}

-(bool)queryRead:(NSString *)sql{
    {
        sqlite3_stmt *statement;
        const char *sql_stmt = [sql UTF8String];
        if(sqlite3_prepare_v2(database, sql_stmt,
                              -1, &statement, NULL) == SQLITE_OK) {
            bool done = sqlite3_step(statement) == SQLITE_DONE;
            sqlite3_finalize(statement);
            return done;
        }
        return false;
    }
}

-(bool)queryExecute:(NSString *)sql statement:(sqlite3_stmt **)statement{
    const char *sql_stmt = [sql UTF8String];
    return sqlite3_prepare_v2(database, sql_stmt,
                              -1, statement, NULL) == SQLITE_OK;

}

/*
-(void)copyDatabseIntoDocumentsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains
                          (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [cacheDir stringByAppendingPathComponent:
                      @"Mobility_collector.sql"];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        NSString *bundlePath = [[NSBundle mainBundle]
                                pathForResource:@"Mobility_collector"
                                ofType:@"sql" inDirectory:@""];
        // will subdirectories be created. sometimes, the cache dir gets deleted.
        [fileManager copyItemAtPath:bundlePath  toPath:path error:nil];
    }
}
*/

-(bool)insertLocationIntoDatabase:(EmbeddedLocation *)location{

    NSString* query = location.getSqlInsertStatement;
    int rc = 0;
    char* errMsg;
    
    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);
    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to insert record  rc:%d, msg=%s",rc, errMsg);
    }
    
    
    [self insertMessageIntoDatabase:@"INserted location in database"];
    
    return rc>0;
}

-(NSString *)getAllMessages{
    NSArray* logMsg = [self executeJSONQuery:@"SELECT * FROM log_table"];
   
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logMsg options:0 error:nil];
    
    NSString* dataToUpload = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // Checking the format
    //    NSLog(@"%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    return dataToUpload;
}

-(bool)deleteUploadedLogs{
   
    NSString* query = [NSString stringWithFormat: @"DELETE FROM log_table"];
    int rc = 0;
    char* errMsg;
    
    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);
    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to delete logs");
    }
    return rc>0;
}

-(bool)insertMessageIntoDatabase:(NSString *)textMessage{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString* query = [NSString stringWithFormat:@"INSERT INTO log_table values('%@','%@')", currentTime, textMessage];
    int rc = 0;
    char* errMsg;
    
    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);
    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to insert record  rc:%d, msg=%s",rc, errMsg);
    }
    
    return rc>0;
}

-(int) getUserId{
    const char *query_stmt = "Select userid from admin_table";
    sqlite3_stmt*statement;
    
    if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, nil)==SQLITE_OK) {
        
        if (sqlite3_step(statement)==SQLITE_ROW) {
            if (sqlite3_column_text(statement, 0) == nil ) return 0;
            else return [[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 0)] intValue];
        }
    }
    return 0;
}

-(bool) setUserId:(NSString*) userId phoneModel:(NSString *)phoneModel phoneOS:(NSString *)phoneOs{
    NSString* query = @"DELETE from admin_table";
    int rc = 0;
    char* errMsg;
    
    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);
    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to DELETE");
    }
    
    query = [NSString stringWithFormat:@"INSERT into admin_table values('%@','%@','%@','%d')", userId, phoneModel, phoneOs, 0];

    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);

    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to INSERT");
    }
    
    return rc>0;
}

-(bool)updateIsServiceRunning:(bool)newValue{
    int uploadService = 0;
    if (newValue) uploadService=1;
    
    NSString* query = [NSString stringWithFormat: @"UPDATE admin_table SET isServiceOn='%d'", uploadService];
    int rc = 0;
    char* errMsg;
    
    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);
    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to update service running status");
    }
    return rc>0;
}

-(bool)getIsServiceRunning{
    const char *query_stmt = "Select isServiceOn from admin_table";
    sqlite3_stmt*statement;
    
    if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, nil)==SQLITE_OK) {
        
        if (sqlite3_step(statement)==SQLITE_ROW) {
            if (sqlite3_column_text(statement, 0) == nil ) return 0;
            else return [[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 0)] boolValue];
        }
    }
    return 0;
}

-(void)closeDatabase{
    sqlite3_close(database);
}

-(NSString *)getLocationsForUpload{
    NSArray* dbLocs = [self executeJSONQuery:@"SELECT * FROM location_table where upload = 0"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dbLocs options:0 error:nil];
    
    NSString* dataToUpload = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // Checking the format
//    NSLog(@"%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
 
    return dataToUpload;
}

-(bool)updateUploadedLocations{
    NSString* query = @"UPDATE location_table SET upload=1";
    int rc = 0;
    char* errMsg;
    
    rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL, &errMsg);
    if(SQLITE_OK != rc)
    {
        NSLog(@"Failed to update the uploaded locations");
    }
    return rc>0;
}

- (NSArray *)executeJSONQuery:(NSString *)query
{
    sqlite3_stmt *stmt;
    const char *tail;
    sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, &tail);
    if (stmt == NULL)
        return nil;
    
    int status;
    int num_cols;
    int i;
    int type;
    id obj;
    NSString *key;
    NSMutableArray *result;
    NSMutableDictionary *row;
    
    result = [NSMutableArray array];
    while ((status = sqlite3_step(stmt)) != SQLITE_DONE) {
        if (status != SQLITE_ROW)
            continue;
        
        row = [NSMutableDictionary dictionary];
        num_cols = sqlite3_data_count(stmt);
        for (i = 0; i < num_cols; i++) {
            obj = nil;
            type = sqlite3_column_type(stmt, i);
            switch (type) {
                case SQLITE_INTEGER:
                    obj = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)];
                    break;
                case SQLITE_FLOAT:
                    obj = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
                    break;
                case SQLITE_TEXT:
                    obj = [NSString stringWithUTF8String:sqlite3_column_text(stmt, i)];
                    break;
                case SQLITE_BLOB:
                    obj = [NSData dataWithBytes:sqlite3_column_blob(stmt, i)
                                         length:sqlite3_column_bytes(stmt, i)];
                    break;
                case SQLITE_NULL:
                    obj = [NSNull null];
                    break;
                default:
                    break;
            }
            
            key = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
            [row setObject:obj forKey:key];
        }
        
        [result addObject:row];
    }
    
    sqlite3_finalize(stmt);
    return result;
}

@end