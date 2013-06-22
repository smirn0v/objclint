//
//  TextReportGenerator.m
//  objclint
//
//  Created by Smirnov on 5/1/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "TextReportGenerator.h"
#import "ObjclintCoordinator.h"
#import "ObjclintIssue.h"

@implementation TextReportGenerator

#pragma mark - ObjclintReportGenerator

- (void) generateReportForProjectIdentity:(NSString*) identity
                        withinCoordinator:(id<ObjclintCoordinator>) coordinator {
    
    NSArray* issues = [coordinator issuesForProjectIdentity: identity];
    
    issues = [issues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ObjclintIssue* issue1 = obj1;
        ObjclintIssue* issue2 = obj2;
        
        NSComparisonResult fileComparison = [issue1.fileName compare: issue2.fileName];
        
        if(fileComparison != NSOrderedSame)
            return fileComparison;
        
        NSComparisonResult lineComparison = issue1.line < issue2.line ? NSOrderedAscending : NSOrderedDescending;
        
        if(issue1.line != issue2.line)
            return lineComparison;
        
        NSComparisonResult columnComparison = issue1.column < issue2.column ? NSOrderedAscending : NSOrderedDescending;
        
        if(issue1.column != issue2.column)
            return columnComparison;
        
        return NSOrderedSame;
    }];
    
    NSString* const reportFormat = @"$file:$line:$column:$type: $content\n";
    NSMutableString* reportLine = nil;
        @autoreleasepool {
        for(ObjclintIssue* issue in issues) {
            reportLine = [NSMutableString stringWithString: reportFormat];
            
            void(^setParameter)(NSString*,NSString*) = ^(NSString* name, NSString* value) {
                [reportLine replaceOccurrencesOfString:name
                                            withString:value
                                               options:0
                                                 range:NSMakeRange(0, reportLine.length)];
            };
            
            setParameter(@"$file",    issue.fileName);
            setParameter(@"$line",    @(issue.line).stringValue);
            setParameter(@"$column",  @(issue.column).stringValue);
            setParameter(@"$type",    issue.issueTypeDescription);
            setParameter(@"$content", issue.description);
                         
            printf("%s",reportLine.UTF8String);
        }
    }
}


@end
