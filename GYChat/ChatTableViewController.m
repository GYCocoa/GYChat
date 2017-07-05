//
//  ChatTableViewController.m
//  GYChat
//
//  Created by GY.Z on 2017/6/28.
//  Copyright © 2017年 deepbaytech. All rights reserved.
//

#import "ChatTableViewController.h"

#import "LeftTableViewCell.h"
#import "RightTableViewCell.h"

static NSString *leftCellId = @"leftCellId";
static NSString *rightCellId = @"rightCellId";
@interface ChatTableViewController ()<XMPPStreamDelegate>
@property(nonatomic,strong)NSMutableArray *messages;


@end

@implementation ChatTableViewController

- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendAction)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:UIBarButtonItemStyleDone target:self action:@selector(imageAction)];
    self.navigationItem.rightBarButtonItems = @[item1,item2];
    
    [[XMPPManager defaultManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.tableView registerClass:[LeftTableViewCell class] forCellReuseIdentifier:leftCellId];
    [self.tableView registerClass:[RightTableViewCell class] forCellReuseIdentifier:rightCellId];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self reloadMessages];

}
- (void)imageAction{
    
}
- (void)sendAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发送消息" message:@"内容" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {}];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",alert.textFields.firstObject.text);
        NSString *name = alert.textFields.firstObject.text;
        //创建一个消息对象，并且指明接收者
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatToJid];
        //设置消息内容
        [message addBody:name];
        //发送消息
        [[XMPPManager defaultManager].xmppStream sendElement:message];
        //发送成功或者失败，有两种对应的代理方法
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"消息发送成功");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMessages];
    });
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error{
    NSLog(@"消息发送失败");
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"接收消息成功");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMessages];
    });
}

- (void)reloadMessages{
    //得到上下文
    NSManagedObjectContext *context = [XMPPManager defaultManager].messageArchivingContext;
    //搜索对象
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    //创建一个实体描述
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [request setEntity:entity];
    //查询条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[XMPPManager defaultManager].xmppStream.myJID.bare,self.chatToJid.bare];
    request.predicate = pre;
    //排序方式
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    //执行查询
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (self.messages.count != 0) {
        [self.messages removeAllObjects];
    }
    [self.messages addObjectsFromArray:array];
    [self.tableView reloadData];
    
    if (self.tableView.contentSize.height > self.tableView.frame.size.height){
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RightTableViewCell *rightCell = [tableView dequeueReusableCellWithIdentifier:rightCellId];
    rightCell.selectionStyle = UITableViewCellSelectionStyleNone;
    //将聊天信息放到cell上
    //拿到一个聊天消息
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messages[indexPath.row];
    if (message.isOutgoing != YES) {
        LeftTableViewCell *leftCell = [tableView dequeueReusableCellWithIdentifier:leftCellId];
        leftCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (leftCell == nil) {
            leftCell = [tableView dequeueReusableCellWithIdentifier:leftCellId];
        }
        leftCell.contentL.text = message.body;
        CGFloat w = [self adaptiveHeightWithString:message.body Font:15 Reduce:DYWidth*0.4].width;
        CGFloat h = [self adaptiveHeightWithString:message.body Font:15 Reduce:DYWidth*0.4].height;
        h = h + 40;
//        image=[image stretchableImageWithLeftCapWidth:200 topCapHeight:50];
        leftCell.bubbleImage.frame = CGRectMake(40, 0, w+40, h);
        leftCell.contentL.frame = CGRectMake(60, 20, w, h-40);
        return leftCell;
    }else{
        if (rightCell == nil) {
            rightCell = [tableView dequeueReusableCellWithIdentifier:leftCellId];
        }
        rightCell.contentL.text = message.body;
        CGFloat w = [self adaptiveHeightWithString:message.body Font:15 Reduce:DYWidth*0.4].width;
        CGFloat h = [self adaptiveHeightWithString:message.body Font:15 Reduce:DYWidth*0.4].height;
        h = h + 40;
        rightCell.bubbleImage.frame = CGRectMake(DYWidth-(w+80), 0, w+40, h);
        rightCell.contentL.frame = CGRectMake(DYWidth-(w+60), 20, w, h-40);
    }
    return rightCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messages[indexPath.row];
    if (message.isOutgoing != YES) {
        
    }
    CGFloat h = [self adaptiveHeightWithString:message.body Font:15 Reduce:DYWidth*0.4].height;
    h = h + 40;
    
    return h;
}

- (CGSize)adaptiveHeightWithString:(NSString *)str Font:(CGFloat)font Reduce:(CGFloat)reduce{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(DYWidth-reduce, INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}


//- (void)bubbleView:(NSString *)text{
//    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
//    CGSize size = [text boundingRectWithSize:CGSizeMake(DYWidth - 20, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
//    //背景图片
//    UIImage *bubble = [UIImage imageNamed:@"icon_left_chat_bubble"];
//    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble resizableImageWithCapInsets:UIEdgeInsetsMake(25, 30, 10, 10)]];
//    //添加文本信息
//    UILabel *bubbleText = [[UILabel alloc] init];
//    bubbleText.backgroundColor = [UIColor clearColor];
//    ///
//    bubbleText.font = [UIFont systemFontOfSize:15];
//    bubbleText.numberOfLines = 0;
//    bubbleText.lineBreakMode = NSLineBreakByCharWrapping;
//    bubbleText.text = text;
//    
//    [self.contentLab addSubview:bubbleImageView];
//    [self.contentLab addSubview:bubbleText];
//    [bubbleText mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(15);
//        make.size.mas_equalTo(CGSizeMake(size.width, size.height + 10));
//    }];
//    [bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.left.and.top.mas_equalTo(0);
//        make.size.mas_equalTo(CGSizeMake(size.width + 15, size.height + 10));
//    }];
//}






@end
