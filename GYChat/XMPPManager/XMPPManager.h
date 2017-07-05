//
//  XMPPManager.h
//  GYChat
//
//  Created by GY.Z on 2017/6/28.
//  Copyright © 2017年 deepbaytech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRoster.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"


@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>
//通信管道，输入输出流
@property(nonatomic,strong)XMPPStream *xmppStream;
//好友管理
@property(nonatomic,strong)XMPPRoster *xmppRoster;

//聊天信息归档
@property(nonatomic,strong)XMPPMessageArchiving *xmppMessageArchiving;
//信息归档的上下文
@property(nonatomic,strong)NSManagedObjectContext *messageArchivingContext;






//单例方法
+(XMPPManager *)defaultManager;
//登录的方法
-(void)loginwithName:(NSString *)userName andPassword:(NSString *)password;
//注册
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password;
-(void)logout;
@end
