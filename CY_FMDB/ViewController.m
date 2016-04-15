//
//  ViewController.m
//  CY_FMDB
//
//  Created by  GUOBIN on 16/4/13.
//  Copyright © 2016年 千里之行始于足下. All rights reserved.
//

#import "ViewController.h"
#import "GeneralDB.h"
#import "Classes.h"
#import "MJExtension.h"
#import "Transcript.h"

#define CREATE_STUDENT_SQL @"CREATE TABLE IF NOT EXISTS Classes (studentID integer PRIMARY KEY AUTOINCREMENT, studentName text, studentSex text)"
#define INSERT_STUDENT_SQL @"INSERT INTO Classes VALUES(NULL,?,?)"
#define SELECT_STUDENT_SQL @"SELECT * FROM Classes"
#define UPDATE_STUDENT_SQL @"UPDATE Classes SET studentName = ?, studentSex = ? where studentID = ?"
#define DELETE_STUDENT_SQL @"DELETE FROM Classes where studentID = ?"
#define MPTY_STUDENT_SQL @"DELETE FROM Classes"

#pragma mark - 班级表的外键表  (成绩单)
#define CREATE_TRANSCRIPT_SQL @"CREATE TABLE IF NOT EXISTS Transcript ( mathematics text, english text,sno integer,FOREIGN KEY (sno) REFERENCES Classes (studentID) ON DELETE CASCADE ON UPDATE CASCADE)"
#define INSERT_TRANSCRIPT_SQL @"INSERT INTO Transcript VALUES(?,?,?)"
#define SELECT_TRANSCRIPT_SQL @"SELECT * FROM Transcript"

/**
 降序
 @"SELECT * FROM 'tableName' order by date DESC"
 外键
 sno integer,FOREIGN KEY (sno) REFERENCES Classes (studentID) ON DELETE CASCADE ON UPDATE CASCADE)
 */

typedef BOOL(^updateStudentData)(NSString *name,NSString *sex);
typedef void(^selectedCellIndex)();

@interface StudentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *studentID;
@property (weak, nonatomic) IBOutlet UITextField *studentName;
@property (weak, nonatomic) IBOutlet UITextField *studentSex;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UITextField *mathematics;
@property (weak, nonatomic) IBOutlet UITextField *english;

@property (weak, nonatomic) Classes *myClasses;

@property (copy, nonatomic) updateStudentData updateData;
@property (copy, nonatomic) selectedCellIndex selectedIndex;

@end

@implementation StudentCell
@synthesize myClasses;

- (void)setSubViewAttribute {
    [_updateButton setTitle:@"修改" forState:UIControlStateNormal];
    [_updateButton setTitle:@"确定" forState:UIControlStateSelected];
}

- (void)setMyClasses:(Classes *)classes {
    myClasses = classes;
    self.studentID.text = classes.studentID;
    self.studentName.text = classes.studentName;
    self.studentSex.text = classes.studentSex;
    self.mathematics.text = classes.transcript.mathematics;
    self.english.text = classes.transcript.english;
}

- (IBAction)UpdateStudentData:(UIButton *)button {
    if (button.selected) {
        if (self.updateData) {
            if (!self.updateData(_studentName.text,_studentSex.text)) {
                return;
            }
        }
        
        [self updateButtonSelected:NO];
    } else {
        
        if (self.selectedIndex) {
            self.selectedIndex();
        }
        [self updateButtonSelected:YES];
    }
}

- (void)updateButtonSelected:(BOOL)btnEnabled {
    _updateButton.selected = btnEnabled;
    _studentName.enabled = btnEnabled;
    _studentSex.enabled = btnEnabled;
}

@end


//---------------------------------------------------------

@interface ViewController () {
    
    __weak IBOutlet UITableView *myTableView;
    __weak IBOutlet UITextField *studentName;
    __weak IBOutlet UITextField *studentSex;
    __weak IBOutlet UIButton *addStudentButton;
    
    NSArray *_list;
    NSInteger _selectUpdateButtonIndex;
}
@property (strong, nonatomic) IBOutletCollection(id) NSArray *fillInViews;
@end

static NSString *const tableName = @"Classes";
static NSString *const transcriptTableName = @"Transcript";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectUpdateButtonIndex = -1;
    
    [[GeneralDB shareInstance] createTable:CREATE_STUDENT_SQL tableName:tableName];
    [[GeneralDB shareInstance] createTable:CREATE_TRANSCRIPT_SQL tableName:transcriptTableName];
    [self resetData:^{
        [myTableView reloadData];
    }];
    
    [addStudentButton setTitle:@"新增学生" forState:UIControlStateNormal];
    [addStudentButton setTitle:@"保存" forState:UIControlStateSelected];
    
    // 获取本地数据库
//    [self getLocalData];
}

- (void)getLocalData {
    GeneralDB *bd = [GeneralDB shareInstance];
    bd.dataBaseName = @"LocalData.sqlite";
    NSLog(@"Classes = %@",[bd getTableData:@"SELECT * FROM Classes"]);
    NSLog(@"Transcript = %@",[bd getTableData:@"SELECT * FROM Transcript"]);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"StudentCell";
    StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self setCell:cell indexPath:indexPath];
    return cell;
}

- (void)setCell:(StudentCell *)cell indexPath:(NSIndexPath *)indexPath {
    [cell setSubViewAttribute];
    Classes *classes = _list[indexPath.row];
    cell.myClasses = classes;
    cell.updateData = ^(NSString *name, NSString *sex) {
        if ([name isEqualToString:@""] || [sex isEqualToString:@""]) {
            [self showAlert];
            return NO;
        }
        [[GeneralDB shareInstance] updateTableData:UPDATE_STUDENT_SQL,name,sex,classes.studentID];
        return YES;
    };
    cell.selectedIndex = ^{
        _selectUpdateButtonIndex = indexPath.row;
    };
    if (_selectUpdateButtonIndex != -1 && _selectUpdateButtonIndex == indexPath.row) {
        [cell updateButtonSelected:YES];
    } else {
        [cell updateButtonSelected:NO];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}   //是否具有可移动功能

// 删除某行数据
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Classes *classes = _list[indexPath.row];
        [[GeneralDB shareInstance] deleteTableData:DELETE_STUDENT_SQL,classes.studentID];
        [self resetData:^{
            if (_selectUpdateButtonIndex == indexPath.row) {
                _selectUpdateButtonIndex = -1;
            }
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView reloadData];
            [self getTranscriptData];
        }];
    }
}

#pragma mark - 新增学生
- (IBAction)addStudent:(UIButton *)button {
    if (button.selected) {
        if ([studentName.text isEqualToString:@""] || [studentSex.text isEqualToString:@""]) {
            [self showAlert];
            return;
        }
        button.selected = NO;
        
        [self insertStudentAndAddStudentResult];
        
        [self resetData:^{
            [self getTranscriptData];
            [myTableView reloadData];
        }];
        studentName.text = @"";
        studentSex.text  = @"";
        _selectUpdateButtonIndex = -1;
        [self.view endEditing:YES];
        for (UIView *view in _fillInViews) { view.hidden = YES;}
    } else {
        button.selected = YES;
        for (UIView *view in _fillInViews) { view.hidden = NO; }
        [studentName becomeFirstResponder];
    }
}

- (void)insertStudentAndAddStudentResult {
    [[GeneralDB shareInstance] insertTableData:INSERT_STUDENT_SQL,studentName.text,studentSex.text];
    
    // 给成绩单插入数据
    NSArray *classesArr = [[GeneralDB shareInstance] getTableData:SELECT_STUDENT_SQL];
    NSDictionary *dic = classesArr[classesArr.count - 1];
    Classes *classes = [Classes mj_objectWithKeyValues:dic];
    [[GeneralDB shareInstance] insertTableData:INSERT_TRANSCRIPT_SQL,[self getResult],[self getResult],classes.studentID];
}

- (NSString *)getResult {
    int x = arc4random() % 101;
    return [NSString stringWithFormat:@"%d",x];
}

#pragma mark - 重新获取数据库数据
- (void)resetData:(void(^)())block {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        
        NSArray *classesArr = [[GeneralDB shareInstance] getTableData:SELECT_STUDENT_SQL];
        NSMutableArray *listArray = [NSMutableArray array];
        
        for (NSDictionary *dic in classesArr) {
            Classes *classes = [Classes mj_objectWithKeyValues:dic];
            [listArray addObject:classes];
        }
        NSArray *transcriptArr = [[GeneralDB shareInstance] getTableData:SELECT_TRANSCRIPT_SQL];
        
        for (int i = 0; i < transcriptArr.count; i++) {
            NSDictionary *dic = transcriptArr[i];
            Transcript *transcript = [Transcript mj_objectWithKeyValues:dic];
            Classes *classes = listArray[i];
            classes.transcript = transcript;
        }
        
        _list = listArray;
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    });
}

- (void)getTranscriptData {
    NSLog(@"tra = %@",[[GeneralDB shareInstance] getTableData:SELECT_TRANSCRIPT_SQL]);
}

#pragma mark - 显示输入有误Alert
- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入有误" message:@"请重新输入!" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 清空
- (IBAction)empty {
    [[GeneralDB shareInstance] deleteTableData:MPTY_STUDENT_SQL];
    [self getTranscriptData];
    [self resetData:^{
        [myTableView reloadData];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
