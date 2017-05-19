//
//  LRResponseSerializer.m
//  Pods
//
//  Created by Raviteja Ghanta on 03/03/17.
//
//

#import "LRResponseSerializer.h"
#import "NSError+LRError.h"
#import "NSString+LRString.h"

static NSString * const errorCode = @"errorCode";
static NSString * const isProviderError = @"isProviderError";
static NSString * const description = @"description";
static NSString * const providerErrorResponse = @"providerErrorResponse";
static NSString * const message = @"message";

@implementation LRResponseSerializer


- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error {
    id responseObject = nil;
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        NSError *validateError = *error;
        if (validateError) {
            NSError *jsonError;
            NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            NSError *loginRadiusError;

            // HTTP Not acceptable errorCode. Deserialize LoginRadius Error if payload present
            if (!jsonError)
            {
                //Check if its from v1 or v2 server
                if(payload[errorCode])
                {
                    //v1 notation
                    if([payload[isProviderError] boolValue]) {
                        loginRadiusError = [NSError errorWithCode:[payload[errorCode] integerValue] description:payload[description] failureReason:payload[providerErrorResponse]];
                    } else {
                        loginRadiusError = [NSError errorWithCode:[payload[errorCode] integerValue] description:payload[description] failureReason:payload[message]];
                    }
                }else if (payload[[errorCode capitalizedFirst]])
                {
                    //v2 notation
                    if([payload[[isProviderError capitalizedFirst]] boolValue]) {
                        loginRadiusError = [NSError errorWithCode:[payload[[errorCode capitalizedFirst]] integerValue] description:payload[[description capitalizedFirst]] failureReason:payload[[providerErrorResponse capitalizedFirst]]];
                    } else {
                        loginRadiusError = [NSError errorWithCode:[payload[[errorCode capitalizedFirst]] integerValue] description:payload[[description capitalizedFirst]] failureReason:payload[[message capitalizedFirst]]];
                    }
                }

                (*error) = loginRadiusError;
            } else {
                (*error) = validateError;
            }
        }
    } else {
        responseObject = [super responseObjectForResponse:response data:data error:error];
    }
    return responseObject;
}

@end
