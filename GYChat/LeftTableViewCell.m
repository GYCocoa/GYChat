//
//  LeftTableViewCell.m
//  GYChat
//
//  Created by GY.Z on 2017/7/4.
//  Copyright © 2017年 deepbaytech. All rights reserved.
//

#import "LeftTableViewCell.h"

@implementation LeftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initUI];
    }
    
    return self;
}

- (void)initUI{
    
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        _headerImage.image = [UIImage imageNamed:@"icon1"];
        _headerImage.clipsToBounds = YES;
        _headerImage.layer.cornerRadius = 15;
        [self.contentView addSubview:_headerImage];
    }
    
    if (!_bubbleImage) {
        _bubbleImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_recive"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)]];
        [self.contentView addSubview:_bubbleImage];
    }
    
    if (!_contentL) {
        _contentL = [[UILabel alloc] init];
        _contentL.font = [UIFont systemFontOfSize:15];
        _contentL.textColor = [UIColor whiteColor];
        _contentL.backgroundColor = [UIColor clearColor];
        _contentL.numberOfLines = 0;
        [self.contentView addSubview:_contentL];
    }
    
}


@end
