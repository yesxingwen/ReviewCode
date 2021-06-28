//
//  ViewController.m
//  PermanentThread
//
//  Created by zhongxingwen on 2021/6/28.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)createThread:(UIButton *)sender {
    if (self.thread == nil) {
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(action) object:nil];
        [self.thread start];
    }
}

- (void)action {
    // 监听runloop状态变化
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = [NSString stringWithFormat:@"%@ \r 监听到RunLoop状态发生改变 = %zd", self.textView.text, activity];
        });
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    // 添加端口，常驻
    @autoreleasepool {
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
}

- (IBAction)onThread:(UIButton *)sender {
    // 在线程中执行代码
    [self performSelector:@selector(threadAction) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)threadAction {
    // 线程中
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = [NSString stringWithFormat:@"%@ \r 在常驻线程中执行了任务", self.textView.text];
    });
}

@end
