//
//  Conductor.h
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

#import "CDOperation.h"
#import "CDOperationQueue.h"
#import "CDProgressObserver.h"

@interface CDQueueController : NSObject

/**
 A key store for all the queues that this instance manages
 */
@property (nonatomic, readonly) NSMutableDictionary *queues;

/**
 Singleton Conductor instance
 */
+ (id)sharedInstance;

/**
 Add a configured queue to Conductor instance
 */
- (BOOL)addQueue:(CDOperationQueue *)queue;

- (CDOperationQueue *)getQueueNamed:(NSString *)queueName;

/**
 * Adds the operation to the queue with the given name at the specified priority.
 * Optionally create the queue if it doesn't already exist. Returns the operation
 * identifier.
 */
- (void)addOperation:(CDOperation *)operation 
        toQueueNamed:(NSString *)queueName;

/**
 Udates the operation with the identifier to the queue with the given name
 */
- (BOOL)updatePriorityOfOperationWithIdentifier:(NSString *)identifier
                                   inQueueNamed:(NSString *)queueName
                                  toNewPriority:(NSOperationQueuePriority)priority;

/**
 * Returns the operation in the given queue
 */
- (CDOperation *)operationWithIdentifier:(NSString *)identifier
                            inQueueNamed:(NSString *)queueName;

/**
 Returns YES if the queue with the given name has an operation either running or
 queued up to run with the identifier.
 */
- (BOOL)hasOperationWithIdentifier:(NSString *)identifier
                      inQueueNamed:(NSString *)queueName;

/**
 Adds the progress obsever to the queue
 */
- (void)addProgressObserver:(CDProgressObserver *)observer toQueueNamed:(NSString *)queueName;

/**
 Removes the progress obsever to the queue
 */
- (void)removeProgresObserver:(CDProgressObserver *)observer fromQueueNamed:(NSString *)queueName;

/**
 Gets messages when the max number of queued operations is reached, and when
 you can start submitting again. This is useful if you want to limit the amount of operations you can
 add to a queue and show feedback to the user.
 */
- (void)addQueueOperationObserver:(id)observer
                     toQueueNamed:(NSString *)queueName;

/**
 * List of all queue names
 */
- (NSArray *)allQueueNames;

/**
 Returns the number of operations currently in the queue.  Returns 0 if there is no queue of that
 name.
 */
- (NSUInteger)numberOfOperationsInQueueNamed:(NSString *)queueName;

/**
 Queries whether the conductor instance has queues.  Mostly useful for async
 tests.
 */
- (BOOL)hasQueues;

@end
