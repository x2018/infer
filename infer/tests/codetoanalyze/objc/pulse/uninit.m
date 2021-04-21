/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import <Foundation/Foundation.h>

@interface Uninit : NSObject

@property(nonatomic, assign) int obj_field;

@end

struct my_struct {
  int x;
  int y;
};

@implementation Uninit

- (void)capture_in_closure_ok {
  __block BOOL x;

  void (^block)() = ^() {
    x = true;
  };
}

- (BOOL)capture_in_closure_bad_FN {
  __block BOOL x;

  void (^block)() = ^() {
    x = true;
  };

  return x;
}

- (BOOL)set_in_closure_ok {
  __block BOOL x;

  void (^block)() = ^() {
    x = true;
  };

  block();
  return x;
}

- (BOOL)not_set_in_closure_bad_FN {
  __block BOOL x;

  void (^block)() = ^() {
  };

  block();
  return x;
}

- (BOOL)use_in_closure_bad_FN {
  __block BOOL x;

  void (^block)() = ^() {
    BOOL y = x;
  };

  block();
}

- (BOOL)dispatch_sync_closure_ok:(dispatch_queue_t)queue {
  __block BOOL x;

  dispatch_sync(queue, ^() {
    x = true;
  });
  return x;
}

- (BOOL)dispatch_sync_variable_closure_ok:(dispatch_queue_t)queue {
  __block BOOL x;

  void (^block)() = ^() {
    x = true;
  };
  dispatch_sync(queue, block);
  return x;
}

- (struct my_struct)return_my_struct {
  struct my_struct s;
  s.x = 1;
  s.y = 2;
  return s;
}

+ (int)call_return_my_struct_ok {
  Uninit* o = nil;
  return [o return_my_struct].x;
}

dispatch_queue_t queue;

- (void)dispatch_sync_block:(dispatch_block_t)block {
  dispatch_sync(queue, ^{
    block();
  });
}

- (int)init_x_in_block_ok {
  __block int x;
  [self dispatch_sync_block:^{
    x = self->_obj_field;
  }];
  return x;
}

@end
