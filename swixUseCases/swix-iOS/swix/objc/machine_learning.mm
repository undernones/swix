//
//  svm.m
//  swix
//
//  Created by Scott Sievert on 7/16/14.
//  Copyright (c) 2014 com.scott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenCV.h"
#import "swix-Bridging-Header.h"
using namespace cv;

void doubleToFloat(double * x, float * y, int N){
    vDSP_vdpsp(x, 1, y, 1, N);
}



// #### STATE VECTOR MACHINE
@implementation cvSVM : NSObject
CvSVM ocvSVM;
CvSVMParams params;
int N; // number of variables
int M; // number of responses
void copy_float_to_double(float* x, double* y, int N){
    vDSP_vspdp(x, 1, y, 1, N);
}
void copy_float(float* x, float * y, int N){
    cblas_scopy(N, x, 1, y, 1);
}
void matToPointer_float(Mat x, float * y, int N){
    if  (!x.isContinuous()){
        printf("Careful! The OpenCV::Mat-->double* conversion didn't go well as x is not continuous in memory! (message printed from swix/objc/opencv.mm:matToPointer)\n");
    }
    uchar* ptr = x.data;
    float* ptrD = (float*)ptr;
    copy_float(ptrD, y, N);
}
-(void)setParams:(NSString*)svm_type kernel:(NSString*)kernel{
    //if ([svm_type isEqualTo:@"svc"]) { params.svm_type = CvSVM::C_SVC; }
    //if ([kernel isEqualTo:@"linear"]){ params.kernel_type = CvSVM::LINEAR;}
    
    // I don't have enough application to test this right now. See [0] on how to set the SVM parameters; it looks like you call a function.
    // [0]:http://docs.opencv.org/modules/ml/doc/support_vector_machines.html#cvsvmparams-cvsvmparams
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
}
-(NSObject*)init{
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    return self;
}
-(void) train:(double *)x targets:(double *)targets m:(int)M n:(int)N{
    // M is the number of responses or rows; N is columns or variables
    float * x2 = (float *)malloc(sizeof(float) * M * N);
    float * t2 = (float *)malloc(sizeof(float) * M);
    doubleToFloat(x, x2, M*N);
    doubleToFloat(targets, t2, M*1);
    Mat xMat(M, N, CV_32FC1, x2);
    Mat tMat(M, 1, CV_32FC1, t2);
    Mat x3 = Mat();
    ocvSVM.train(xMat, tMat, x3, x3, params);
}
- (float) predict:(double *)x n:(int)N{
    float * x2 = (float *)malloc(sizeof(float) * 1 * N);
    doubleToFloat(x, x2, N);
    Mat xMat(1, N, CV_32FC1, x2);
    float targetPredict = ocvSVM.predict(xMat);
    return targetPredict;
}
- (double*) predict:(double*)x into:(double*)y m:(int)M n:(int)N{
    float * x2 = (float *)malloc(sizeof(float) * M * N);
    doubleToFloat(x, x2, M*N);
    Mat xMat(M, N, CV_32FC1, x2);
    Mat yMat(M, N, CV_32FC1);
    
    ocvSVM.predict(xMat, yMat);
    float* y2 = (float *)malloc(sizeof(float) * M);
    matToPointer_float(yMat, y2, M);
    copy_float_to_double(y2, y, M);
    return y;
}
@end

// #### STATE VECTOR MACHINE
@implementation kNN : NSObject
int kN;
int kM;

CvKNearest cvknn;

-(NSObject*)init{
    return self;
}

- (void) train:(double *)x targets:(double *)tar m:(int)M n:(int)N{
    float * x2 = (float *)malloc(sizeof(float) * M * N);
    float * t2 = (float *)malloc(sizeof(float) * M * 1);
    Mat x3(M, N, CV_32FC1, x2);
    Mat t3(M, 1, CV_32FC1, t2);
    
    cvknn.train(x3, t3);
}
- (double) predict:(double *)x n:(int)N k:(int)k{
    float * x2 = (float *)malloc(sizeof(float) * N * 1);
    Mat x3(1, N, CV_32FC1, x2);
    Mat results(1, 1, CV_32FC1);
    float targetPredict = -3.14;
    targetPredict = cvknn.find_nearest(x3, k, &results);
    
    std::cout << results << std::endl;
    std::cout << results.at<double>(0,0) << std::endl;
    return results.at<double>(0,0);
}
@end

