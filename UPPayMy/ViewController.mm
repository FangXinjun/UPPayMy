//
//  ViewController.m
//  UPPayMy
//
//  Created by myApplePro01 on 16/4/29.
//  Copyright © 2016年 LSH. All rights reserved.
//

/*
 3	测试帐号
 以下是测试用卡号、手机号等信息（此类信息仅供测试使用，不会发生真实交易）
 招商银行借记卡：6226090000000048
 手机号：18100000000
 密码：111101
 短信验证码：123456（先点获取验证码之后再输入）
 证件类型：01身份证
 证件号：510265790128303
 姓名：张三
 
 
 华夏银行贷记卡：6226388000000095
 手机号：18100000000
 CVN2：248
 有效期：1219
 短信验证码：123456（先点获取验证码之后再输入）
 证件类型：01身份证
 证件号：510265790128303
 姓名：张三
 
 二、客户端开发步骤
 1. 参考文档《中国银联手机支付控件使用指南》（该文档位于前台开发包的doc目录下），建立一下工程。
 2. 在后台开发实现消费（获取tn）请求前，App开发可以看看demo代码怎么调起控件的，demo里默认由银联的一个商户仿真获取tn（http://202.101.25.178:8080/sim/gettn或http://101.231.204.84:8091/sim/getacptn），之后需要改从商户自己的后台那里获取tn的。
 3. 后台开发完成消费请求后，与后台开发商讨一下后台和app间传递tn的方式。
 4. 改为从自己后台tn做测试。
 5. 自行增加其他业务逻辑。
 
 *  遇到问题可到https://open.unionpay.com/先自行看看能否解决：
 1) 如果是代码异常：帮助中心-FAQ中把异常拷贝一小段搜索；或可以到FAQ的开发问题类别下，搜“安卓”或“iOS”可搜到对应的全量开发问题。
 2) 如果是控件出错，报错信息有7位数字：技术集成-应答码，输入7位数字搜索。
 3) 如果是控件出错，没有报错信息或没有7位数字：帮助中心-FAQ-测试问题，搜“app”可搜到控件的全量测试问题。
 *  交易成功退出控件后开发包demo里有段验证签名的代码，代码默认是在手机app（此处就是指demo的app）中验签，请注意一定修改为传给后台进行验签，对应后台开发包demo的VerifyAppData文件。（验签公钥证书到期后需要更新的，如果放app里做会很难更新的。）
 
 */



#import "ViewController.h"
#import "UPPaymentControl.h"

#define kURL_TN_Normal                @"http://101.231.204.84:8091/sim/getacptn"



@interface ViewController ()
@property (nonatomic, strong) NSMutableData        *responseData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//    _responseData = [[NSMutableData alloc] init];
    
}


- (void)btnClick:(UIButton *)btn{
    
    [self startNetWithURL:[NSURL URLWithString:kURL_TN_Normal]];
    
}

#pragma mark - NSURLConnection
- (void)startNetWithURL:(NSURL *)url
{
    NSURLRequest * urlRequest=[NSURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
}


#pragma mark - connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    NSInteger code = [rsp statusCode];
    if (code != 200)
    {
        
        [connection cancel];
    }
    else
    {
        _responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    [_responseData appendData:data];
    _responseData = [data copy];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    //交易流水号，商户后台向银联后台提交订单信息后，由银联后台生成并下发给商户后台的交易凭证
    NSString* tn = [[NSMutableString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    if (tn != nil && tn.length > 0)
    {
        [[UPPaymentControl defaultControl] startPay:tn fromScheme:@"UPPay" mode:@"01" viewController:self];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
    NSLog(@"%@",error);
    
    UIAlertController *alrtVC = [UIAlertController alertControllerWithTitle:@"提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {


    }];
    UIAlertAction *alction1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        
    }];
    [alrtVC addAction:alction];
    [alrtVC addAction:alction1];
    [self showDetailViewController:alrtVC sender:nil];
    

}

#pragma mark UPPayPluginResult
- (void)UPPayPluginResult:(NSString *)result
{
    //    NSString* msg = [NSString stringWithFormat:kResult, result];
}


#pragma mark  NSURLSession
//- (void)startNetWithURL:(NSURL *)url
//{
//    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
//
//    //(1)设置请求方式
//    [request setHTTPMethod:@"GET"];
//
////    (2)超时时间
//    [request setTimeoutInterval:120];
////
////    (3)缓存策略
//    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
//
//    //3.构造Session
//    NSURLSession *session = [NSURLSession sharedSession];
//
//
//    //4.构造要执行的任务task
//    /**
//     * task
//     *
//     * @param data 返回的数据
//     * @param response 响应头
//     * @param error 错误信息
//     *
//     */
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //201604291938271762738
//
////        [_responseData appendData:data];
//        //交易流水号，商户后台向银联后台提交订单信息后，由银联后台生成并下发给商户后台的交易凭证 201604291500331400488
//        NSString *tn = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
//        NSString *tn1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//        NSLog(@"%@",tn);
//        NSLog(@"%@",tn1);
//
//
//        if ([[UPPaymentControl defaultControl] isPaymentAppInstalled]) {
//            NSLog(@"安装");
//        }
//        //当获得的tn不为空时，调用支付接口
//        if (tn != nil && tn.length > 0)
//        {
//            // 接入模式，标识商户以何种方式调用支付控件，该参数提供以下两个可选值：
//            //        "00"代表接入生产环境（正式版本需要）；
//            //        "01"代表接入开发测试环境（测试版本需要）；
//            [[UPPaymentControl defaultControl]
//             startPay:tn
//             fromScheme:@"UPPayTest"
//             mode:@"01"
//             viewController:self];
//        }
//
//    }];
//
//    [task resume];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
