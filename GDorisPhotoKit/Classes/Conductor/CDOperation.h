//
//  CDOperation.h
//  Conductor
//
//  Created by Andrew Smith on 10/21/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@protocol CDOperationDelegate;

@interface CDOperation : NSOperation

@property (nonatomic, weak) id <CDOperationDelegate> delegate;

/**
 * Key used to track operation in CDOperationQueue.  If no identifier is provided,
 * the operations description will be used instead.  
 */
@property (nonatomic, strong) id identifier;

/**
 * Convenience init for adding an identifier to your operation.
 * @see identifier
 */
- (id)initWithIdentifier:(id)identifier;

/**
 * Factory for adding an identifier to your operation.
 * @see initWithIdentifier:
 */
+ (id)operationWithIdentifier:(id)identifier;

/**
 Do your main work here. This is where your subclass should do stuff, not in main.
 */
- (void)work;

/**
 Do whatever you gotta do after the operation is complete.
 */
- (void)cleanup;

/**
 Runs the cleanup and alerts the delegate that the operation has finished
 */
- (void)finish;

/**
 Run this in your "work" method to allow the task to continue even if the app has been backgrounded
 */
- (void)beginBackgroundTask;

/**
 Subclasses can override this to cleanup anything extra before the task is shut down by the OS
 */
- (void)backgroundTaskExpirationCleanup;

@end

@protocol CDOperationDelegate <NSObject>
- (void)operationDidFinish:(CDOperation *)operation;
- (void)operationWasCanceled:(CDOperation *)operation;
@end
