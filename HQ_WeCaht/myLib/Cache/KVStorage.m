//
//  KVStorage.m
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "KVStorage.h"
#import <UIKit/UIKit.h>

///此宏传入一个你想引入文件的名称作为参数，如果该文件能够被引入则返回1，否则返回0。
#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif


@implementation  KVStorageItem

@end

///数据库出现错误的次数
static const NSUInteger kMaxErrorRetryCount = 8;
///本次开机时间 到本次开机最后一次出现错误时 的最小时间戳
static const NSTimeInterval kMinRetryTimeInterval = 2.0;
///路径的最大长度
static const int kPathLengthMax = PATH_MAX - 64 ;
///数据库名称
static  NSString *const kDBFileName = @"manifest.sqlite";
///shm 缓存文件
static  NSString *const kDBShmFileName = @"manifest.sqlite-shm";
///wal 缓存文件
static  NSString *const kDBWalFileName = @"manifest.sqlite-wal";
/// 数据路径
static NSString *const kDataDirectoryName = @"data";
/// 垃圾文件路径
static NSString *const kTrashDirectoryName = @"trash";


@implementation KVStorage{
    ///清楚数据的队列
    dispatch_queue_t _trashQueue;
    ///数据库
    sqlite3 *_db;
    ///垃圾路径
    NSString *_trashPath;
    ///存放数据的路径
    NSString *_dataPath;
    ///数据库路径
    NSString *_dbPath;
    NSString *_path;
    /// 缓存字典 (缓存 sqlite3_stmt)
    CFMutableDictionaryRef _dbStmtCache;
    ///数据库从手机开机到发生错误的时间戳
    NSTimeInterval _dbLastOpenErrorTime;
    /// 数据库发生错误的次数
    NSUInteger _dbOpenErrorCount;

}
- (BOOL)dbOpen{
    if(_db) return YES;
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallBacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallBacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallBacks, &valueCallBacks);
        return YES;
    }else{
        _db = NULL;
        if (_dbStmtCache) CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        _dbLastOpenErrorTime = CACurrentMediaTime();
        _dbOpenErrorCount += 1;
        NSLog(@"%s line:%d sqlite open failed (%d).", __FUNCTION__, __LINE__, result);
        return NO;
    }
}
- (BOOL)dbClose{
    if(!_db) return YES;
    
    int  result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    ///清空缓存
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    do {
        retry = NO;
        result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    ////unction is called to delete a [prepared statement]
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        }
    } while (retry);
    _db = NULL;
    return YES;
}
- (BOOL)dbCheck{
    if (!_db) {
        if (_dbOpenErrorCount <= kMaxErrorRetryCount && (CACurrentMediaTime() - _dbLastOpenErrorTime ) > kMinRetryTimeInterval) {
            return [self dbOpen] && [self dbInitilize];
        }else{
            return NO;
        }
    }
    return YES;
}
- (BOOL)dbInitilize{
    NSString *sql = @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists manifest (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on manifest(last_access_time);";
    return [self dbExecute:sql];
}
- (void)dbCheckPoint{
    if (![self dbCheck]) return;
    ////checkPoint 是把日志文件 wal 提交到数据库文件
    sqlite3_wal_checkpoint(_db, NULL);
    
}
- (BOOL)dbExecute:(NSString *)sql{
    if (sql.length <= 0) return NO;
    if (![self dbCheck]) return NO;
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        NSLog(@"%s line:%d sqlite open failed (%d).", __FUNCTION__, __LINE__, result);
        return NO;
    }
    return result == SQLITE_OK;
}
- (sqlite3_stmt *)dbPrepareStmt:(NSString *)sql {
    if (![self dbCheck] || sql.length <= 0 || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)sql);
    if (!stmt) {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"error msg = %s",sqlite3_errmsg(_db));
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)sql, stmt);
    }else{
    //function is called to reset a prepared statement object back to its initial state 重置  stmt 到初始化状态 跟sqlite3_prepare_v2一样
        sqlite3_reset(stmt);
    }
    return stmt;
}
- (NSString *)dbJoinedKeys:(NSArray *)keys {
    NSMutableString *string = [NSMutableString new];
    for (NSUInteger i = 0,max = keys.count; i < max; i++) {
        [string appendString:@"?"];
        if (i + 1 != max) {
            [string appendString:@","];
        }
    }
    return string;
}
////绑定数据
- (void)dbBindJoinedKeys:(NSArray *)keys stmt:(sqlite3_stmt *)stmt fromIndex:(int)index{
    for (int i = 0 , max = (int) keys.count; i < max; i++) {
        NSString *key = keys[i];
        sqlite3_bind_text(stmt, index+1, key.UTF8String, -1, NULL);
    }
}
- (BOOL)dbSaveWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName extendData:(NSData *)extendData{
     NSString *sql = @"insert or replace into manifest (key, filename, size, inline_data, modification_time, last_access_time, extended_data) values (?1, ?2, ?3, ?4, ?5, ?6, ?7);";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return NO;
    ////绑定参数对应的数据
    int timestamp = (int)time(NULL);
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, fileName.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 3, (int)value.length);
    if (fileName.length == 0) {
        sqlite3_bind_blob(stmt, 4, value.bytes, (int)value.length, 0);
    }else{
        sqlite3_bind_blob(stmt, 4, NULL, 0, 0);
    }
    sqlite3_bind_int(stmt, 5, timestamp);
    sqlite3_bind_int(stmt, 6, timestamp);
    sqlite3_bind_blob(stmt, 7, extendData.bytes, (int)extendData.length, 0);
    ////evaluate stmt
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    return YES;
}
#warning 此处还没有  sqlite3_finalize
///更新一条数据
- (BOOL)dbUpDateAccessTimeWithKey:(NSString *)key{
    if (key.length == 0) return NO;
    NSString *sql = @"update manifest set last_access_time = ?1 where key = ?2;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    sqlite3_bind_int(stmt, 1, (int)time(NULL));
    sqlite3_bind_text(stmt, 2, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE){
         NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    return YES;
}
///跟新多条数据
- (BOOL)dbUpdateAccessTimeWithKeys:(NSArray *)keys{
    if (keys.count == 0 ) return NO;
    int t = (int)time(NULL);
    NSString *sql = [NSString stringWithFormat:@"update manifest set last_access_time = %d where key in (%@)",t,[self dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(_db, sql.UTF8String, -1, &stmt, NULL);
    if (!stmt || result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    [self dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    //step
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    return YES;
}
- (BOOL)dbDeleteItemWithKey:(NSString *)key{
    if (key.length == 0) return NO;
    NSString *sql = @"delete from manifest where key = ?1";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (stmt) return NO;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    return YES;
}
- (BOOL)dbDeleteItemsWithKeys:(NSArray *)keys{
    if (keys.count == 0) return NO;
    NSString *sql = [NSString stringWithFormat:@"delete from manifest where key in (%@);",[self dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    [self dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return  NO;
    }
    return YES;
}
- (BOOL)dbDeleteItemsWithSizeLargeThan:(int)size{
    if (size < 0) return NO;
    NSString *sql = @"delete from  manifest where size > ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return NO;
    int result = sqlite3_bind_int(stmt, 1, size);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    return YES;
}
- (BOOL)dbDelteItemsWithSizeEarlizerThan:(int)time{
    if (time < 0) return NO;
    NSString *sql = @"delete from  manifest where last_access_time < ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return NO;
    int result = sqlite3_bind_int(stmt, 1, time);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        return NO;
    }
    return YES;
}
#warning 需要测试
- (KVStorageItem *)dbGetItemFromStmt:(sqlite3_stmt *)stmt extendLineData:(BOOL)extendLineData{
    if (!stmt) return nil;
    ///从第0列开始
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *fileName = (char *)sqlite3_column_text(stmt, i++);
    int size = (int)sqlite3_column_int(stmt, i++);
    const void *inlineData = extendLineData? NULL : sqlite3_column_blob(stmt, i);
    int inlineDataSize = extendLineData ? 0 : sqlite3_column_bytes(stmt, i++);
    int modifyTime = sqlite3_column_int(stmt, i++);
    int lastAccessTime = sqlite3_column_int(stmt, i++);
    const void *extendData = sqlite3_column_blob(stmt, i);
    int extendDataSize = sqlite3_column_bytes(stmt, i);
    
    KVStorageItem *item = [KVStorageItem new];
    item.key = [NSString stringWithUTF8String:key];
    item.filename = [NSString stringWithUTF8String:fileName];
    item.size = size;
    if (inlineDataSize > 0 && inlineData) item.value = [NSData dataWithBytes:inlineData length:inlineDataSize];
    item.accessTime = lastAccessTime;
    item.modTime = modifyTime;
    if (extendData && extendDataSize > 0) item.extendedData = [NSData dataWithBytes:extendData length:extendDataSize];
    return item;
}

- (KVStorageItem *)dbGetItemWith:(NSString *)key extendLineData:(BOOL)extendLineData{
    if (key.length == 0) return nil;
    NSString *sql = extendLineData ? @"select key, filename, size, modification_time, last_access_time, extended_data from manifest where key = ?1;" : @"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    KVStorageItem *item = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        item = [self dbGetItemFromStmt:stmt extendLineData:extendLineData];
    }else{
        if (result != SQLITE_DONE) {         
            NSLog(@" function %s occor error %s at line %d",__FUNCTION__,sqlite3_errmsg(_db),__LINE__);
        }
    }
    return item;
}
- (NSMutableArray *)dbGetItemsWithKeys:(NSArray *)keys extendInlineData:(BOOL)extendInlinData{
    if (keys.count == 0) return nil;
    if (![self dbCheck]) return nil;
    NSString *sql;
    if (extendInlinData) {
        sql = [NSString stringWithFormat:@"select key, filename, size, modification_time, last_access_time, extended_data from manifest where key in (%@);", [self dbJoinedKeys:keys]];
    } else {
        sql = [NSString stringWithFormat:@"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from manifest where key in (%@)", [self dbJoinedKeys:keys]];
    }
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            KVStorageItem *item = [self dbGetItemFromStmt:stmt extendLineData:extendInlinData];
            if (item) [items addObject:item];
        }else if (result == SQLITE_DONE){
            break;
        }else{
            NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}
- (NSData *)dbGetValueWith:(NSString *)key{
    if (key.length == 0) return nil;
    NSString *sql = @"select inline_data from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        const void *inline_data = sqlite3_column_blob(stmt, 0);
        int inline_data_bytes = sqlite3_column_bytes(stmt, 0);
        if (!inline_data || inline_data_bytes <= 0) return nil;
        return [NSData dataWithBytes:inline_data length:inline_data_bytes];
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
        return nil;
    }
}
- (NSString *)dbGetFilenameWithKey:(NSString *)key {
    NSString *sql = @"select filename from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        char *filename = (char *)sqlite3_column_text(stmt, 0);
        if (filename && *filename != 0) {
            return [NSString stringWithUTF8String:filename];
        }
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return nil;
}
- (NSMutableArray *)dbGetFilenameWithKeys:(NSArray *)keys {
    if (![self dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select filename from manifest where key in (%@);", [self dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
         NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return filenames;
}
- (NSMutableArray *)dbGetFilenamesWithSizeLargerThan:(int)size {
    NSString *sql = @"select filename from manifest where size > ?1 and filename is not null;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, size);
    
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
             NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}
- (NSMutableArray *)dbGetFilenamesWithTimeEarlierThan:(int)time {
    NSString *sql = @"select filename from manifest where last_access_time < ?1 and filename is not null;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, time);
    
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
             NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}
- (NSMutableArray *)dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = @"select key, filename, size from manifest order by last_access_time asc limit ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, count);
    
    NSMutableArray *items = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *key = (char *)sqlite3_column_text(stmt, 0);
            char *filename = (char *)sqlite3_column_text(stmt, 1);
            int size = sqlite3_column_int(stmt, 2);
            NSString *keyStr = key ? [NSString stringWithUTF8String:key] : nil;
            if (keyStr) {
                KVStorageItem *item = [KVStorageItem new];
                item.key = key ? [NSString stringWithUTF8String:key] : nil;
                item.filename = filename ? [NSString stringWithUTF8String:filename] : nil;
                item.size = size;
                [items addObject:item];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    return items;
}
- (int)dbGetItemCountWithKey:(NSString *)key {
    NSString *sql = @"select count(key) from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return -1;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}
- (int)dbGetTotalItemSize {
    NSString *sql = @"select sum(size) from manifest;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return -1;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}
- (int)dbGetTotalItemCount {
    NSString *sql = @"select count(*) from manifest;";
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return -1;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
         NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}
#pragma mark      file

- (BOOL)fileWriteWithName:(NSString *)fileName data:(NSData *)data{
    NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
    return [data writeToFile:path atomically:NO];
}
- (NSData *)fileReadWithName:(NSString *)fileName {
    NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
    return [NSData dataWithContentsOfFile:path];
}
- (BOOL)fileDeleteWith:(NSString *)fileName{
    NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}
- (BOOL)fileMoveAllToTrash{
    CFUUIDRef uuidf = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidf);
    CFRelease(uuidf);
    NSString *tempPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)uuid];
    BOOL res = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tempPath error:NULL];
    if (res) {
        res = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    CFRelease(uuid);
    return res;
}
- (void)fileEmptyTrashInBackground{
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *man = [NSFileManager defaultManager];
        NSArray *paths = [man contentsOfDirectoryAtPath:_trashPath error:NULL];
        for (NSString *path in paths) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [man removeItemAtPath:fullPath error:NULL];
        }
    });
}

- (void)reset {
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBShmFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBWalFileName] error:nil];
    [self fileMoveAllToTrash];
    [self fileEmptyTrashInBackground];
}


#pragma mark ------- public --
- (instancetype)init{
    @throw [NSException exceptionWithName:@"KVStorage init faild" reason:@"please user  initWithPath: type: function" userInfo:nil];
    return [self initWithPath:nil type:KVStorageTypeMixed];
}

- (nullable instancetype)initWithPath:(NSString *)path type:(KVStorageType)type{
    if (path.length == 0 || path.length > kPathLengthMax) {
        NSLog(@"path  is  not invalid ");
        return nil;
    }
    if (type > KVStorageTypeMixed) {
        return nil;
    }
    self = [super init];
    _path = path.copy;
    _type = type;
    _dataPath = [_path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [_path stringByAppendingPathComponent:kTrashDirectoryName];
    _trashQueue = dispatch_queue_create("trashQueue", DISPATCH_QUEUE_SERIAL);
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]
        || ![[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:&error]
        || ![[NSFileManager defaultManager] createDirectoryAtPath:_trashPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"error = %@",error);
        return nil;
    }
    if (![self dbOpen] || ![self dbInitilize]) {
        [self dbClose];
        [self reset];
        if (![self dbOpen] || ![self dbInitilize]) {
            [self dbClose];
            return nil;
        }
    }
    [self fileEmptyTrashInBackground];
    return self;
}
- (void)dealloc{
    [self dbClose];
}
- (BOOL)saveItem:(KVStorageItem *)item{
    return [self saveItemWithKey:item.key value:item.value filename:item.filename extendedData:item.extendedData];
}
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value{
    return [self saveItemWithKey:key value:value filename:nil extendedData:nil];
}
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value filename:(NSString *)filename extendedData:(NSData *)extendedData{
    if (key.length == 0 || filename.length == 0) return NO;
    if (_type == KVStorageTypeFile && filename.length == 0) return NO;
    if (filename.length) {
        if (![self fileWriteWithName:filename data:value]) {
            return NO;
        }
        if (![self dbSaveWithKey:key value:value fileName:filename extendData:extendedData]) {
            [self fileDeleteWith:filename];
            return NO;
        }
        return YES;
    }else{
        if (_type != KVStorageTypeSQLite) {
            NSString *name = [self dbGetFilenameWithKey:key];
            if (name) {
                [self fileDeleteWith:name];
            }
        }
        return [self dbSaveWithKey:key value:value fileName:nil extendData:extendedData];
    }
}
- (BOOL)removeItemForKey:(NSString *)key {
    if (key.length == 0) return NO;
    switch (_type) {
        case KVStorageTypeSQLite: {
            return [self dbDeleteItemWithKey:key];
        } break;
        case KVStorageTypeFile:
        case KVStorageTypeMixed: {
            NSString *filename = [self dbGetFilenameWithKey:key];
            if (filename) {
                [self fileDeleteWith:filename];
            }
            return [self dbDeleteItemWithKey:key];
        } break;
        default: return NO;
    }
}
- (BOOL)removeItemForKeys:(NSArray *)keys {
    if (keys.count == 0) return NO;
    switch (_type) {
        case KVStorageTypeSQLite: {
            return [self dbDeleteItemsWithKeys:keys];
        } break;
        case KVStorageTypeFile:
        case KVStorageTypeMixed: {
            NSArray *filenames = [self dbGetFilenameWithKeys:keys];
            for (NSString *filename in filenames) {
                [self fileDeleteWith:filename];
            }
            return [self dbDeleteItemsWithKeys:keys];
        } break;
        default: return NO;
    }
}
- (BOOL)removeItemsLargerThanSize:(int)size{
    if (size >= INT_MAX) return NO;
    if (size <= 0) return [self removeAllItems];
    switch (_type) {
        case KVStorageTypeSQLite: {
            if ([self dbDeleteItemsWithSizeLargeThan:size]) {
                [self dbCheckPoint];
                return YES;
            }
        } break;
        case KVStorageTypeFile:
        case KVStorageTypeMixed: {
            NSArray *filenames = [self dbGetFilenamesWithSizeLargerThan:size];
            for (NSString *name in filenames) {
                [self fileDeleteWith:name];
            }
            if ([self dbDeleteItemsWithSizeLargeThan:size]) {
                [self dbCheckPoint];
                return YES;
            }
        } break;
    }
    return NO;
}
- (BOOL)removeItemsEarlierThanTime:(int)time {
    if (time <= 0) return YES;
    if (time == INT_MAX) return [self removeAllItems];
    
    switch (_type) {
        case KVStorageTypeSQLite: {
            if ([self dbDeleteItemsWithSizeLargeThan:time]) {
                [self dbCheckPoint];
                return YES;
            }
        } break;
        case KVStorageTypeFile:
        case KVStorageTypeMixed: {
            NSArray *filenames = [self dbGetFilenamesWithTimeEarlierThan:time];
            for (NSString *name in filenames) {
                [self fileDeleteWith:name];
            }
            if ([self dbDeleteItemsWithSizeLargeThan:time]) {
                [self dbCheckPoint];
                return YES;
            }
        } break;
    }
    return NO;
}
- (BOOL)removeItemsToFitSize:(int)maxSize {
    if (maxSize == INT_MAX) return YES;
    if (maxSize <= 0) return [self removeAllItems];
    
    int total = [self dbGetTotalItemSize];
    if (total < 0) return NO;
    if (total <= maxSize) return YES;
    
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        int perCount = 16;
        items = [self dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (KVStorageItem *item in items) {
            if (total > maxSize) {
                if (item.filename) {
                    [self fileDeleteWith:item.filename];
                }
                suc = [self dbDeleteItemWithKey:item.key];
                total -= item.size;
            } else {
                break;
            }
            if (!suc) break;
        }
    } while (total > maxSize && items.count > 0 && suc);
    if (suc) [self dbCheckPoint];
    return suc;
}
- (BOOL)removeItemsToFitCount:(int)maxCount {
    if (maxCount == INT_MAX) return YES;
    if (maxCount <= 0) return [self removeAllItems];
    
    int total = [self dbGetTotalItemCount];
    if (total < 0) return NO;
    if (total <= maxCount) return YES;
    
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        int perCount = 16;
        items = [self dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (KVStorageItem *item in items) {
            if (total > maxCount) {
                if (item.filename) {
                    [self fileDeleteWith:item.filename];
                }
                suc = [self dbDeleteItemWithKey:item.key];
                total--;
            } else {
                break;
            }
            if (!suc) break;
        }
    } while (total > maxCount && items.count > 0 && suc);
    if (suc) [self dbCheckPoint];
    return suc;
}
- (void)removeAllItemsWithProcessBlock:(void (^)(int removeCount , int totalCount))processBlock endBlock:(void (^)(BOOL success))endBlock{
    int total = [self dbGetTotalItemSize];
    if (total <= 0) {
        if(endBlock) endBlock(NO);
    }else{
        int left = total;
        int perCount = 32;
        NSArray *items = nil;
        BOOL suc = NO;
        do {
            items = [self dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
            for (KVStorageItem *item in items) {
                if (left > 0) {
                    if (item.filename) {
                        [self fileDeleteWith:item.filename];
                    }
                    [self dbDeleteItemWithKey:item.key];
                    left -= 1;
                    if (processBlock) processBlock(total - left , total);
                }else{
                    break;
                }
            }
            if (processBlock) processBlock(total - left , total);
        } while (items.count && suc && left > 0);
        if (suc) [self dbCheckPoint];
        if (endBlock) endBlock(YES);
    }
}
- (BOOL)removeAllItems{
    if (![self dbClose]) return NO;
    [self reset];
    if (![self dbOpen]) return NO;
    if (![self dbInitilize]) return NO;
    return YES;
}
- (KVStorageItem *)getItemForKey:(NSString *)key {
    if (key.length == 0) return nil;
    KVStorageItem *item = [self dbGetItemWith:key extendLineData:NO];
    if (item) {
        [self dbUpDateAccessTimeWithKey:key];
        if (item.filename) {
            item.value = [self fileReadWithName:item.filename];
            if (!item.value) {
                [self dbDeleteItemWithKey:key];
                item = nil;
            }
        }
    }
    return item;
}
- (KVStorageItem *)getItemInfoForKey:(NSString *)key {
    if (key.length == 0) return nil;
    KVStorageItem *item = [self dbGetItemWith:key extendLineData:YES];
    return item;
}
- (NSData *)getItemValueForKey:(NSString *)key {
    if (key.length == 0) return nil;
    NSData *value = nil;
    switch (_type) {
        case KVStorageTypeFile: {
            NSString *filename = [self dbGetFilenameWithKey:key];
            if (filename) {
                value = [self fileReadWithName:filename];
                if (!value) {
                    [self dbDeleteItemWithKey:key];
                    value = nil;
                }
            }
        } break;
        case KVStorageTypeSQLite: {
            value = [self dbGetValueWith:key];
        } break;
        case KVStorageTypeMixed: {
            NSString *filename = [self dbGetFilenameWithKey:key];
            if (filename) {
                value = [self fileReadWithName:filename];
                if (!value) {
                    [self dbDeleteItemWithKey:key];
                    value = nil;
                }
            } else {
                value = [self dbGetValueWith:key];
            }
        } break;
    }
    if (value) {
        [self dbUpDateAccessTimeWithKey:key];
    }
    return value;
}
- (NSArray *)getItemForKeys:(NSArray *)keys {
    if (keys.count == 0) return nil;
    NSMutableArray *items = [self dbGetItemsWithKeys:keys extendInlineData:NO];
    if (_type != KVStorageTypeSQLite) {
        for (NSInteger i = 0, max = items.count; i < max; i++) {
            KVStorageItem *item = items[i];
            if (item.filename) {
                item.value = [self fileReadWithName:item.filename];
                if (!item.value) {
                    if (item.key) [self dbDeleteItemWithKey:item.key];
                    [items removeObjectAtIndex:i];
                    i--;
                    max--;
                }
            }
        }
    }
    if (items.count > 0) {
        [self dbUpdateAccessTimeWithKeys:keys];
    }
    return items.count ? items : nil;
}
- (NSArray *)getItemInfoForKeys:(NSArray *)keys {
    if (keys.count == 0) return nil;
    return [self dbGetItemsWithKeys:keys extendInlineData:YES];
}
- (NSDictionary *)getItemValueForKeys:(NSArray *)keys {
    NSMutableArray *items = (NSMutableArray *)[self getItemForKeys:keys];
    NSMutableDictionary *kv = [NSMutableDictionary new];
    for (KVStorageItem *item in items) {
        if (item.key && item.value) {
            [kv setObject:item.value forKey:item.key];
        }
    }
    return kv.count ? kv : nil;
}
- (BOOL)itemExistsForKey:(NSString *)key {
    if (key.length == 0) return NO;
    return [self dbGetItemCountWithKey:key] > 0;
}

- (int)getItemsCount {
    return [self dbGetTotalItemCount];
}

- (int)getItemsSize {
    return [self dbGetTotalItemSize];
}

@end



/*
 sqlite3 :
 
 sqlite3_stmt 是把要执行的sql语句 转换成 sqlite3_stmt
 
 
 
 
 
 sql :
 
 //// journal_mode 是数据库的链接模式  wal 是类似于一个日志文件   数据库的操作先在wal文件中执行 然后再checkPoint 提交到数据库
 
   WAL的文件会在执行checkpoint操作时写回数据库文件，或者当文件大小达到某个阙值时（默认为1KB）会自动执行checkpoint操作

 pragma journal_mode = wal;

 
 
 
 
 
 sqlite的磁盘写入速度分为三个等级： 当synchronous为FULL时，数据库引擎会在紧急时刻暂停以确定数据写入磁盘，这样能保证在系统崩溃或者计算机死机的环境下数据库在重启后不会被损坏，代价是插入数据的速度会降低。
 
 如果synchronous为OFF则不会暂停。除非计算机死机或者意外关闭的情况，否则即便是sqlite程序崩溃了，数据也不会损伤，这种等级的写入速度最高
 
 PRAGMA synchronous = FULL; (2)
 PRAGMA synchronous = NORMAL; (1)
 PRAGMA synchronous = OFF; (0)
 
 pragma synchronous = normal;
 
 
 
 
 
 
 ///创建表
 create table if not exists manifest (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key));
 
 
 
 ////创建索引
 create index if not exists last_access_time_idx on
  manifest(last_access_time);
 
 sql语句会被 sqlite3_prepare  编译(complie)成  sqlite3_stmt 然后再执行
 
 sqlite3_reset(sqlite3_stmt *pStmt) :
 The sqlite3_reset() function is called to reset a prepared statement object back to its initial state,
 sqlite3_reset() 重置statement 到它的初始化状态
 
 
 
 
 sqlite3_exec实际上是将编译，执行进行了封装，与之等价的一组函数是 sqlite3_prepare_v2(), sqlite3_step()和sqlite3_finalize()。sqlite3_prepare_v2()编译SQL语句生成VDBE执行码，sqlite3_step()执行，sqlite3_finalize()关闭语句句柄，释放资源。两种方式，都可以通过调用sqlite3_changes(pdb)，得到语句影响的行数。
 
    参数大于一个的时候 需要使用 sqlite3_finalize 时
 
 2.3两种方式比较
 (1).sqlite3_exec方式接口使用很简单，实现同样的功能，比sqlite3_perpare_v2接口代码量少。
 (2).sqlite3_prepare方式更高效，因为只需要编译一次，就可以重复执行N次。
 (3).sqlite3_prepare方式支持参数化SQL。
 
 
 
 */




