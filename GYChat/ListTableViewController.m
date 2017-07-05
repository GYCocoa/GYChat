//
//  ListTableViewController.m
//  GYChat
//
//  Created by GY.Z on 2017/6/28.
//  Copyright © 2017年 deepbaytech. All rights reserved.
//

#import "ListTableViewController.h"
#import "ChatTableViewController.h"

@interface ListTableViewController ()<XMPPRosterDelegate,XMPPStreamDelegate>

@property(nonatomic,strong)NSMutableArray *rosterJids;


@end

@implementation ListTableViewController

- (NSMutableArray *)rosterJids{
    if (!_rosterJids) {
        _rosterJids = [NSMutableArray array];
    }
    return _rosterJids;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    [[XMPPManager defaultManager].xmppRoster  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addFriendsAction)];
    self.navigationItem.rightBarButtonItems = @[item1];
    
    [[XMPPManager defaultManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)addFriendsAction{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"请输入昵称" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {}];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",alert.textFields.firstObject.text);
        NSString *name = alert.textFields.firstObject.text;
        XMPPJID *jid = [XMPPJID jidWithUser:name domain:@"192.168.1.17" resource:@"iPhone"];
        [[XMPPManager defaultManager].xmppRoster subscribePresenceToUser:jid];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark 开始检索好友列表的方法
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"开始检索好友列表");
}

#pragma mark 正在检索好友列表的方法
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    NSLog(@"每一个好友都会走一次这个方法");
    //获得item的属性里的jid字符串，再通过它获得jid对象
    if ([[[item attributeForName:@"subscription"] stringValue] isEqualToString:@"both"]||[[[item attributeForName:@"subscription"] stringValue] isEqualToString:@"from"]||[[[item attributeForName:@"subscription"] stringValue] isEqualToString:@"to"]) {
        NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
        XMPPJID *jid = [XMPPJID jidWithString:jidStr];
        //是否已经添加
        if ([self.rosterJids containsObject:jid]) {
            return;
        }
        //将好友添加到数组中去
        [self.rosterJids addObject:jid];
        //添加完数据要更新UI（表视图更新）
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.rosterJids.count-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark 好友列表检索完毕的方法
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"好友列表检索完毕");
}


#pragma mark 删除好友执行的方法
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //找到要删除的人
        XMPPJID *jid = self.rosterJids[indexPath.row];
        //从数组中删除
        [self.rosterJids removeObjectAtIndex:indexPath.row];
        //从Ui单元格删除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic
         ];
        //从服务器删除
        [[XMPPManager defaultManager].xmppRoster removeUser:jid];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.rosterJids.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (self.rosterJids.count > 0) {
        XMPPJID *jid = self.rosterJids[indexPath.row];
        cell.textLabel.text = jid.user;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatTableViewController *chat = [ChatTableViewController new];
    chat.chatToJid = self.rosterJids[indexPath.row];
    [self.navigationController pushViewController:chat animated:YES];
    
}




@end
