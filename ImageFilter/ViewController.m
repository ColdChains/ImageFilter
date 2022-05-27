//
//  ViewController.m
//  ImageFilter
//
//  Created by lax on 2022/5/27.
//

#import "ViewController.h"
#import "ColorManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(88, 88, 100, 100)];
    imageView.image = [UIImage imageNamed:@"image"];
    [self.view addSubview:imageView];
    imageView.tag = 100;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(88, 288, 100, 100)];
    imageView.image = [UIImage imageNamed:@""];
    [self.view addSubview:imageView];
    imageView.tag = 101;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ((UIImageView *)[self.view viewWithTag:101]).image = [ColorManager changeImageColor:((UIImageView *)[self.view viewWithTag:100]).image colorStr:@"#000000"];
}

@end
