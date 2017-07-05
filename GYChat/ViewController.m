//
//  ViewController.m
//  GYChat
//
//  Created by GY.Z on 2017/6/28.
//  Copyright © 2017年 deepbaytech. All rights reserved.
//

#import "ViewController.h"
#import "ListTableViewController.h"

@interface ViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UITextField *pwdTF;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[XMPPManager defaultManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (sender.tag == 1) {
        [[XMPPManager defaultManager] registerWithName:self.nameTF.text andPassword:self.pwdTF.text];
    }else{
        [[XMPPManager defaultManager] loginwithName:self.nameTF.text andPassword:self.pwdTF.text];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    ListTableViewController *view = [ListTableViewController new];
    [self.navigationController pushViewController:view animated:YES];
}


@end
